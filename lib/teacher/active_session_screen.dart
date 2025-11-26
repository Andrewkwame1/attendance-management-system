import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:open_file/open_file.dart';

class ActiveSessionScreen extends StatefulWidget {
  final String sessionId;

  const ActiveSessionScreen({super.key, required this.sessionId});

  @override
  State<ActiveSessionScreen> createState() => _ActiveSessionScreenState();
}

class _ActiveSessionScreenState extends State<ActiveSessionScreen> {
  Future<void> _exportToCsv() async {
    final sessionDoc = await FirebaseFirestore.instance.collection('sessions').doc(widget.sessionId).get();
    final sessionData = sessionDoc.data() as Map<String, dynamic>;

    final checkinsSnapshot = await FirebaseFirestore.instance
        .collection('sessions')
        .doc(widget.sessionId)
        .collection('checkins')
        .orderBy('timestamp', descending: true)
        .get();

    final List<List<dynamic>> rows = [];
    rows.add(['Student Name', 'Student Email', 'Check-in Time']); // Header

    for (final doc in checkinsSnapshot.docs) {
      final checkin = doc.data();
      final timestamp = (checkin['timestamp'] as Timestamp).toDate();
      rows.add([
        checkin['studentName'],
        checkin['studentEmail'],
        DateFormat.yMMMd().add_jm().format(timestamp),
      ]);
    }

    final String csv = const ListToCsvConverter().convert(rows);
    final String courseName = sessionData['courseName'].replaceAll(' ', '_');
    final String className = sessionData['className'].replaceAll(' ', '_');
    final String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final String fileName = '${courseName}_${className}_$formattedDate.csv';

    try {
      final Directory directory = await getApplicationDocumentsDirectory();
      final String path = '${directory.path}/$fileName';
      final File file = File(path);
      await file.writeAsString(csv);

      OpenFile.open(path);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error exporting CSV: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Session Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Export to CSV',
            onPressed: _exportToCsv,
          ),
        ],
      ),
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
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Course: ${sessionData['courseName']}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text('Class: ${sessionData['className']}', style: const TextStyle(fontSize: 16)),
                        const SizedBox(height: 8),
                        Text('Lecturer: ${sessionData['lecturerName']}', style: const TextStyle(fontSize: 16)),
                        const SizedBox(height: 8),
                        Text(
                            'Status: ${sessionData['endTime'].toDate().isBefore(DateTime.now()) ? 'Finished' : 'Active'}',
                            style: TextStyle(fontSize: 16, color: sessionData['endTime'].toDate().isBefore(DateTime.now()) ? Colors.red : Colors.green)
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: QrImageView(
                    data: widget.sessionId,
                    version: QrVersions.auto,
                    size: 200.0,
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Check-ins:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                          final studentEmail = checkin['studentEmail'];
                          final timestamp = (checkin['timestamp'] as Timestamp).toDate();

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 4.0),
                            child: ListTile(
                              leading: const CircleAvatar(child: Icon(Icons.person)),
                              title: Text(studentName),
                              subtitle: Text('$studentEmail\nChecked in at: ${DateFormat.yMMMd().add_jm().format(timestamp)}'),
                            ),
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
