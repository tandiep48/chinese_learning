/// Vocab trainer — the completion/recap screen.
///
/// Ported from `VocabTrainerRecap.tsx`: a complete header with the round score,
/// then the missed words (word + pinyin + meaning) with Retry, or a perfect-round
/// state. The sticky bar carries Exit + Continue (Continue advances the milestone).
library;

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../data/trainer_word.dart';
import '../styles/vocab_trainer_styles.dart';
import 'vocab_bottom_bar.dart';

class VocabTrainerRecap extends StatelessWidget {
  const VocabTrainerRecap({
    super.key,
    required this.missed,
    required this.total,
    required this.correct,
    required this.onRetry,
    required this.onDone,
    required this.onExit,
  });

  final List<TrainerWord> missed;
  final int total;
  final int correct;
  final VoidCallback onRetry;
  final VoidCallback onDone;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isVi = Localizations.localeOf(context).languageCode == 'vi';

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: VocabTrainerStyles.recapPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.check_circle,
                  size: VocabTrainerStyles.recapIconSize,
                  color: BrandColors.success,
                ),
                VocabTrainerStyles.recapGap,
                Text(
                  l10n.vocabCompleteTitle,
                  textAlign: TextAlign.center,
                  style: VocabTrainerStyles.recapHeading,
                ),
                VocabTrainerStyles.recapSmallGap,
                Text(
                  l10n.trainerScore(correct, total),
                  textAlign: TextAlign.center,
                  style: VocabTrainerStyles.recapScore,
                ),
                VocabTrainerStyles.recapGap,
                if (missed.isEmpty)
                  Text(
                    l10n.lessonPerfect,
                    textAlign: TextAlign.center,
                    style: VocabTrainerStyles.recapMeaning,
                  )
                else ...[
                  Text(
                    l10n.lessonRecapTitle,
                    style: VocabTrainerStyles.recapSectionTitle,
                  ),
                  VocabTrainerStyles.recapGap,
                  for (var i = 0; i < missed.length; i++) ...[
                    if (i > 0) VocabTrainerStyles.recapRowGap,
                    _MissedRow(word: missed[i], isVi: isVi),
                  ],
                  VocabTrainerStyles.recapGap,
                  OutlinedButton.icon(
                    style: VocabTrainerStyles.exitButtonStyle,
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: Text(l10n.lessonRetryMissed),
                  ),
                ],
              ],
            ),
          ),
        ),
        VocabBottomBar(
          exitLabel: l10n.milestoneQuit,
          onExit: onExit,
          primaryLabel: l10n.milestoneContinue,
          onPrimary: onDone,
          confirmQuit: false,
        ),
      ],
    );
  }
}

class _MissedRow extends StatelessWidget {
  const _MissedRow({required this.word, required this.isVi});

  final TrainerWord word;
  final bool isVi;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: VocabTrainerStyles.recapRowDecoration,
      padding: VocabTrainerStyles.recapRowPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(word.word, style: VocabTrainerStyles.recapWord),
          VocabTrainerStyles.recapSmallGap,
          Text(
            '${word.pinyin} · ${word.meaning(isVi)}',
            style: VocabTrainerStyles.recapMeaning,
          ),
        ],
      ),
    );
  }
}
