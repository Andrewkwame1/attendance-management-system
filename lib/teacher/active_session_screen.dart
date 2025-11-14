import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ActiveSessionScreen extends StatefulWidget {
  final String sessionId;

  const ActiveSessionScreen({super.key, required this.sessionId});

  @override
  State<ActiveSessionScreen> createState() => _ActiveSessionScreenState();
}

class _ActiveSessionScreenState extends State<ActiveSessionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Active Session')),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('sessions')
            .doc(widget.sessionId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('Session not found.'));
          }

          final sessionData = snapshot.data!.data() as Map<String, dynamic>;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Course: ${sessionData['courseName']}'),
                Text('Class: ${sessionData['className']}'),
                Text('Lecturer: ${sessionData['lecturerName']}'),
                Text(
                    'Status: ${sessionData['endTime'].toDate().isBefore(DateTime.now()) ? 'Finished' : 'Active'}'),
                const SizedBox(height: 20),
                const Text('Check-ins:', style: TextStyle(fontWeight: FontWeight.bold)),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('sessions')
                        .doc(widget.sessionId)
                        .collection('checkins')
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
                    builder: (context, checkinSnapshot) {
                      if (checkinSnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!checkinSnapshot.hasData || checkinSnapshot.data!.docs.isEmpty) {
                        return const Center(child: Text('No check-ins yet.'));
                      }

                      return ListView.builder(
                        itemCount: checkinSnapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          final checkin = checkinSnapshot.data!.docs[index];
                          final studentName = checkin['studentName'];
                          final timestamp = (checkin['timestamp'] as Timestamp).toDate();

                          return ListTile(
                            title: Text(studentName),
                            subtitle: Text(timestamp.toString()),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
