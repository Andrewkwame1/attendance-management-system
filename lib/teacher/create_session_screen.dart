import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateSessionScreen extends StatefulWidget {
  const CreateSessionScreen({super.key});

  @override
  State<CreateSessionScreen> createState() => _CreateSessionScreenState();
}

class _CreateSessionScreenState extends State<CreateSessionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _courseNameController = TextEditingController();
  final _classNameController = TextEditingController();
  final _lecturerNameController = TextEditingController();
  DateTime? _startTime;
  DateTime? _endTime;
  // Geofence fields will be added later

  bool _isLoading = false;

  Future<void> _selectDateTime(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(DateTime.now()),
      );
      if (pickedTime != null) {
        setState(() {
          final pickedDateTime = DateTime(
            picked.year,
            picked.month,
            picked.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          if (isStart) {
            _startTime = pickedDateTime;
          } else {
            _endTime = pickedDateTime;
          }
        });
      }
    }
  }

  Future<void> _createSession() async {
    if (_formKey.currentState!.validate()) {
      if (_startTime == null || _endTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select start and end times')),
        );
        return;
      }
      if (_startTime!.isAfter(_endTime!)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Start time must be before end time')),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          // This should not happen if routes are protected
          return;
        }

        await FirebaseFirestore.instance.collection('sessions').add({
          'courseName': _courseNameController.text,
          'className': _classNameController.text,
          'lecturerName': _lecturerNameController.text,
          'startTime': _startTime,
          'endTime': _endTime,
          'teacherId': user.uid,
          'createdAt': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Session created successfully')),
        );
        Navigator.pop(context); // Go back to the previous screen
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create session: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Session')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _courseNameController,
                decoration: const InputDecoration(labelText: 'Course Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a course name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _classNameController,
                decoration: const InputDecoration(labelText: 'Class Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a class name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _lecturerNameController,
                decoration: const InputDecoration(labelText: 'Lecturer Name (Optional)'),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text('Start Time: ${_startTime?.toString() ?? 'Not set'}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDateTime(context, true),
              ),
              ListTile(
                title: Text('End Time: ${_endTime?.toString() ?? 'Not set'}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDateTime(context, false),
              ),
              const SizedBox(height: 32),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _createSession,
                      child: const Text('Create Session'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
