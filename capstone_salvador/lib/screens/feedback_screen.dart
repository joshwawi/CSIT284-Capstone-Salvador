import 'package:flutter/material.dart';

import '../models/evaluation.dart';
import '../widgets/average_rating_card.dart';
import '../widgets/rating_stars.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key, required this.evaluations});

  final List<Evaluation> evaluations;

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  late Evaluation _selected;
  int _rating = 0;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selected = widget.evaluations.first;
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a star rating')),
      );
      return;
    }

    setState(() {
      _selected.ratings.add(_rating);
      _rating = 0;
      _commentController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Feedback submitted for ${_selected.teacherName}'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Student Feedback')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              children: [
                Text(
                  'Teacher Evaluation',
                  style: Theme.of(context).textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  'Share your anonymous feedback',
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 20),
                AverageRatingCard(
                  average: _selected.average,
                  responseCount: _selected.ratings.length,
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Evaluate a teacher',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<Evaluation>(
                          initialValue: _selected,
                          decoration: const InputDecoration(
                            labelText: 'Teacher',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          items: widget.evaluations
                              .map(
                                (evaluation) => DropdownMenuItem(
                                  value: evaluation,
                                  child: Text(evaluation.teacherName),
                                ),
                              )
                              .toList(),
                          onChanged: (evaluation) {
                            if (evaluation == null) return;
                            setState(() {
                              _selected = evaluation;
                              _rating = 0;
                              _commentController.clear();
                            });
                          },
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _selected.subject,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Your rating',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        RatingStars(
                          value: _rating,
                          onChanged: (value) {
                            setState(() => _rating = value);
                          },
                        ),
                        Text(
                          _rating == 0
                              ? 'Select 1 to 5 stars'
                              : '$_rating out of 5',
                          key: const Key('selected-rating'),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _commentController,
                          minLines: 4,
                          maxLines: 6,
                          maxLength: 500,
                          textInputAction: TextInputAction.done,
                          decoration: const InputDecoration(
                            labelText: 'Comments',
                            hintText: 'What went well? What could improve?',
                            alignLabelWithHint: true,
                            border: OutlineInputBorder(),
                            prefixIcon: Padding(
                              padding: EdgeInsets.only(bottom: 56),
                              child: Icon(Icons.chat_bubble_outline),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.lock_outline,
                              size: 18,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Anonymous submission',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: FilledButton.icon(
                            key: const Key('submit-feedback'),
                            onPressed: _submit,
                            icon: const Icon(Icons.send_outlined),
                            label: const Text('Submit Feedback'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
