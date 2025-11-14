# Project Blueprint

## Overview

This is a Flutter application for a face recognition-based attendance system. The application allows for two user roles: Student and Teacher. Students can enroll by providing their consent, filling out a form, and capturing their facial data. Teachers can create and manage attendance sessions, view live check-ins, and generate reports.

## Style, Design, and Features

### Style

*   **Theme:** Material 3
*   **Color Scheme:** Blue-based, with both light and dark modes.
*   **Typography:** Poppins font from Google Fonts.

### Implemented Features

*   **Role Selection:** A main screen allows users to select whether they are a Student or a Teacher.
*   **Student Enrollment Flow:**
    *   A multi-step enrollment process guides students through:
        *   A welcome screen.
        *   A consent form.
        *   An enrollment form.
        *   A camera capture screen to take three photos of their face.
        *   A confirmation screen upon successful enrollment.
*   **Basic Teacher View:**
    *   A screen to display a list of all enrolled students.
*   **Navigation:** A router (`go_router`) is set up to handle navigation between all screens.
*   **State Management:** `provider` is used for theme management.

### New & Planned Features

*   **Teacher Authentication:**
    *   Login with email and password.
    *   SSO (Single Sign-On) as a future option.
*   **Teacher Session Management:**
    *   **Create Session:** Form with course name, class name, lecturer, start/end times, and geofence.
    *   **Active Session Dashboard:** Real-time view of session status, number of check-ins, and a live list of attendees.
    *   **Session Controls:** End session, refresh data, export to CSV, and manually mark attendance.
*   **Teacher Reporting:**
    *   **Reports Page:** Filterable attendance data with metrics and export options (CSV/PDF).
*   **Student Check-in Flow:**
    *   Initiate check-in by scanning a QR code or following a link.
    *   Request and handle camera and location permissions.
    *   Single face capture for verification against enrolled data.
    *   Provide real-time feedback (verifying, success, failure).
*   **Error Handling:**
    *   Guidance for low-light conditions during face capture.
    *   Graceful handling of denied location permissions.
    *   Process for ambiguous face matches.
*   **Backend Integration:**
    *   **Firebase Authentication** for user management.
    *   **Cloud Firestore** to store user data, session information, and attendance records.
    *   **Firebase AI (Gemini)** for face embedding and matching (conceptual).

## Current Plan

The immediate goal is to implement the new features as described in the UX flows. The development will be phased:

1.  **Phase 1: Teacher Authentication & Session Creation**
    *   **Integrate Firebase:** Add `firebase_core`, `firebase_auth`, and `cloud_firestore` to the project.
    *   **Initialize Firebase:** Configure the application to connect to a Firebase project.
    *   **Implement Login Screen:** Create a dedicated UI for teacher login using email and password.
    *   **Implement Authentication Logic:** Use `FirebaseAuth` to handle user sign-in.
    *   **Protect Teacher Routes:** Update the router to require authentication for all teacher-specific screens.
    *   **Create Session UI:** Build the form for teachers to create new attendance sessions.
    *   **Save Sessions:** Store the created session data in Cloud Firestore.

2.  **Phase 2: Student Check-in**
    *   Implement QR code scanning to join a session.
    *   Integrate location services to check against the session's geofence.
    *   Implement the face capture and verification logic.
    *   Record check-in data in Firestore.

3.  **Phase 3: Dashboards and Reporting**
    *   Build the real-time active session dashboard for teachers.
    *   Develop the historical reports page with filtering and export capabilities.
