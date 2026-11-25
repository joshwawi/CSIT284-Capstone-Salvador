import 'package:flutter/material.dart';

import '../models/evaluation.dart';
import '../services/feedback_repository.dart';

class RatingsSummaryScreen extends StatelessWidget {
  const RatingsSummaryScreen({
    super.key,
    required this.evaluations,
    required this.repository,
  });

  final List<Evaluation> evaluations;
  final FeedbackRepository repository;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Rating Summary')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: StreamBuilder<List<RatingRecord>>(
            stream: repository.watchRatings(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Could not load Firebase ratings: ${snapshot.error}',
                    ),
                  ),
                );
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final ratings = snapshot.data!;
              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                children: [
                  Text(
                    'All Teacher Ratings',
                    style: Theme.of(context).textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${evaluations.length} teachers',
                    style: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 16),
                  for (final evaluation in evaluations)
                    _TeacherRatingTile(
                      evaluation: evaluation,
                      ratings: ratings
                          .where((rating) => rating.teacherId == evaluation.id)
                          .toList(),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _TeacherRatingTile extends StatelessWidget {
  const _TeacherRatingTile({required this.evaluation, required this.ratings});

  final Evaluation evaluation;
  final List<RatingRecord> ratings;

  @override
  Widget build(BuildContext context) {
    final average = ratings.isEmpty
        ? 0.0
        : ratings.map((rating) => rating.rating).reduce((a, b) => a + b) /
              ratings.length;
    final firstName = evaluation.teacherName
        .replaceAll(RegExp(r'^(Dr\.|Prof\.|Ms\.|Mr\.|Engr\.)\s*'), '')
        .substring(0, 1);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(child: Text(firstName)),
        title: Text(evaluation.teacherName),
        subtitle: Text(evaluation.subject),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star_rounded, size: 18, color: Colors.amber),
                const SizedBox(width: 4),
                Text(
                  average.toStringAsFixed(1),
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            Text(
              '${ratings.length} responses',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
