import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EnrollmentWelcomeScreen extends StatelessWidget {
  const EnrollmentWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome to Enrollment'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.school, size: 80, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 20),
              Text(
                'Let\'s get you set up for attendance.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => context.go('/student/enrollment/consent'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  textStyle: Theme.of(context).textTheme.titleMedium,
                ),
                child: const Text('Start Enrollment'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
