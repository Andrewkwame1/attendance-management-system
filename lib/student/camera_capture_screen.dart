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
    try {
      developer.log('Initializing camera...', name: 'camera.init');
      final cameras = await availableCameras();
      // Using the front camera
      final firstCamera = cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front);

      _controller = CameraController(
        firstCamera,
        ResolutionPreset.medium,
      );

      _initializeControllerFuture = _controller.initialize();
      await _initializeControllerFuture;

      developer.log('Camera initialized successfully.', name: 'camera.init');

      if (mounted) {
        setState(() {});
      }
    } catch (e, s) {
      developer.log(
        'Error initializing camera',
        name: 'camera.init',
        error: e,
        stackTrace: s,
        level: 1000, // SEVERE
      );
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
      developer.log('Taking picture...', name: 'camera.capture');
      final image = await _controller.takePicture();

      setState(() {
        _captureCount++;
      });
      
      developer.log(
        'Picture $_captureCount taken successfully at path: ${image.path}',
        name: 'camera.capture',
      );

      if (_captureCount >= 3) {
        developer.log(
          'All 3 pictures taken. Navigating to confirmation.',
          name: 'camera.capture',
        );
        if (mounted) {
          context.go('/student/enrollment/confirmation');
        }
      }
    } catch (e, s) {
      developer.log(
        'Error taking picture',
        name: 'camera.capture',
        error: e,
        stackTrace: s,
        level: 1000, // SEVERE
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
          if (snapshot.connectionState == ConnectionState.done && _controller.value.errorDescription == null) {
            return Column(
              children: [
                Expanded(
                  child: CameraPreview(_controller),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    'Captures: $_captureCount/3',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ],
            );
          } else if (snapshot.hasError) {
             return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 50),
                  const SizedBox(height: 10),
                  const Text('Error initializing camera.'),
                   Text(
                    '${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }
          else {
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
