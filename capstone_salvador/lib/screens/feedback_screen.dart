import 'package:flutter/material.dart';

import '../models/evaluation.dart';
import '../services/feedback_repository.dart';
import '../widgets/average_rating_card.dart';
import '../widgets/rating_stars.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({
    super.key,
    required this.evaluations,
    required this.repository,
  });

  final List<Evaluation> evaluations;
  final FeedbackRepository repository;

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  late Evaluation _selected;
  late final Stream<List<RatingRecord>> _ratingsStream;
  late final Stream<List<FeedbackEntry>> _myFeedbackStream;
  int _rating = 0;
  bool _isSubmitting = false;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selected = widget.evaluations.first;
    _ratingsStream = widget.repository.watchRatings();
    _myFeedbackStream = widget.repository.watchMyFeedback();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_rating == 0) {
      _showMessage('Please select a star rating');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await widget.repository.createFeedback(
        teacherId: _selected.id,
        rating: _rating,
        comment: _commentController.text,
      );
      if (!mounted) return;
      setState(() {
        _rating = 0;
        _commentController.clear();
      });
      _showMessage('Anonymous feedback submitted');
    } catch (error) {
      if (!mounted) return;
      _showMessage('Could not submit feedback: $error');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _editFeedback(FeedbackEntry entry) async {
    final draft = await showDialog<_FeedbackDraft>(
      context: context,
      builder: (context) => _EditFeedbackDialog(entry: entry),
    );
    if (draft == null) return;

    try {
      await widget.repository.updateFeedback(
        FeedbackEntry(
          id: entry.id,
          teacherId: entry.teacherId,
          rating: draft.rating,
          comment: draft.comment,
          updatedAt: entry.updatedAt,
        ),
      );
      if (mounted) _showMessage('Feedback updated');
    } catch (error) {
      if (mounted) _showMessage('Could not update feedback: $error');
    }
  }

  Future<void> _deleteFeedback(FeedbackEntry entry) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete feedback?'),
        content: const Text('This will permanently remove your evaluation.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (shouldDelete != true) return;

    try {
      await widget.repository.deleteFeedback(entry.id);
      if (mounted) _showMessage('Feedback deleted');
    } catch (error) {
      if (mounted) _showMessage('Could not delete feedback: $error');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
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
                StreamBuilder<List<RatingRecord>>(
                  stream: _ratingsStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return _StreamError(message: snapshot.error.toString());
                    }
                    if (!snapshot.hasData) {
                      return const Card(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      );
                    }

                    final ratings = snapshot.data!
                        .where((rating) => rating.teacherId == _selected.id)
                        .toList();
                    final average = ratings.isEmpty
                        ? 0.0
                        : ratings
                                  .map((rating) => rating.rating)
                                  .reduce((a, b) => a + b) /
                              ratings.length;
                    return AverageRatingCard(
                      average: average,
                      responseCount: ratings.length,
                    );
                  },
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
                            onPressed: _isSubmitting ? null : _submit,
                            icon: _isSubmitting
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.send_outlined),
                            label: Text(
                              _isSubmitting
                                  ? 'Submitting...'
                                  : 'Submit Feedback',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _MyFeedbackSection(
                  evaluations: widget.evaluations,
                  stream: _myFeedbackStream,
                  onEdit: _editFeedback,
                  onDelete: _deleteFeedback,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MyFeedbackSection extends StatelessWidget {
  const _MyFeedbackSection({
    required this.evaluations,
    required this.stream,
    required this.onEdit,
    required this.onDelete,
  });

  final List<Evaluation> evaluations;
  final Stream<List<FeedbackEntry>> stream;
  final ValueChanged<FeedbackEntry> onEdit;
  final ValueChanged<FeedbackEntry> onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your feedback',
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            StreamBuilder<List<FeedbackEntry>>(
              stream: stream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return _StreamError(message: snapshot.error.toString());
                }
                if (!snapshot.hasData) {
                  return const LinearProgressIndicator();
                }
                if (snapshot.data!.isEmpty) {
                  return const Text('You have not submitted feedback yet.');
                }

                return Column(
                  children: snapshot.data!.map((entry) {
                    final teacher = evaluations.firstWhere(
                      (evaluation) => evaluation.id == entry.teacherId,
                      orElse: () => Evaluation(
                        id: entry.teacherId,
                        teacherName: 'Unknown teacher',
                        subject: '',
                      ),
                    );
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(teacher.teacherName),
                      subtitle: Text(
                        '${entry.rating} stars'
                        '${entry.comment.isEmpty ? '' : ' · ${entry.comment}'}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Wrap(
                        spacing: 0,
                        children: [
                          IconButton(
                            tooltip: 'Edit feedback',
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () => onEdit(entry),
                          ),
                          IconButton(
                            tooltip: 'Delete feedback',
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => onDelete(entry),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _EditFeedbackDialog extends StatefulWidget {
  const _EditFeedbackDialog({required this.entry});

  final FeedbackEntry entry;

  @override
  State<_EditFeedbackDialog> createState() => _EditFeedbackDialogState();
}

class _EditFeedbackDialogState extends State<_EditFeedbackDialog> {
  late int _rating = widget.entry.rating;
  late final TextEditingController _commentController = TextEditingController(
    text: widget.entry.comment,
  );

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit your feedback'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RatingStars(
              value: _rating,
              onChanged: (rating) => setState(() => _rating = rating),
            ),
            TextField(
              controller: _commentController,
              maxLength: 500,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Comments',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(
            context,
            _FeedbackDraft(rating: _rating, comment: _commentController.text),
          ),
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _FeedbackDraft {
  const _FeedbackDraft({required this.rating, required this.comment});

  final int rating;
  final String comment;
}

class _StreamError extends StatelessWidget {
  const _StreamError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text('Could not load Firebase data: $message'),
      ),
    );
  }
}
