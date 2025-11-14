import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/role_selection_screen.dart';
import 'package:myapp/student/student_home_screen.dart';
import 'package:myapp/teacher/teacher_home_screen.dart';
import 'package:myapp/student/enrollment_welcome_screen.dart';
import 'package:myapp/student/enrollment_consent_screen.dart';
import 'package:myapp/student/enrollment_form_screen.dart';
import 'package:myapp/student/camera_capture_screen.dart';
import 'package:myapp/student/enrollment_confirmation_screen.dart';
import 'package:myapp/teacher/enrolled_students_screen.dart';
import 'package:myapp/teacher/login_screen.dart';
import 'package:myapp/teacher/create_session_screen.dart';
import 'package:myapp/teacher/active_session_screen.dart';

final GoRouter router = GoRouter(
  redirect: (BuildContext context, GoRouterState state) {
    final bool loggedIn = FirebaseAuth.instance.currentUser != null;
    final bool loggingIn = state.matchedLocation == '/teacher/login';

    // If the user is not logged in and not trying to log in,
    // and is trying to access a teacher route, redirect to the login page.
    if (!loggedIn && !loggingIn && state.matchedLocation.startsWith('/teacher')) {
      return '/teacher/login';
    }

    // If the user is logged in and tries to access the login page, redirect to the teacher home.
    if (loggedIn && loggingIn) {
      return '/teacher';
    }

    return null; // No redirect needed
  },
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
      path: '/teacher',
      builder: (BuildContext context, GoRouterState state) {
        return const TeacherHomeScreen();
      },
    ),
    GoRoute(
      path: '/teacher/login',
      builder: (BuildContext context, GoRouterState state) {
        return const LoginScreen();
      },
    ),
    GoRoute(
      path: '/teacher/create-session',
      builder: (BuildContext context, GoRouterState state) {
        return const CreateSessionScreen();
      },
    ),
    GoRoute(
      path: '/teacher/session/:id',
      builder: (BuildContext context, GoRouterState state) {
        final String sessionId = state.pathParameters['id']!;
        return ActiveSessionScreen(sessionId: sessionId);
      },
    ),
    GoRoute(
      path: '/student/enrollment',
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
      path: '/teacher/enrolled-students',
      builder: (BuildContext context, GoRouterState state) {
        return const EnrolledStudentsScreen();
      },
    ),
  ],
);
