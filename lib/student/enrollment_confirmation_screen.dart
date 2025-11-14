import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EnrollmentConfirmationScreen extends StatelessWidget {
  const EnrollmentConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enrollment Complete'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.green, size: 80),
            const SizedBox(height: 20),
            const Text('You have been successfully enrolled!'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.go('/student'),
              child: const Text('Go to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
