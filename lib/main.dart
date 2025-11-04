import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'student/enrollment_welcome_screen.dart';
import 'student/enrollment_consent_screen.dart';
import 'student/enrollment_form_screen.dart';
import 'student/camera_capture_screen.dart';
import 'teacher/enrolled_students_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const FaceRecognitionApp(),
    ),
  );
}

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}

class FaceRecognitionApp extends StatelessWidget {
  const FaceRecognitionApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primarySeedColor = Colors.blue;

    final TextTheme appTextTheme = TextTheme(
      displayLarge: GoogleFonts.poppins(fontSize: 57, fontWeight: FontWeight.bold),
      titleLarge: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w500),
      bodyMedium: GoogleFonts.poppins(fontSize: 14),
    );

    final GoRouter router = GoRouter(
      routes: <RouteBase>[
        GoRoute(
          path: '/',
          builder: (BuildContext context, GoRouterState state) {
            return const RoleSelectionScreen();
          },
        ),
        GoRoute(
          path: '/student',
          builder: (BuildContext context, GoRouterState state) {
            return const StudentHomeScreen();
          },
        ),
        GoRoute(
          path: '/student/enrollment/welcome',
          builder: (BuildContext context, GoRouterState state) {
            return const EnrollmentWelcomeScreen();
          },
        ),
        GoRoute(
          path: '/student/enrollment/consent',
          builder: (BuildContext context, GoRouterState state) {
            return const EnrollmentConsentScreen();
          },
        ),
        GoRoute(
          path: '/student/enrollment/form',
          builder: (BuildContext context, GoRouterState state) {
            return const EnrollmentFormScreen();
          },
        ),
        GoRoute(
          path: '/student/enrollment/camera',
          builder: (BuildContext context, GoRouterState state) {
            return const CameraCaptureScreen();
          },
        ),
        GoRoute(
          path: '/student/enrollment/confirmation',
          builder: (BuildContext context, GoRouterState state) {
            return const EnrollmentConfirmationScreen();
          },
        ),
        GoRoute(
          path: '/teacher',
          builder: (BuildContext context, GoRouterState state) {
            return const TeacherHomeScreen();
          },
        ),
        GoRoute(
          path: '/teacher/enrolled-students',
          builder: (BuildContext context, GoRouterState state) {
            return const EnrolledStudentsScreen();
          },
        ),
      ],
    );

    final ThemeData lightTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primarySeedColor,
        brightness: Brightness.light,
      ),
      textTheme: appTextTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: primarySeedColor,
        foregroundColor: Colors.white,
        titleTextStyle:
            GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );

    final ThemeData darkTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primarySeedColor,
        brightness: Brightness.dark,
      ),
      textTheme: appTextTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
        titleTextStyle:
            GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp.router(
          title: 'Face Recognition Attendance',
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeProvider.themeMode,
          routerConfig: router,
        );
      },
    );
  }
}

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Your Role'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () => context.go('/student'),
              child: const Text('I am a Student'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.go('/teacher'),
              child: const Text('I am a Teacher'),
            ),
          ],
        ),
      ),
    );
  }
}

class StudentHomeScreen extends StatelessWidget {
  const StudentHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Home'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome, Student!'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.go('/student/enrollment/welcome'),
              child: const Text('Enroll Now'),
            ),
          ],
        ),
      ),
    );
  }
}

class TeacherHomeScreen extends StatelessWidget {
  const TeacherHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Home'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children:[
            const Text('Welcome, Teacher!'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.go('/teacher/enrolled-students'),
              child: const Text('View Enrolled Students'),
            ),
          ],
        ),
      ),
    );
  }
}

class EnrollmentConfirmationScreen extends StatelessWidget {
  const EnrollmentConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enrollment Complete'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.green, size: 80),
            const SizedBox(height: 20),
            const Text('You have been successfully enrolled!'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.go('/student'),
              child: const Text('Go to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
