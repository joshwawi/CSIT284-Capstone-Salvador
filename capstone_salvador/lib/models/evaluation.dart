class Evaluation {
  const Evaluation({
    required this.id,
    required this.teacherName,
    required this.subject,
  });

  final String id;
  final String teacherName;
  final String subject;
}

class RatingRecord {
  const RatingRecord({
    required this.id,
    required this.teacherId,
    required this.rating,
  });

  final String id;
  final String teacherId;
  final int rating;

  factory RatingRecord.fromMap(String id, Map<String, dynamic> data) {
    final teacherId = data['teacherId'];
    final rating = data['rating'];
    if (teacherId is! String || rating is! int || rating < 1 || rating > 5) {
      throw FormatException('Invalid rating record: $id');
    }

    return RatingRecord(id: id, teacherId: teacherId, rating: rating);
  }
}

class FeedbackEntry {
  const FeedbackEntry({
    required this.id,
    required this.teacherId,
    required this.rating,
    required this.comment,
    required this.updatedAt,
  });

  final String id;
  final String teacherId;
  final int rating;
  final String comment;
  final DateTime? updatedAt;

  factory FeedbackEntry.fromMap(String id, Map<String, dynamic> data) {
    final teacherId = data['teacherId'];
    final rating = data['rating'];
    final comment = data['comment'];
    final updatedAt = data['updatedAt'];
    if (teacherId is! String ||
        rating is! int ||
        rating < 1 ||
        rating > 5 ||
        comment is! String ||
        (updatedAt != null && updatedAt is! DateTime)) {
      throw FormatException('Invalid feedback record: $id');
    }

    return FeedbackEntry(
      id: id,
      teacherId: teacherId,
      rating: rating,
      comment: comment,
      updatedAt: updatedAt as DateTime?,
    );
  }
}
