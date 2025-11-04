import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EnrollmentConsentScreen extends StatelessWidget {
  const EnrollmentConsentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy & Consent'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Before we continue, please read and agree to the following:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  'I consent to provide my face data for the purpose of class attendance. The system will store a biometric embedding derived from my image; raw photos are not stored by default. I understand how long this data will be retained and may request deletion at any time.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                // A checkbox can be added here for explicit consent
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => context.go('/student/enrollment/form'),
                    child: const Text('I Agree'),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
