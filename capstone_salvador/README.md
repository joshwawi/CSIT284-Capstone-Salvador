# X9 Student Feedback / Evaluation Form

- **Project Title:** Student Feedback / Evaluation Form
- **Name:** Joshua Alberto P. Salvador
- **Workstation Number:** 29

## Project Description

Students can anonymously rate one of 10 seeded teachers, leave an optional
comment, view live average ratings, and manage their own submissions. Firebase
Anonymous Authentication works in the background so students do not need to
create an account. Comments are only readable by the anonymous user who
submitted them; public rating data contains no comments or user IDs.

## Firebase Features

- **Create:** Submit a rating and optional comment.
- **Read:** Display live aggregate ratings; read your own feedback.
- **Update:** Edit your own rating and comment.
- **Delete:** Delete your own feedback.
- Firestore security rules protect feedback ownership and validate rating data.

## Project Structure

- `lib/main.dart` - app startup and bottom navigation
- `lib/screens/` - evaluation and ratings summary screens
- `lib/widgets/` - reusable rating and average widgets
- `lib/models/` - evaluation and feedback models, seeded teacher list
- `lib/services/` - Firebase setup and Firestore repository
- `firestore.rules` - Firestore access and data validation rules

## Firebase Setup

1. Create a Firebase project in the [Firebase Console](https://console.firebase.google.com/).
2. In **Authentication → Sign-in method**, enable **Anonymous**.
3. Create a **Cloud Firestore** database.
4. Register your Web and/or Android app in Firebase project settings. Copy the
   Web app's **API key**, **App ID**, and **Auth domain**; for Android, copy its
   **App ID**. Also note the project's **Project ID** and **Messaging sender
   ID**.
5. Install and log in to the Firebase CLI, then from this project directory run:

   ```powershell
   firebase login
   firebase use --add
   firebase deploy --only firestore:rules
   ```

6. Pass your Firebase values as compile-time defines when starting Flutter.
   Replace the placeholders with values from Firebase Project settings:

   ```powershell
   flutter run -d chrome `
     --dart-define=FIREBASE_API_KEY=your-api-key `
     --dart-define=FIREBASE_PROJECT_ID=your-project-id `
     --dart-define=FIREBASE_MESSAGING_SENDER_ID=your-sender-id `
     --dart-define=FIREBASE_WEB_APP_ID=your-web-app-id `
     --dart-define=FIREBASE_AUTH_DOMAIN=your-project-id.firebaseapp.com
   ```

   For Android, use `flutter run` and provide
   `--dart-define=FIREBASE_ANDROID_APP_ID=your-android-app-id` instead of the
   Web app ID and auth domain. Keep the Firebase project values out of source
   control.

## Run and Test

```powershell
flutter pub get
flutter run
flutter test
flutter analyze
```
