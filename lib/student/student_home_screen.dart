import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentHomeScreen extends StatelessWidget {
  const StudentHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Dashboard'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () => context.go('/student/enrollment'),
              child: const Text('Enroll for Face Recognition'),
            ),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Active Sessions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('sessions')
                  .where('endTime', isGreaterThan: Timestamp.now())
                  .orderBy('endTime', descending: false) // Show soonest ending session first
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No active sessions found.'));
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final sessionDoc = snapshot.data!.docs[index];
                    final sessionData = sessionDoc.data() as Map<String, dynamic>;
                    final courseName = sessionData['courseName'];
                    final className = sessionData['className'];

                    return ListTile(
                      title: Text('$courseName - $className'),
                      subtitle: Text('Ends at: ${sessionData['endTime'].toDate().toString()}'),
                      onTap: () {
                        // TODO: Implement check-in flow
                        // For now, just show a dialog
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Check-in'),
                            content: Text('You are about to check in for $courseName.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  // Navigate to the camera screen for face verification
                                  Navigator.pop(context);
                                  context.go('/student/check-in/camera/${sessionDoc.id}');
                                },
                                child: const Text('Proceed'),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
