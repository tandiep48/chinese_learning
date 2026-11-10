/// Lessons module — the Word Summary (milestone step 1).
///
/// Read-only list of the part's vocabulary cards (hanzi · pinyin · meaning),
/// ported from the read-only use of `WordSummary.tsx` (the lesson-study variant
/// with `hideActions`). Audio and stroke order are deferred to Slice R0. Data
/// from `GET /api/lesson/vocab/:id` via [passageVocabProvider]; passive — the
/// milestone's Continue completes the step.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/loading_view.dart';
import '../data/models/lesson_vocab_row.dart';
import '../providers/lesson_providers.dart';
import '../styles/lessons_styles.dart';

String learnerMeaning(BuildContext context, String vn, String en) {
  final isVi = Localizations.localeOf(context).languageCode == 'vi';
  return isVi ? (vn.isNotEmpty ? vn : en) : (en.isNotEmpty ? en : vn);
}

class WordSummaryView extends ConsumerWidget {
  const WordSummaryView({super.key, required this.passageId});

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
        return ListView.separated(
          padding: LessonsStyles.learnerListPadding,
          itemCount: rows.length,
          separatorBuilder: (_, _) => LessonsStyles.vocabCardGap,
          itemBuilder: (context, i) => _VocabCard(row: rows[i]),
        );
      },
    );
  }
}

class _VocabCard extends StatelessWidget {
  const _VocabCard({required this.row});

  final LessonVocabRow row;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: LessonsStyles.vocabCardDecoration,
      padding: LessonsStyles.vocabCardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(row.cn, style: LessonsStyles.vocabHanziStyle),
          if (row.pinyin.isNotEmpty) ...[
            LessonsStyles.vocabCardInnerGap,
            Text(row.pinyin, style: LessonsStyles.pinyinStyle),
          ],
          LessonsStyles.vocabCardInnerGap,
          Text(
            learnerMeaning(context, row.meaningVn, row.meaningEn),
            style: LessonsStyles.meaningStyle,
          ),
        ],
      ),
    );
  }
}
