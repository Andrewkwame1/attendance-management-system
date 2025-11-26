import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../notifications.dart';

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
  LatLng? _selectedLocation;
  double _radius = 100;

  bool _isLoading = false;

  Future<void> _selectDateTime(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      if (!context.mounted) return;
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
      if (_selectedLocation == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a location')),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          if (mounted) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('You must be logged in to create a session.')),
            );
          }
          return;
        }

        final newSessionRef = await FirebaseFirestore.instance.collection('sessions').add({
          'courseName': _courseNameController.text,
          'className': _classNameController.text,
          'lecturerName': _lecturerNameController.text,
          'startTime': _startTime,
          'endTime': _endTime,
          'teacherId': user.uid,
          'createdAt': FieldValue.serverTimestamp(),
          'location': GeoPoint(_selectedLocation!.latitude, _selectedLocation!.longitude),
          'radius': _radius,
        });

        await NotificationService.scheduleNotification(
          id: newSessionRef.id.hashCode,
          title: 'Upcoming Class: ${_courseNameController.text}',
          body: 'Your ${_classNameController.text} class is about to start.',
          scheduledDate: _startTime!.subtract(const Duration(minutes: 15)), // 15 minutes before start time
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Session created successfully')),
        );
        context.go('/teacher/session/${newSessionRef.id}');
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create session: $e')),
        );
        developer.log('Failed to create session', error: e);
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
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
              const SizedBox(height: 16),
              SizedBox(
                height: 300,
                child: GoogleMap(
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(37.7749, -122.4194), // Default to San Francisco
                    zoom: 12,
                  ),
                  onTap: (location) {
                    setState(() {
                      _selectedLocation = location;
                    });
                  },
                  markers: {
                    if (_selectedLocation != null)
                      Marker(
                        markerId: const MarkerId('selected-location'),
                        position: _selectedLocation!,
                      ),
                  },
                  circles: {
                    if (_selectedLocation != null)
                      Circle(
                        circleId: const CircleId('radius'),
                        center: _selectedLocation!,
                        radius: _radius,
                        fillColor: Colors.blue.withAlpha(77),
                        strokeColor: Colors.blue,
                        strokeWidth: 2,
                      ),
                  },
                ),
              ),
              const SizedBox(height: 16),
              Text('Radius: ${_radius.toInt()} meters'),
              Slider(
                value: _radius,
                min: 50,
                max: 500,
                divisions: 9,
                label: '${_radius.toInt()} m',
                onChanged: (value) {
                  setState(() {
                    _radius = value;
                  });
                },
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
