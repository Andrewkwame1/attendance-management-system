import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class TeacherHomeScreen extends StatefulWidget {
  const TeacherHomeScreen({super.key});

  @override
  State<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends State<TeacherHomeScreen> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final List<DocumentSnapshot> _sessions = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
    _listenToSessions();
  }

  void _listenToSessions() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    FirebaseFirestore.instance
        .collection('sessions')
        .where('teacherId', isEqualTo: user.uid)
        .orderBy('startTime', descending: true)
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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Teacher Dashboard', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
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
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (!context.mounted) return;
              context.go('/');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search sessions by course or class name',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('sessions')
                  .where('teacherId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                  .orderBy('startTime', descending: true)
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
                          'No sessions yet!\nTap the + button to create your first session.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                final filteredDocs = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final courseName = data['courseName'].toString().toLowerCase();
                  final className = data['className'].toString().toLowerCase();
                  final query = _searchQuery.toLowerCase();
                  return courseName.contains(query) || className.contains(query);
                }).toList();

                if (filteredDocs.isEmpty) {
                  return Center(
                    child: Text(
                      'No sessions match your search.',
                      style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey[600]),
                    ),
                  );
                }

                return AnimatedList(
                  key: _listKey,
                  initialItemCount: filteredDocs.length,
                  padding: const EdgeInsets.all(8.0),
                  itemBuilder: (context, index, animation) {
                    final sessionDoc = filteredDocs[index];
                    return _buildSessionCard(context, sessionDoc, animation);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/teacher/create-session'),
        tooltip: 'Create Session',
        icon: const Icon(Icons.add),
        label: Text('Create Session', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        elevation: 8,
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
    );
  }

  Widget _buildSessionCard(BuildContext context, DocumentSnapshot sessionDoc, Animation<double> animation) {
    final sessionData = sessionDoc.data() as Map<String, dynamic>;
    final courseName = sessionData['courseName'];
    final className = sessionData['className'];
    final startTime = (sessionData['startTime'] as Timestamp).toDate();
    final endTime = (sessionData['endTime'] as Timestamp).toDate();
    final now = DateTime.now();

    String status;
    IconData icon;
    Color color;

    if (now.isAfter(endTime)) {
      status = 'Past';
      icon = Icons.history;
      color = Colors.grey.shade600;
    } else if (now.isAfter(startTime) && now.isBefore(endTime)) {
      status = 'Active';
      icon = Icons.play_circle_fill_outlined;
      color = Colors.green.shade600;
    } else {
      status = 'Upcoming';
      icon = Icons.event_note_outlined;
      color = Colors.blue.shade600;
    }

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.1),
          end: Offset.zero,
        ).animate(animation),
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: LinearGradient(
                colors: [Colors.white, Colors.grey.shade50],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              leading: CircleAvatar(
                backgroundColor: color.withAlpha(25),
                child: Icon(icon, color: color, size: 28),
              ),
              title: Text(
                '$courseName - $className',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87),
              ),
              subtitle: Text(
                '${DateFormat.yMMMd().add_jm().format(startTime)} - ${DateFormat.jm().format(endTime)}\nStatus: $status',
                style: GoogleFonts.poppins(color: Colors.black54, height: 1.5),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.black54, size: 16),
              onTap: () => context.go('/teacher/session/${sessionDoc.id}'),
            ),
          ),
        ),
      ),
    );
  }
}
