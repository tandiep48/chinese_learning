/// Lessons module — the lesson-line cards (milestone step 5).
///
/// Loads the passage (`GET /api/lesson/passage/:id`) and hands its lines to the
/// shared [TypingCardStudy] card learner (`LessonCardStudy.tsx`): one sentence at
/// a time with a typing self-check and its line audio. Passive — the milestone's
/// Next completes the step.
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

class LessonCardStudyView extends ConsumerWidget {
  const LessonCardStudyView({super.key, required this.passageId});

  final String passageId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final passage = ref.watch(passageDetailProvider(passageId));

    return passage.when(
      loading: () => const LoadingView(),
      error: (_, _) => EmptyState(
        icon: Icons.cloud_off,
        title: l10n.studyError,
        action: FilledButton.tonal(
          onPressed: () => ref.invalidate(passageDetailProvider(passageId)),
          child: Text(l10n.commonRetry),
        ),
      ),
      data: (detail) {
        if (detail.lines.isEmpty) {
          return EmptyState(icon: Icons.notes_outlined, title: l10n.studyEmpty);
        }
        final folder = lessonAudioFolder(
          hskLevel: detail.hskLevel,
          bookCode: detail.bookCode,
        );
        return TypingCardStudy(
          isSentence: true,
          items: [
            for (final line in detail.lines)
              StudyCardItem(
                text: line.content ?? '',
                pinyin: line.pinyin ?? '',
                meaning: learnerMeaning(
                  context,
                  line.translationVi ?? '',
                  line.translationEn ?? '',
                ),
                audioUrl: (line.audioKey ?? '').isEmpty
                    ? null
                    : lessonAudioUrl(folder, line.audioKey!),
              ),
          ],
          placeholder: l10n.lessonCardTypingPlaceholder,
        );
      },
    );
  }
}
