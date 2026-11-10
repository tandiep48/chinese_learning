/// Lessons module — the lesson-line cards (milestone step 5).
///
/// A one-line-at-a-time review of the passage: each card shows the speaker,
/// hanzi, pinyin and translation; Prev/Next step through. Ported from
/// `LessonCardStudy.tsx` (audio deferred to Slice R0). Data from the passage
/// detail via [passageDetailProvider]; passive — the milestone's Continue
/// completes the step.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/loading_view.dart';
import '../data/models/lesson_passage.dart';
import '../providers/lesson_providers.dart';
import '../styles/lessons_styles.dart';
import 'card_nav.dart';
import 'word_summary_view.dart' show learnerMeaning;

class LessonCardStudyView extends ConsumerStatefulWidget {
  const LessonCardStudyView({super.key, required this.passageId});

  final String passageId;

  @override
  ConsumerState<LessonCardStudyView> createState() =>
      _LessonCardStudyViewState();
}

class _LessonCardStudyViewState extends ConsumerState<LessonCardStudyView> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final passage = ref.watch(passageDetailProvider(widget.passageId));

    return passage.when(
      loading: () => const LoadingView(),
      error: (_, _) => EmptyState(
        icon: Icons.cloud_off,
        title: l10n.studyError,
        action: FilledButton.tonal(
          onPressed: () =>
              ref.invalidate(passageDetailProvider(widget.passageId)),
          child: Text(l10n.commonRetry),
        ),
      ),
      data: (detail) {
        final lines = detail.lines;
        if (lines.isEmpty) {
          return EmptyState(icon: Icons.notes_outlined, title: l10n.studyEmpty);
        }
        final i = _index.clamp(0, lines.length - 1);
        return Column(
          children: [
            Expanded(
              child: Padding(
                padding: LessonsStyles.learnerListPadding,
                child: Center(child: _LineCard(line: lines[i])),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: CardNav(
                index: i,
                total: lines.length,
                onPrev: i > 0 ? () => setState(() => _index = i - 1) : null,
                onNext: i < lines.length - 1
                    ? () => setState(() => _index = i + 1)
                    : null,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _LineCard extends StatelessWidget {
  const _LineCard({required this.line});

  final LessonPassageLine line;

  @override
  Widget build(BuildContext context) {
    final meaning = learnerMeaning(
      context,
      line.translationVi ?? '',
      line.translationEn ?? '',
    );
    return Container(
      width: double.infinity,
      constraints:
          const BoxConstraints(minHeight: LessonsStyles.flashCardMinHeight),
      decoration: LessonsStyles.flashCardDecoration,
      padding: LessonsStyles.flashCardPadding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (line.speaker != null && line.speaker!.isNotEmpty) ...[
            Text(line.speaker!, style: LessonsStyles.speakerStyle),
            LessonsStyles.flashCardGap,
          ],
          Text(line.content ?? '', style: LessonsStyles.hanziPlainStyle),
          if (line.pinyin != null && line.pinyin!.isNotEmpty) ...[
            LessonsStyles.flashCardGap,
            Text(line.pinyin!, style: LessonsStyles.pinyinStyle),
          ],
          if (meaning.isNotEmpty) ...[
            LessonsStyles.flashCardGap,
            Text(meaning, style: LessonsStyles.meaningStyle),
          ],
        ],
      ),
    );
  }
}
