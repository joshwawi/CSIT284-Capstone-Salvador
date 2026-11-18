# X9 Student Feedback / Evaluation Form

- **Project Title:** Student Feedback / Evaluation Form
- **Name:** [Add student name]
- **Workstation Number:** X9

## Project Description

This Flutter application lets students anonymously evaluate one seeded teacher
or event using a 1–5 star rating and optional comments. It displays the current
raw average rating and response count. The scope is limited to anonymous
student evaluations with no login or admin dashboard.

## Features

- Select from 10 dummy teacher evaluations
- Submit a star rating and optional comment
- View live average ratings and response counts
- Navigate between the evaluation form and rating summary screens
- Material 3 interface

## Project Structure

- `lib/main.dart` - app entry point and bottom navigation
- `lib/screens/` - evaluation and rating summary screens
- `lib/widgets/` - reusable rating and average widgets
- `lib/models/` - evaluation model and dummy data

## Run the Project

1. Install and configure the Flutter SDK.
2. Open this project directory.
3. Run `flutter pub get`.
4. Run `flutter run`.

For web:

```bash
flutter run -d chrome
```
