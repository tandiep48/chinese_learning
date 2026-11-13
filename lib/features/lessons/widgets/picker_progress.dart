/// Lessons module — progress bars for the lesson/part pickers.
///
/// Ported from `PickerProgress.tsx` (`ProgressLines`): a "Words learned / total"
/// bar and a "Lesson %" bar, coloured by completion. A bar renders nothing when
/// it has no total.
library;

import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../data/models/picker_progress.dart';
import '../styles/lessons_styles.dart';

class PickerProgressLines extends StatelessWidget {
  const PickerProgressLines({super.key, required this.progress});

  final PickerProgress progress;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _Bar(
          label: l10n.pickerWordsLabel,
          done: progress.learnedWords,
          total: progress.totalWords,
        ),
        _Bar(
          label: l10n.pickerLessonProgressLabel,
          done: progress.progressPct,
          total: 100,
          asPercentage: true,
        ),
      ],
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({
    required this.label,
    required this.done,
    required this.total,
    this.asPercentage = false,
  });

  final String label;
  final int done;
  final int total;
  final bool asPercentage;

  @override
  Widget build(BuildContext context) {
    if (total <= 0) return const SizedBox.shrink();
    final pct = ((done / total) * 100).round().clamp(0, 100);
    final text = asPercentage ? '$pct%' : '$done / $total';
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        children: [
          Text(label, style: LessonsStyles.progressLabelStyle),
          const SizedBox(width: 8),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: LessonsStyles.progressTrackMaxWidth,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: pct / 100,
                    minHeight: LessonsStyles.progressTrackHeight,
                    backgroundColor: LessonsStyles.progressTrackBg,
                    valueColor: AlwaysStoppedAnimation(
                      LessonsStyles.progressFill(pct),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: LessonsStyles.progressPctWidth,
            child: Text(
              text,
              textAlign: TextAlign.right,
              style: LessonsStyles.progressPctStyle,
            ),
          ),
        ],
      ),
    );
  }
}
