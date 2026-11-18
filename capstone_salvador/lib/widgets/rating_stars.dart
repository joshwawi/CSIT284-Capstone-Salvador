import 'package:flutter/material.dart';

class RatingStars extends StatelessWidget {
  const RatingStars({super.key, required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final starValue = index + 1;
        return IconButton(
          key: Key('rating-$starValue'),
          onPressed: () => onChanged(starValue),
          iconSize: 42,
          tooltip: '$starValue stars',
          icon: Icon(
            starValue <= value
                ? Icons.star_rounded
                : Icons.star_outline_rounded,
            color: starValue <= value
                ? Colors.amber.shade700
                : colorScheme.outline,
          ),
        );
      }),
    );
  }
}
