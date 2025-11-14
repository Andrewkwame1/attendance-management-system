import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Your Role'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () => context.go('/student'),
              child: const Text('I am a Student'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.go('/teacher'),
              child: const Text('I am a Teacher'),
            ),
          ],
        ),
      ),
    );
  }
}
