import 'package:flutter/material.dart';

class EnrolledStudentsScreen extends StatelessWidget {
  const EnrolledStudentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Fetch and display the list of enrolled students
    final List<String> enrolledStudents = [
      'Alice Smith',
      'Bob Johnson',
      'Charlie Brown',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Enrolled Students'),
      ),
      body: ListView.builder(
        itemCount: enrolledStudents.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(enrolledStudents[index]),
          );
        },
      ),
    );
  }
}
