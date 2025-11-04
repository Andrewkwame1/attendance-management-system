import 'dart:developer' as developer;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CameraCaptureScreen extends StatefulWidget {
  const CameraCaptureScreen({super.key});

  @override
  State<CameraCaptureScreen> createState() => _CameraCaptureScreenState();
}

class _CameraCaptureScreenState extends State<CameraCaptureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  int _captureCount = 0;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    // Using the front camera
    final firstCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front);

    _controller = CameraController(
      firstCamera,
      ResolutionPreset.medium,
    );

    _initializeControllerFuture = _controller.initialize();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _takePicture() async {
    try {
      await _initializeControllerFuture;
      await _controller.takePicture();

      setState(() {
        _captureCount++;
      });

      if (_captureCount >= 3) {
        if (mounted) {
          // TODO: Navigate to a confirmation screen
          context.go('/student/enrollment/confirmation');
        }
      }
    } catch (e, s) {
      developer.log(
        'Error taking picture',
        name: 'camera_capture',
        error: e,
        stackTrace: s,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Capture Your Face'),
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Column(
              children: [
                Expanded(
                  child: CameraPreview(_controller),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text('Captures: $_captureCount/3'),
                ),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _takePicture,
        child: const Icon(Icons.camera_alt),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
