/// Lessons module — the vocab flash-cards (milestone step 2).
///
/// Loads the part's vocabulary (`GET /api/lesson/vocab/:id`) and hands it to the
/// shared [TypingCardStudy] card learner (`FlashcardView.tsx`). Passive — the
/// milestone's Next completes the step.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/media/gcs.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/loading_view.dart';
import '../providers/lesson_providers.dart';
import 'typing_card_study.dart';
import 'word_summary_view.dart' show learnerMeaning;

class FlashcardStudyView extends ConsumerWidget {
  const FlashcardStudyView({super.key, required this.passageId});

  final String passageId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final vocab = ref.watch(passageVocabProvider(passageId));

    return vocab.when(
      loading: () => const LoadingView(),
      error: (_, _) => EmptyState(
        icon: Icons.cloud_off,
        title: l10n.studyError,
        action: FilledButton.tonal(
          onPressed: () => ref.invalidate(passageVocabProvider(passageId)),
          child: Text(l10n.commonRetry),
        ),
      ),
      data: (rows) {
        if (rows.isEmpty) {
          return EmptyState(
            icon: Icons.menu_book_outlined,
            title: l10n.vocabNoWords,
          );
        }
        return TypingCardStudy(
          items: [
            for (final r in rows)
              StudyCardItem(
                text: r.cn,
                pinyin: r.pinyin,
                meaning: learnerMeaning(context, r.meaningVn, r.meaningEn),
                audioUrl: (r.audioKey ?? '').isEmpty
                    ? null
                    : vocabAudioUrl(r.audioKey!),
              ),
          ],
          placeholder: l10n.flashTypingPlaceholder,
        );
      },
    );
  }
}
