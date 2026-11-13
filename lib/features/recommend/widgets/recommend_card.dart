/// Recommend module — one recommendation card.
///
/// Ported from `recommend/RecommendCard.tsx`: a selectable mint card (the whole
/// card and its checkbox toggle selection) with the HSK-level badge, lesson
/// title, skill / category / status row, the progress + question-count chip and
/// the recent-word focus line.
library;

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../data/models/recommended_practice.dart';
import '../styles/recommend_styles.dart';

class RecommendCard extends StatelessWidget {
  const RecommendCard({
    super.key,
    required this.rec,
    required this.selected,
    required this.onToggle,
  });

  final RecommendedPractice rec;
  final bool selected;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isExam = rec.category == 'exam';
    final skillLabel = rec.skill == 'listening'
        ? l10n.reviewListening
        : rec.skill == 'reading'
        ? l10n.reviewReading
        : null;
    final recentWords = rec.recentMatchedWords.take(6).join(', ');
    final hsk =
        RecommendStyles.hskColors[rec.level] ??
        RecommendStyles.hskColors.values.first;

    return Container(
      decoration: RecommendStyles.cardDecoration(selected: selected),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onToggle,
          child: Padding(
            padding: RecommendStyles.cardPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 22,
                      height: 22,
                      child: Checkbox(
                        value: selected,
                        onChanged: (_) => onToggle(),
                        activeColor: BrandColors.primary,
                        side: const BorderSide(
                          color: Color(0x4D576856),
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: hsk.$1,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: RecommendStyles.badgePadding,
                      child: Text(
                        'HSK ${rec.level}',
                        style: RecommendStyles.hskBadgeText.copyWith(
                          color: hsk.$2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${l10n.recommendLessonPrefix} ${rec.lesson}',
                        style: RecommendStyles.cardTitle,
                      ),
                    ),
                  ],
                ),
                RecommendStyles.cardGap,
                Wrap(
                  spacing: 10,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (skillLabel != null)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            rec.skill == 'listening'
                                ? Icons.headphones
                                : Icons.menu_book_outlined,
                            size: 14,
                            color: BrandColors.mutedText,
                          ),
                          const SizedBox(width: 5),
                          Text(skillLabel, style: RecommendStyles.skillText),
                        ],
                      ),
                    Container(
                      decoration: RecommendStyles.categoryBadge(exam: isExam),
                      padding: RecommendStyles.categoryPadding,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isExam
                                ? Icons.description_outlined
                                : Icons.checklist,
                            size: 13,
                            color: RecommendStyles.categoryText(
                              exam: isExam,
                            ).color,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            isExam ? l10n.dashboardExam : l10n.dashboardExercise,
                            style: RecommendStyles.categoryText(exam: isExam),
                          ),
                        ],
                      ),
                    ),
                    Text(_statusText(l10n), style: RecommendStyles.statusText),
                  ],
                ),
                RecommendStyles.cardGap,
                Container(
                  decoration: RecommendStyles.progressChip,
                  padding: RecommendStyles.progressChipPadding,
                  child: Text(
                    '${_progressLabel(l10n)} · ${l10n.recommendQuestionCount(rec.questionCount)}',
                    style: RecommendStyles.skillText,
                  ),
                ),
                if (recentWords.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    l10n.recommendNewFocus(recentWords),
                    style: RecommendStyles.focusText,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _statusText(AppLocalizations l10n) => switch (rec.status) {
    'Finish and success' => l10n.recommendStatusFinishSuccess,
    'Finish and fail' => l10n.recommendStatusFinishFail,
    _ => l10n.recommendStatusNotStart,
  };

  String _progressLabel(AppLocalizations l10n) {
    final p = rec.progress;
    if (p.isEmpty) return '-';
    if (p.contains('-')) {
      final parts = p.split('-');
      return l10n.recommendQuestionsRange(
        parts[0],
        parts.length > 1 ? parts[1] : '',
      );
    }
    return l10n.recommendQuestionSingle(p);
  }
}
