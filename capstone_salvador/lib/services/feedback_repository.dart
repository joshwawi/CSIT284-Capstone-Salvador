import '../models/evaluation.dart';

abstract interface class FeedbackRepository {
  Stream<List<RatingRecord>> watchRatings();

  Stream<List<FeedbackEntry>> watchMyFeedback();

  Future<void> createFeedback({
    required String teacherId,
    required int rating,
    required String comment,
  });

  Future<void> updateFeedback(FeedbackEntry entry);

  Future<void> deleteFeedback(String entryId);
}
