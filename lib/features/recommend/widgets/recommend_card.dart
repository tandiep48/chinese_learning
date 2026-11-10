/// Recommend module — one recommendation card.
///
/// Ported from `recommend/RecommendCard.tsx`: HSK + skill + category + status
/// badges, the progress + question-count line, the recent-word focus line, and
/// a Start button (the web toggled multi-select; mobile starts the group
/// directly).
library;

import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../data/models/recommended_practice.dart';
import '../styles/recommend_styles.dart';

class RecommendCard extends StatelessWidget {
  const RecommendCard({super.key, required this.rec, required this.onStart});

  final RecommendedPractice rec;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isExam = rec.category == 'exam';
    final skillLabel = rec.skill == 'listening'
        ? l10n.practiceListening
        : rec.skill == 'reading'
        ? l10n.practiceReading
        : null;
    final recentWords = rec.recentMatchedWords.take(6).join(', ');

    return Container(
      decoration: RecommendStyles.cardDecoration,
      padding: RecommendStyles.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                decoration: RecommendStyles.hskBadge,
                padding: RecommendStyles.badgePadding,
                child: Text(
                  'HSK ${rec.level}',
                  style: RecommendStyles.hskBadgeText,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${l10n.recommendLessonPrefix} ${rec.lesson}',
                style: RecommendStyles.cardTitle,
              ),
            ],
          ),
          RecommendStyles.gap8,
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              if (skillLabel != null)
                _badge(
                  skillLabel,
                  RecommendStyles.skillBg,
                  icon: rec.skill == 'listening'
                      ? Icons.headphones
                      : Icons.menu_book_outlined,
                ),
              _badge(
                isExam ? l10n.dashboardExam : l10n.dashboardExercise,
                isExam ? RecommendStyles.examBg : RecommendStyles.practiceBg,
                icon: isExam ? Icons.description_outlined : Icons.checklist,
              ),
              _badge(_statusText(l10n), RecommendStyles.statusBg),
            ],
          ),
          RecommendStyles.gap8,
          Text(
            '${_progressLabel(l10n)} · ${l10n.recommendQuestionCount(rec.questionCount)}',
            style: RecommendStyles.progressLabel,
          ),
          if (recentWords.isNotEmpty) ...[
            RecommendStyles.gap4,
            Text(
              l10n.recommendNewFocus(recentWords),
              style: RecommendStyles.focusLine,
            ),
          ],
          RecommendStyles.gap12,
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: RecommendStyles.startButton,
              onPressed: onStart,
              icon: const Icon(Icons.play_arrow, size: 18),
              label: Text(l10n.recommendStart),
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge(String text, Color bg, {IconData? icon}) => Container(
    decoration: RecommendStyles.metaBadge(bg),
    padding: RecommendStyles.badgePadding,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 13, color: RecommendStyles.metaText.color),
          const SizedBox(width: 4),
        ],
        Text(text, style: RecommendStyles.metaText),
      ],
    ),
  );

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
