import 'dart:math';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:go_router/go_router.dart';
import 'dart:developer' as developer;

class CheckInCameraScreen extends StatefulWidget {
  final String sessionId;
  const CheckInCameraScreen({super.key, required this.sessionId});

  @override
  State<CheckInCameraScreen> createState() => _CheckInCameraScreenState();
}

class _CheckInCameraScreenState extends State<CheckInCameraScreen> {
  CameraController? _cameraController;
  Future<void>? _initializeControllerFuture;
  Interpreter? _interpreter;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _loadModel();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;
    _cameraController = CameraController(
      firstCamera,
      ResolutionPreset.medium,
    );
    _initializeControllerFuture = _cameraController!.initialize();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('mobilefacenet.tflite');
    } catch (e) {
      developer.log('Failed to load model: $e', name: 'CheckInCameraScreen');
    }
  }

  Future<Float32List> _getEmbedding(Uint8List imageBytes) async {
    img.Image? image = img.decodeImage(imageBytes);
    if (image == null) {
      throw Exception('Could not decode image');
    }

    img.Image resizedImage = img.copyResize(image, width: 112, height: 112);
    List<double> normalizedPixels = resizedImage.getBytes(order: img.ChannelOrder.rgb).map((pixel) => pixel / 255.0).toList();

    var input = List.generate(1, (i) => List.generate(112, (j) => List.generate(112, (k) => List.generate(3, (l) => 0.0))));

    for (int y = 0; y < 112; y++) {
      for (int x = 0; x < 112; x++) {
        int pixelIndex = (y * 112 + x) * 3;
        input[0][y][x][0] = normalizedPixels[pixelIndex];
        input[0][y][x][1] = normalizedPixels[pixelIndex + 1];
        input[0][y][x][2] = normalizedPixels[pixelIndex + 2];
      }
    }

    var output = List.filled(1 * 192, 0.0).reshape([1, 192]);

    _interpreter!.run(input, output);
    return output[0] as Float32List;
  }

  Future<void> _captureAndVerify() async {
    if (_isProcessing || !_cameraController!.value.isInitialized) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final XFile imageFile = await _cameraController!.takePicture();
      final Uint8List imageBytes = await imageFile.readAsBytes();
      final Float32List liveEmbedding = await _getEmbedding(imageBytes);

      final enrolledStudents = await FirebaseFirestore.instance.collection('enrolledStudents').get();

      String? matchedStudentId;
      String? matchedStudentName;
      double highestSimilarity = 0.8; 

      for (var doc in enrolledStudents.docs) {
        final data = doc.data();
        final List<dynamic> storedEmbedding = data['faceEmbedding'];
        final Float32List storedEmbeddingFloat = Float32List.fromList(storedEmbedding.map((e) => e as double).toList());

        final double similarity = _calculateCosineSimilarity(liveEmbedding, storedEmbeddingFloat);

        if (similarity > highestSimilarity) {
          highestSimilarity = similarity;
          matchedStudentId = doc.id;
          matchedStudentName = data['name'];
        }
      }

      if (matchedStudentId != null) {
        await FirebaseFirestore.instance
            .collection('sessions')
            .doc(widget.sessionId)
            .collection('checkins')
            .add({
              'studentId': matchedStudentId,
              'studentName': matchedStudentName,
              'timestamp': FieldValue.serverTimestamp(),
              'similarity': highestSimilarity,
            });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Check-in successful for $matchedStudentName!')),
        );
        context.go('/student');

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Face not recognized. Please try again.')),
        );
      }

    } catch (e) {
      developer.log('Error during verification: $e', name: 'CheckInCameraScreen');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  double _calculateCosineSimilarity(Float32List vec1, Float32List vec2) {
    double dotProduct = 0;
    double norm1 = 0;
    double norm2 = 0;
    for (int i = 0; i < vec1.length; i++) {
      dotProduct += vec1[i] * vec2[i];
      norm1 += vec1[i] * vec1[i];
      norm2 += vec2[i] * vec2[i];
    }
    return dotProduct / (sqrt(norm1) * sqrt(norm2));
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _interpreter?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Check-in')),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Column(
              children: [
                Expanded(
                  child: CameraPreview(_cameraController!),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _isProcessing
                      ? const CircularProgressIndicator()
                      : FloatingActionButton(
                          onPressed: _captureAndVerify,
                          child: const Icon(Icons.camera),
                        ),
                ),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
