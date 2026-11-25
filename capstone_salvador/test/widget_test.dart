import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:capstone_salvador/main.dart';
import 'package:capstone_salvador/models/dummy_evaluations.dart';
import 'package:capstone_salvador/models/evaluation.dart';
import 'package:capstone_salvador/services/feedback_repository.dart';

void main() {
  testWidgets('shows teacher feedback screen and Firebase average', (
    tester,
  ) async {
    final repository = MemoryFeedbackRepository();
    addTearDown(repository.dispose);
    await tester.pumpWidget(StudentFeedbackApp(repository: repository));
    await tester.pumpAndSettle();

    expect(find.text('Student Feedback'), findsOneWidget);
    expect(find.text('Teacher Evaluation'), findsOneWidget);
    expect(find.text('Dr. Ana Reyes'), findsOneWidget);
    expect(find.text('4.6'), findsOneWidget);
    expect(find.text('10 responses'), findsOneWidget);
  });

  testWidgets('requires a star rating before submitting feedback', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = MemoryFeedbackRepository();
    addTearDown(repository.dispose);
    await tester.pumpWidget(StudentFeedbackApp(repository: repository));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const Key('submit-feedback')));
    await tester.tap(find.byKey(const Key('submit-feedback')));
    await tester.pump();

    expect(find.text('Please select a star rating'), findsOneWidget);
    expect(await repository.watchMyFeedback().first, isEmpty);
  });

  testWidgets('creates feedback and updates the average', (tester) async {
    tester.view.physicalSize = const Size(800, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = MemoryFeedbackRepository();
    addTearDown(repository.dispose);
    await tester.pumpWidget(StudentFeedbackApp(repository: repository));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('rating-5')));
    await tester.enterText(find.byType(TextField), 'Great teaching!');
    await tester.ensureVisible(find.byKey(const Key('submit-feedback')));
    await tester.tap(find.byKey(const Key('submit-feedback')));
    await tester.pumpAndSettle();

    expect(find.text('11 responses'), findsOneWidget);
    final savedFeedback = (await repository.watchMyFeedback().first).single;
    expect(savedFeedback.rating, 5);
    expect(savedFeedback.comment, 'Great teaching!');
  });

  testWidgets('navigates to rating summary with ten dummy teachers', (
    tester,
  ) async {
    final repository = MemoryFeedbackRepository();
    addTearDown(repository.dispose);
    await tester.pumpWidget(StudentFeedbackApp(repository: repository));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Ratings'));
    await tester.pumpAndSettle();

    expect(find.text('Rating Summary'), findsOneWidget);
    expect(find.text('All Teacher Ratings'), findsOneWidget);
    expect(find.text('10 teachers'), findsOneWidget);
    expect(find.text('Dr. Ana Reyes'), findsOneWidget);
  });

  test(
    'repository supports creating, reading, updating, and deleting feedback',
    () async {
      final repository = MemoryFeedbackRepository();
      addTearDown(repository.dispose);

      await repository.createFeedback(
        teacherId: 'ana-reyes',
        rating: 4,
        comment: 'Clear explanations',
      );
      final created = (await repository.watchMyFeedback().first).single;
      expect(created.rating, 4);
      expect(created.comment, 'Clear explanations');
      expect((await repository.watchRatings().first).last.rating, 4);

      await repository.updateFeedback(
        FeedbackEntry(
          id: created.id,
          teacherId: created.teacherId,
          rating: 5,
          comment: 'Very clear explanations',
          updatedAt: created.updatedAt,
        ),
      );
      final updated = (await repository.watchMyFeedback().first).single;
      expect(updated.rating, 5);
      expect(updated.comment, 'Very clear explanations');

      await repository.deleteFeedback(created.id);
      expect(await repository.watchMyFeedback().first, isEmpty);
      expect(
        (await repository.watchRatings().first).where(
          (rating) => rating.id == created.id,
        ),
        isEmpty,
      );
    },
  );
}

class MemoryFeedbackRepository implements FeedbackRepository {
  MemoryFeedbackRepository()
    : _ratings = [
        for (var index = 0; index < 10; index++)
          RatingRecord(
            id: 'seed-$index',
            teacherId: 'ana-reyes',
            rating: [5, 5, 4, 5, 4, 5, 5, 4, 5, 4][index],
          ),
      ];

  final List<RatingRecord> _ratings;
  final List<FeedbackEntry> _entries = [];
  final StreamController<List<RatingRecord>> _ratingChanges =
      StreamController<List<RatingRecord>>.broadcast();
  final StreamController<List<FeedbackEntry>> _feedbackChanges =
      StreamController<List<FeedbackEntry>>.broadcast();
  int _nextId = 0;

  Stream<List<T>> _watch<T>(
    List<T> Function() current,
    StreamController<List<T>> changes,
  ) async* {
    yield current();
    yield* changes.stream;
  }

  @override
  Stream<List<RatingRecord>> watchRatings() =>
      _watch(() => List.of(_ratings), _ratingChanges);

  @override
  Stream<List<FeedbackEntry>> watchMyFeedback() =>
      _watch(() => List.of(_entries), _feedbackChanges);

  @override
  Future<void> createFeedback({
    required String teacherId,
    required int rating,
    required String comment,
  }) async {
    final entry = FeedbackEntry(
      id: 'entry-${_nextId++}',
      teacherId: teacherId,
      rating: rating,
      comment: comment.trim(),
      updatedAt: DateTime.now(),
    );
    _entries.add(entry);
    _ratings.add(
      RatingRecord(id: entry.id, teacherId: teacherId, rating: rating),
    );
    _publish();
  }

  @override
  Future<void> updateFeedback(FeedbackEntry entry) async {
    final index = _entries.indexWhere((item) => item.id == entry.id);
    if (index < 0) throw StateError('Feedback entry not found');
    _entries[index] = entry;
    final ratingIndex = _ratings.indexWhere((item) => item.id == entry.id);
    _ratings[ratingIndex] = RatingRecord(
      id: entry.id,
      teacherId: entry.teacherId,
      rating: entry.rating,
    );
    _publish();
  }

  @override
  Future<void> deleteFeedback(String entryId) async {
    _entries.removeWhere((entry) => entry.id == entryId);
    _ratings.removeWhere((rating) => rating.id == entryId);
    _publish();
  }

  void _publish() {
    _ratingChanges.add(List.of(_ratings));
    _feedbackChanges.add(List.of(_entries));
  }

  Future<void> dispose() async {
    await _ratingChanges.close();
    await _feedbackChanges.close();
  }
}
