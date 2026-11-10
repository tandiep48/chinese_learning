/// Lesson trainer — the completion/recap screen.
///
/// Ported from `LessonTrainerRecap.tsx`: a "Lesson Complete" header with the
/// round score, then either a list of missed tasks (type / question / your
/// answer / correct answer) with Retry, or a perfect-round state. The sticky bar
/// carries Exit + Continue (Continue advances the milestone). The web's
/// "back to menu" link is hidden inside the milestone.
library;

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../data/missed_task.dart';
import '../styles/lesson_trainer_styles.dart';
import 'trainer_bottom_bar.dart';

class LessonTrainerRecap extends StatelessWidget {
  const LessonTrainerRecap({
    super.key,
    required this.missed,
    required this.total,
    required this.correct,
    required this.onRetry,
    required this.onDone,
    required this.onExit,
  });

  final List<MissedTask> missed;
  final int total;
  final int correct;
  final VoidCallback onRetry;
  final VoidCallback onDone;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: LessonTrainerStyles.recapPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.check_circle,
                  size: LessonTrainerStyles.recapIconSize,
                  color: BrandColors.success,
                ),
                LessonTrainerStyles.recapGap,
                Text(l10n.lessonCompleteTitle,
                    textAlign: TextAlign.center,
                    style: LessonTrainerStyles.recapHeading),
                LessonTrainerStyles.recapSmallGap,
                Text(l10n.lessonCompleteBody,
                    textAlign: TextAlign.center,
                    style: LessonTrainerStyles.recapBody),
                LessonTrainerStyles.recapSmallGap,
                Text(l10n.trainerScore(correct, total),
                    textAlign: TextAlign.center,
                    style: LessonTrainerStyles.recapScore),
                LessonTrainerStyles.recapGap,
                if (missed.isEmpty)
                  Text(l10n.lessonPerfect,
                      textAlign: TextAlign.center,
                      style: LessonTrainerStyles.recapBody)
                else ...[
                  Text(l10n.lessonRecapTitle,
                      style: LessonTrainerStyles.recapSectionTitle),
                  LessonTrainerStyles.recapGap,
                  for (var i = 0; i < missed.length; i++) ...[
                    if (i > 0) LessonTrainerStyles.recapRowGap,
                    _MissedRow(missed: missed[i]),
                  ],
                  LessonTrainerStyles.recapGap,
                  OutlinedButton.icon(
                    style: LessonTrainerStyles.exitButtonStyle,
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: Text(l10n.lessonRetryMissed),
                  ),
                ],
              ],
            ),
          ),
        ),
        TrainerBottomBar(
          exitLabel: l10n.milestoneQuit,
          onExit: onExit,
          primaryLabel: l10n.milestoneContinue,
          onPrimary: onDone,
        ),
      ],
    );
  }
}

class _MissedRow extends StatelessWidget {
  const _MissedRow({required this.missed});

  final MissedTask missed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final question = missed.task.content.isNotEmpty
        ? missed.task.content
        : missed.task.type;

    return Container(
      decoration: LessonTrainerStyles.recapRowDecoration,
      padding: LessonTrainerStyles.recapRowPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question, style: LessonTrainerStyles.recapQuestion),
          LessonTrainerStyles.recapSmallGap,
          Text('${l10n.lessonTableYourAnswer}: ${missed.userAnswer}',
              style: LessonTrainerStyles.recapYourAnswer),
          Text('${l10n.lessonTableCorrectAnswer}: ${missed.task.correctAnswer}',
              style: LessonTrainerStyles.recapCorrectAnswer),
        ],
      ),
    );
  }
}
