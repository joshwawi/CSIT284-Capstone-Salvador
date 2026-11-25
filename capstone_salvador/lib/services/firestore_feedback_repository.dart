import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/evaluation.dart';
import 'feedback_repository.dart';

class FirestoreFeedbackRepository implements FeedbackRepository {
  factory FirestoreFeedbackRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  }) {
    final user = auth.currentUser;
    if (user == null) {
      throw StateError('Anonymous Firebase sign-in must finish before use.');
    }
    return FirestoreFeedbackRepository._(firestore, user);
  }

  FirestoreFeedbackRepository._(this._firestore, this._user);

  final FirebaseFirestore _firestore;
  final User _user;

  CollectionReference<Map<String, dynamic>> get _feedback =>
      _firestore.collection('feedback');

  CollectionReference<Map<String, dynamic>> get _ratings =>
      _firestore.collection('ratings');

  @override
  Stream<List<RatingRecord>> watchRatings() {
    return _ratings.snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => RatingRecord.fromMap(doc.id, doc.data()))
          .toList(),
    );
  }

  @override
  Stream<List<FeedbackEntry>> watchMyFeedback() {
    return _feedback.where('ownerUid', isEqualTo: _user.uid).snapshots().map((
      snapshot,
    ) {
      final entries = snapshot.docs
          .map(
            (doc) => FeedbackEntry.fromMap(doc.id, {
              ...doc.data(),
              'updatedAt': _dateTimeOrNull(doc.data()['updatedAt']),
            }),
          )
          .toList();
      entries.sort((a, b) {
        final aDate = a.updatedAt;
        final bDate = b.updatedAt;
        if (aDate == null) return 1;
        if (bDate == null) return -1;
        return bDate.compareTo(aDate);
      });
      return entries;
    });
  }

  @override
  Future<void> createFeedback({
    required String teacherId,
    required int rating,
    required String comment,
  }) async {
    _validateInput(rating, comment);
    final feedbackRef = _feedback.doc();
    final ratingRef = _ratings.doc(feedbackRef.id);
    final batch = _firestore.batch();

    batch.set(feedbackRef, {
      'ownerUid': _user.uid,
      'teacherId': teacherId,
      'rating': rating,
      'comment': comment.trim(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    batch.set(ratingRef, {'teacherId': teacherId, 'rating': rating});
    await batch.commit();
  }

  @override
  Future<void> updateFeedback(FeedbackEntry entry) async {
    _validateInput(entry.rating, entry.comment);
    final feedbackRef = _feedback.doc(entry.id);
    final ratingRef = _ratings.doc(entry.id);
    final batch = _firestore.batch();

    batch.update(feedbackRef, {
      'rating': entry.rating,
      'comment': entry.comment.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    batch.update(ratingRef, {
      'teacherId': entry.teacherId,
      'rating': entry.rating,
    });
    await batch.commit();
  }

  @override
  Future<void> deleteFeedback(String entryId) async {
    final batch = _firestore.batch();
    batch.delete(_feedback.doc(entryId));
    batch.delete(_ratings.doc(entryId));
    await batch.commit();
  }

  DateTime? _dateTimeOrNull(Object? value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    throw const FormatException('Invalid feedback timestamp');
  }

  void _validateInput(int rating, String comment) {
    if (rating < 1 || rating > 5) {
      throw ArgumentError.value(rating, 'rating', 'Must be between 1 and 5');
    }
    if (comment.trim().length > 500) {
      throw ArgumentError.value(
        comment,
        'comment',
        'Must be at most 500 characters',
      );
    }
  }
}
