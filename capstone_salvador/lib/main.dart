import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'models/dummy_evaluations.dart';
import 'screens/feedback_screen.dart';
import 'screens/ratings_summary_screen.dart';
import 'services/feedback_repository.dart';
import 'services/firebase_options.dart';
import 'services/firestore_feedback_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AppBootstrap());
}

class AppBootstrap extends StatefulWidget {
  const AppBootstrap({super.key});

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap> {
  late final Future<FeedbackRepository> _repository = _initializeFirebase();

  Future<FeedbackRepository> _initializeFirebase() async {
    final options = FirebaseOptionsConfig.currentPlatformOptions();
    if (options == null) {
      throw StateError(
        'Firebase is not configured. Follow the Firebase setup steps in README.md.',
      );
    }

    await Firebase.initializeApp(options: options);
    final auth = FirebaseAuth.instance;
    if (auth.currentUser == null) {
      await auth.signInAnonymously();
    }
    return FirestoreFeedbackRepository(
      firestore: FirebaseFirestore.instance,
      auth: auth,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FeedbackRepository>(
      future: _repository,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return MaterialApp(
            title: 'Firebase Setup Required',
            theme: _appTheme(),
            home: _FirebaseSetupScreen(error: snapshot.error.toString()),
          );
        }
        if (!snapshot.hasData) {
          return MaterialApp(
            title: 'Student Feedback',
            theme: _appTheme(),
            home: const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }
        return StudentFeedbackApp(repository: snapshot.data!);
      },
    );
  }
}

class StudentFeedbackApp extends StatelessWidget {
  const StudentFeedbackApp({super.key, required this.repository});

  final FeedbackRepository repository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Student Feedback',
      theme: _appTheme(),
      home: MainNavigation(repository: repository),
    );
  }
}

ThemeData _appTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2F6B65)),
  );
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key, required this.repository});

  final FeedbackRepository repository;

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  final List<Evaluation> _evaluations = buildDummyEvaluations();
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      FeedbackScreen(evaluations: _evaluations, repository: widget.repository),
      RatingsSummaryScreen(
        evaluations: _evaluations,
        repository: widget.repository,
      ),
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.edit_outlined),
            selectedIcon: Icon(Icons.edit),
            label: 'Evaluate',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Ratings',
          ),
        ],
      ),
    );
  }
}

class _FirebaseSetupScreen extends StatelessWidget {
  const _FirebaseSetupScreen({required this.error});

  final String error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Firebase setup required')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            padding: const EdgeInsets.all(24),
            shrinkWrap: true,
            children: [
              const Icon(Icons.cloud_off_outlined, size: 56),
              const SizedBox(height: 16),
              Text(error, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              const Text(
                'Create a Firebase project, enable Anonymous sign-in and '
                'Cloud Firestore, deploy firestore.rules, then run the app '
                'with the Firebase --dart-define values listed in README.md.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
