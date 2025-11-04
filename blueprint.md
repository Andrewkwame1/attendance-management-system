# Project Blueprint

## Overview

This is a Flutter application for a face recognition-based attendance system. The application allows for two user roles: Student and Teacher. Students can enroll by providing their consent, filling out a form, and capturing their facial data. Teachers can view a list of enrolled students.

## Style, Design, and Features

### Style

*   **Theme:** Material 3
*   **Color Scheme:** Blue-based, with both light and dark modes.
*   **Typography:** Poppins font from Google Fonts.

### Features

*   **Role Selection:** A main screen allows users to select whether they are a Student or a Teacher.
*   **Student Flow:**
    *   **Enrollment:** A multi-step enrollment process guides students through:
        *   A welcome screen.
        *   A consent form.
        *   An enrollment form.
        *   A camera capture screen to take three photos of their face.
        *   A confirmation screen upon successful enrollment.
*   **Teacher Flow:**
    *   **Enrolled Students:** A screen to display a list of all enrolled students.
*   **Navigation:** A router (`go_router`) is set up to handle navigation between all screens.
*   **State Management:** `provider` is used for theme management.

## Current Plan

*   Run the application in the web preview.
