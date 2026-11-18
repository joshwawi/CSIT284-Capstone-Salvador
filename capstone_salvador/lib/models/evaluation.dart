class Evaluation {
  Evaluation({
    required this.teacherName,
    required this.subject,
    required this.initialRatings,
  }) : ratings = List<int>.from(initialRatings);

  final String teacherName;
  final String subject;
  final List<int> initialRatings;
  final List<int> ratings;

  double get average =>
      ratings.isEmpty ? 0 : ratings.reduce((a, b) => a + b) / ratings.length;
}
