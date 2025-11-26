import 'dart:developer' as developer;
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;

class CheckInCameraScreen extends StatefulWidget {
  final String sessionId;

  const CheckInCameraScreen({super.key, required this.sessionId});

  @override
  State<CheckInCameraScreen> createState() => _CheckInCameraScreenState();
}

class _CheckInCameraScreenState extends State<CheckInCameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  late FaceDetector _faceDetector;
  bool _isProcessing = false;
  double _similarityThreshold = 0.98;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _initializeFaceDetector();
    _initializeRemoteConfig();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final firstCamera = cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front);

      _controller = CameraController(
        firstCamera,
        ResolutionPreset.medium,
      );

      _initializeControllerFuture = _controller.initialize();
      await _initializeControllerFuture;

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      developer.log('Error initializing camera: $e', name: 'CheckInCameraScreen');
    }
  }

  void _initializeFaceDetector() {
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        performanceMode: FaceDetectorMode.accurate,
        enableLandmarks: true,
        enableContours: true,
      ),
    );
  }

  void _initializeRemoteConfig() {
    final remoteConfig = FirebaseRemoteConfig.instance;
    setState(() {
      _similarityThreshold = remoteConfig.getDouble('similarity_threshold');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _faceDetector.close();
    super.dispose();
  }

  Future<List<double>?> _getEmbeddings(InputImage image) async {
    final List<Face> faces = await _faceDetector.processImage(image);
    if (faces.isEmpty) {
      return null;
    }
    // Placeholder for a real face embedding model
    final FaceContour? faceContour = faces.first.contours[FaceContourType.face];
    if (faceContour == null) {
      return null;
    }
    return faceContour.points
        .map((point) => [point.x.toDouble(), point.y.toDouble()])
        .expand((point) => point)
        .toList();
  }


  double _calculateSimilarity(List<double> embeddings1, List<double> embeddings2) {
    if (embeddings1.isEmpty || embeddings2.isEmpty) {
      return 0.0;
    }
    // Using cosine similarity as a placeholder
    double dotProduct = 0;
    double mag1 = 0;
    double mag2 = 0;
    for (int i = 0; i < embeddings1.length; i++) {
      dotProduct += embeddings1[i] * embeddings2[i];
      mag1 += embeddings1[i] * embeddings1[i];
      mag2 += embeddings2[i] * embeddings2[i];
    }
    return dotProduct / (mag1 * mag2);
  }

  void _takePictureAndCheckIn() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // 1. Fetch session data
      final sessionDoc = await FirebaseFirestore.instance
          .collection('sessions')
          .doc(widget.sessionId)
          .get();

      if (!mounted) return;
      if (!sessionDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Session not found.')),
        );
        return;
      }

      final sessionData = sessionDoc.data() as Map<String, dynamic>;
      final sessionLocation = sessionData['location'] as GeoPoint;
      final sessionRadius = sessionData['radius'] as double;

      // 2. Get student's current location
      final Position position = await Geolocator.getCurrentPosition();

      // 3. Calculate distance
      final double distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        sessionLocation.latitude,
        sessionLocation.longitude,
      );

      if (!mounted) return;
      // 4. Check if within geofence
      if (distance > sessionRadius) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('You are too far from the class to check in.')),
        );
        return;
      }

      // 5. Take picture and generate embedding
      await _initializeControllerFuture;
      final imageFile = await _controller.takePicture();
      final checkInInputImage = InputImage.fromFilePath(imageFile.path);
      final checkInEmbeddings = await _getEmbeddings(checkInInputImage);

      if (!mounted) return;
      if (checkInEmbeddings == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not detect a face. Please try again.')),
        );
        return;
      }
      
      // 6. Fetch enrolled images and compare embeddings
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final studentDoc = await FirebaseFirestore.instance.collection('students').doc(user.uid).get();
      final enrolledImages = (studentDoc.data()?['enrolledImages'] as List<dynamic>?)?.cast<String>() ?? [];

      developer.log('Found ${enrolledImages.length} enrolled images.', name: 'CheckInCameraScreen');

      bool matchFound = false;
      for (final imageUrl in enrolledImages) {
        final response = await http.get(Uri.parse(imageUrl));
        final image = img.decodeImage(response.bodyBytes);
        if (image == null) continue;
        final enrolledInputImage = InputImage.fromBytes(bytes: response.bodyBytes, metadata: InputImageMetadata(size: Size(image.width.toDouble(), image.height.toDouble()), rotation: InputImageRotation.rotation0deg, format: InputImageFormat.nv21, bytesPerRow: image.width));
        final enrolledEmbeddings = await _getEmbeddings(enrolledInputImage);

        if (enrolledEmbeddings != null) {
          final similarity = _calculateSimilarity(checkInEmbeddings, enrolledEmbeddings);
          developer.log('Similarity with image $imageUrl: $similarity', name: 'CheckInCameraScreen');
          if (similarity > _similarityThreshold) {
            matchFound = true;
            developer.log('Match found with image $imageUrl', name: 'CheckInCameraScreen');
            break;
          }
        }
      }

      if (!mounted) return;
      if (!matchFound) {
        developer.log('No match found for student ${user.uid}', name: 'CheckInCameraScreen');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Face not recognized. Please try again.')),
        );
        return;
      }

      // 7. Proceed with check-in
      final storageRef = FirebaseStorage.instance.ref().child(
          'check-ins/${widget.sessionId}/${DateTime.now().toIso8601String()}.jpg');
      await storageRef.putFile(File(imageFile.path));
      final imageUrl = await storageRef.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('sessions')
          .doc(widget.sessionId)
          .collection('checkins')
          .add({
        'studentId': user.uid,
        'studentName': user.displayName ?? 'Test Student',
        'timestamp': FieldValue.serverTimestamp(),
        'location': GeoPoint(position.latitude, position.longitude),
        'imageUrl': imageUrl,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Check-in successful!')),
        );
        context.go('/'); // Navigate back to the home screen
      }
    } catch (e, s) {
      developer.log('Error during check-in: $e', stackTrace: s, name: 'CheckInCameraScreen');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Check In')),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(_controller);
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _takePictureAndCheckIn,
        child: _isProcessing 
            ? const CircularProgressIndicator(color: Colors.white) 
            : const Icon(Icons.camera_alt),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
