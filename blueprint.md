# Class Attendance App Blueprint

## Overview

This document outlines the blueprint for a Flutter-based Class Attendance App. The app provides a platform for teachers to create and manage class sessions, and for students to check in to those sessions using facial recognition and location-based validation.

## Style, Design, and Features

### Implemented

*   **User Roles:** The app supports two user roles: "Teacher" and "Student".
*   **Authentication:** Users can sign up and log in using Firebase Authentication.
*   **Teacher Features:**
    *   **Create Sessions:** Teachers can create new class sessions with details such as course name, class name, start time, end time, and location.
    *   **View Sessions:** Teachers can view a list of their active, upcoming, and past sessions on their dashboard.
    *   **Search Sessions:** Teachers can search for sessions by course or class name.
    *   **Session Details:** Teachers can view the details of a specific session, including a real-time list of students who have checked in.
    *   **CSV Export:** Teachers can export the attendance list of a session to a CSV file.
*   **Student Features:**
    *   **Facial Enrollment:** Students can enroll their face by taking three pictures.
    *   **View Available Sessions:** Students can view a list of available class sessions and check in.
    *   **Profile Screen:** Students can view their profile information and their complete attendance history.
*   **Notifications:** Students receive a notification 15 minutes before a class session starts.
*   **UI/UX:**
    *   **Navigation:** The app uses `go_router` for navigation.
    *   **Theming:** The app uses a consistent theme with a primary color of deep purple.
    *   **Modern UI:** The student and teacher home screens have been redesigned with a modern and visually appealing UI, featuring card-based layouts, gradients, shadows, and custom fonts for a better user experience.

### Plan for Current Request

*   No active plan. Ready for the next request.
