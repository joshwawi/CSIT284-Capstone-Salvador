import 'package:flutter/material.dart';

class AverageRatingCard extends StatelessWidget {
  const AverageRatingCard({
    super.key,
    required this.average,
    required this.responseCount,
  });

  final double average;
  final int responseCount;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      color: colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Average Rating',
                    style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(color: colorScheme.onPrimaryContainer),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        average.toStringAsFixed(1),
                        key: const Key('average-rating'),
                        style: Theme.of(context).textTheme.displaySmall
                            ?.copyWith(
                              color: colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 8),
                        child: Text(
                          '/ 5',
                          style: TextStyle(
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: List.generate(5, (index) {
                    final filled = index < average.round();
                    return Icon(
                      filled ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: filled
                          ? Colors.amber.shade700
                          : colorScheme.onPrimaryContainer.withValues(
                              alpha: 0.45,
                            ),
                      size: 22,
                    );
                  }),
                ),
                const SizedBox(height: 6),
                Text(
                  '$responseCount responses',
                  key: const Key('response-count'),
                  style: TextStyle(color: colorScheme.onPrimaryContainer),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
