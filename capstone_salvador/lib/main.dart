import 'package:flutter/material.dart';

import 'models/dummy_evaluations.dart';
import 'screens/feedback_screen.dart';
import 'screens/ratings_summary_screen.dart';

void main() {
  runApp(const StudentFeedbackApp());
}

class MyApp extends StudentFeedbackApp {
  const MyApp({super.key});
}

class StudentFeedbackApp extends StatelessWidget {
  const StudentFeedbackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Student Feedback',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2F6B65)),
      ), 
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  final List<Evaluation> _evaluations = buildDummyEvaluations();
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      FeedbackScreen(evaluations: _evaluations),
      RatingsSummaryScreen(evaluations: _evaluations),
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
