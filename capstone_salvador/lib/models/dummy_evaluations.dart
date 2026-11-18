import 'evaluation.dart';

export 'evaluation.dart';

List<Evaluation> buildDummyEvaluations() {
  return [
    Evaluation(
      teacherName: 'Dr. Ana Reyes',
      subject: 'Introduction to Computer Science',
      initialRatings: const [5, 5, 4, 5, 4, 5, 5, 4, 5, 4],
    ),
    Evaluation(
      teacherName: 'Prof. Marco Santos',
      subject: 'Data Structures',
      initialRatings: const [4, 5, 4, 4, 3, 5, 4, 4],
    ),
    Evaluation(
      teacherName: 'Ms. Leah Cruz',
      subject: 'Human-Computer Interaction',
      initialRatings: const [5, 5, 5, 4, 5, 4, 5, 4, 5],
    ),
    Evaluation(
      teacherName: 'Engr. Paolo Garcia',
      subject: 'Software Engineering',
      initialRatings: const [4, 4, 5, 4, 5, 4, 4, 5],
    ),
    Evaluation(
      teacherName: 'Dr. Maria Lopez',
      subject: 'Database Systems',
      initialRatings: const [5, 4, 4, 5, 5, 4, 5, 4, 5, 5],
    ),
    Evaluation(
      teacherName: 'Prof. Carlo Mendoza',
      subject: 'Operating Systems',
      initialRatings: const [4, 3, 4, 4, 5, 4, 3, 4, 4],
    ),
    Evaluation(
      teacherName: 'Ms. Bianca Ramos',
      subject: 'Web Development',
      initialRatings: const [5, 5, 4, 5, 5, 5, 4, 5],
    ),
    Evaluation(
      teacherName: 'Dr. Rico Villanueva',
      subject: 'Computer Networks',
      initialRatings: const [4, 4, 4, 5, 3, 4, 5, 4],
    ),
    Evaluation(
      teacherName: 'Prof. Camille Torres',
      subject: 'Mobile Application Development',
      initialRatings: const [5, 5, 5, 4, 5, 4, 5, 5, 4],
    ),
    Evaluation(
      teacherName: 'Mr. Daniel Flores',
      subject: 'Discrete Mathematics',
      initialRatings: const [4, 5, 4, 4, 4, 3, 5, 4, 4, 4],
    ),
  ];
}
