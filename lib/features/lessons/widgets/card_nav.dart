/// Lessons module — Prev / counter / Next row for the card viewers (flash cards
/// and lesson-line cards). A null handler disables that arrow.
library;

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../styles/lessons_styles.dart';

class CardNav extends StatelessWidget {
  const CardNav({
    super.key,
    required this.index,
    required this.total,
    required this.onPrev,
    required this.onNext,
  });

  final int index;
  final int total;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onPrev,
          icon: const Icon(Icons.chevron_left),
          color: BrandColors.primary,
        ),
        Expanded(
          child: Text(
            '${index + 1} / $total',
            textAlign: TextAlign.center,
            style: LessonsStyles.cardCounterStyle,
          ),
        ),
        IconButton(
          onPressed: onNext,
          icon: const Icon(Icons.chevron_right),
          color: BrandColors.primary,
        ),
      ],
    );
  }
}
