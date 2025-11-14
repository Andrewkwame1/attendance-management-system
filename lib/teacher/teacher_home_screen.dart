import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TeacherHomeScreen extends StatelessWidget {
  const TeacherHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              context.go('/');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () => context.go('/teacher/create-session'),
              child: const Text('Create a New Session'),
            ),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Your Sessions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('sessions')
                  .where('teacherId', isEqualTo: user?.uid)
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('You have not created any sessions yet.'));
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final sessionDoc = snapshot.data!.docs[index];
                    final sessionData = sessionDoc.data() as Map<String, dynamic>;
                    final courseName = sessionData['courseName'];
                    final className = sessionData['className'];
                    final startTime = (sessionData['startTime'] as Timestamp).toDate();

                    return ListTile(
                      title: Text('$courseName - $className'),
                      subtitle: Text('Starts: ${startTime.toString()}'),
                      onTap: () => context.go('/teacher/session/${sessionDoc.id}'),
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
