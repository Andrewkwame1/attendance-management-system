import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final List<DocumentSnapshot> _sessions = [];

  @override
  void initState() {
    super.initState();
    _listenToSessions();
  }

  void _listenToSessions() {
    FirebaseFirestore.instance
        .collection('sessions')
        .where('endTime', isGreaterThan: Timestamp.now())
        .orderBy('endTime', descending: false)
        .snapshots()
        .listen((snapshot) {
      for (var change in snapshot.docChanges) {
        switch (change.type) {
          case DocumentChangeType.added:
            _sessions.insert(change.newIndex, change.doc);
            _listKey.currentState?.insertItem(change.newIndex);
            break;
          case DocumentChangeType.removed:
            // This implementation assumes that a session is never removed, only added or modified.
            break;
          case DocumentChangeType.modified:
            // This implementation assumes that a session is never modified, only added or removed.
            break;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Available Sessions', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Theme.of(context).primaryColor, Theme.of(context).colorScheme.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'My Profile',
            onPressed: () => context.go('/student/profile'),
          ),
          IconButton(
            icon: const Icon(Icons.face_retouching_natural_outlined),
            tooltip: 'Enroll Face',
            onPressed: () => context.go('/student/enrollment'),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('sessions')
            .where('endTime', isGreaterThan: Timestamp.now())
            .orderBy('endTime', descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.school_outlined, size: 100, color: Colors.grey[400]),
                  const SizedBox(height: 20),
                  Text(
                    'No active sessions available.',
                    style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return AnimatedList(
            key: _listKey,
            initialItemCount: _sessions.length,
            padding: const EdgeInsets.all(8.0),
            itemBuilder: (context, index, animation) {
              final sessionDoc = _sessions[index];
              final sessionData = sessionDoc.data() as Map<String, dynamic>;
              final courseName = sessionData['courseName'];
              final className = sessionData['className'];
              final lecturerName = sessionData['lecturerName'] ?? 'N/A';
              final endTime = (sessionData['endTime'] as Timestamp).toDate();

              return _buildSessionCard(context, courseName, className, lecturerName, endTime, sessionDoc.id, animation);
            },
          );
        },
      ),
    );
  }

  Widget _buildSessionCard(BuildContext context, String courseName, String className, String lecturerName, DateTime endTime, String sessionId, Animation<double> animation) {
    return ScaleTransition(
      scale: animation,
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor.withAlpha(200),
                Theme.of(context).colorScheme.secondary.withAlpha(200),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.onPrimary,
              child: Icon(Icons.school, color: Theme.of(context).primaryColor),
            ),
            title: Text(
              '$courseName - $className',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
            ),
            subtitle: Text(
              'Lecturer: $lecturerName\nEnds at: ${DateFormat.jm().format(endTime)}',
              style: GoogleFonts.poppins(color: Colors.white70, height: 1.5),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
            onTap: () => context.go('/student/check-in/camera/$sessionId'),
          ),
        ),
      ),
    );
  }
}
