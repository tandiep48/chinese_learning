/// Lessons module — the vocab flash-cards (milestone step 2).
///
/// A one-card-at-a-time flip viewer of the part's vocabulary: front shows the
/// hanzi, tap reveals pinyin + meaning; Prev/Next step through. Ported from the
/// card review of `FlashcardStudy.tsx` / `FlashcardView` (speaking practice,
/// audio and stroke order deferred to Slice R0). Data from [passageVocabProvider];
/// passive — the milestone's Continue completes the step.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/loading_view.dart';
import '../data/models/lesson_vocab_row.dart';
import '../providers/lesson_providers.dart';
import '../styles/lessons_styles.dart';
import 'card_nav.dart';
import 'word_summary_view.dart' show learnerMeaning;

class FlashcardStudyView extends ConsumerStatefulWidget {
  const FlashcardStudyView({super.key, required this.passageId});

  final String passageId;

  @override
  ConsumerState<FlashcardStudyView> createState() => _FlashcardStudyViewState();
}

class _FlashcardStudyViewState extends ConsumerState<FlashcardStudyView> {
  int _index = 0;
  bool _flipped = false;

  void _go(int to) => setState(() {
        _index = to;
        _flipped = false;
      });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final vocab = ref.watch(passageVocabProvider(widget.passageId));

    return vocab.when(
      loading: () => const LoadingView(),
      error: (_, _) => EmptyState(
        icon: Icons.cloud_off,
        title: l10n.studyError,
        action: FilledButton.tonal(
          onPressed: () => ref.invalidate(passageVocabProvider(widget.passageId)),
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
        final i = _index.clamp(0, rows.length - 1);
        final row = rows[i];
        return Column(
          children: [
            Expanded(
              child: Padding(
                padding: LessonsStyles.learnerListPadding,
                child: Center(child: _Card(row: row, flipped: _flipped, onTap: () {
                  setState(() => _flipped = !_flipped);
                })),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: CardNav(
                index: i,
                total: rows.length,
                onPrev: i > 0 ? () => _go(i - 1) : null,
                onNext: i < rows.length - 1 ? () => _go(i + 1) : null,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.row, required this.flipped, required this.onTap});

  final LessonVocabRow row;
  final bool flipped;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        constraints:
            const BoxConstraints(minHeight: LessonsStyles.flashCardMinHeight),
        decoration: LessonsStyles.flashCardDecoration,
        padding: LessonsStyles.flashCardPadding,
        alignment: Alignment.center,
        child: flipped
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (row.pinyin.isNotEmpty) ...[
                    Text(row.pinyin,
                        textAlign: TextAlign.center,
                        style: LessonsStyles.flashCardPinyinStyle),
                    LessonsStyles.flashCardGap,
                  ],
                  Text(
                    learnerMeaning(context, row.meaningVn, row.meaningEn),
                    textAlign: TextAlign.center,
                    style: LessonsStyles.flashCardMeaningStyle,
                  ),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(row.cn,
                      textAlign: TextAlign.center,
                      style: LessonsStyles.flashCardHanziStyle),
                  LessonsStyles.flashCardGap,
                  Text(l10n.flashTapToFlip,
                      style: LessonsStyles.flashCardHintStyle),
                ],
              ),
      ),
    );
  }
}
