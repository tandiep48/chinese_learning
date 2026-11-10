/// Profile module — the learning-statistics block.
///
/// Ported from `profile/LearningStatistics.tsx`: two headline figures, the two
/// three-day charts, and a per-activity breakdown (questions answered + time).
library;

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../data/models/activity_day.dart';
import '../data/models/global_stats.dart';
import '../styles/profile_styles.dart';
import 'mini_bar_chart.dart';

class LearningStatistics extends StatelessWidget {
  const LearningStatistics({
    super.key,
    required this.stats,
    required this.wordsDays,
    required this.timeDays,
  });

  final GlobalStats stats;
  final List<LearnedWordsDay> wordsDays;
  final List<TimeLearnedDay> timeDays;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: _headline(
                l10n.dashboardTotalTime.toUpperCase(),
                stats.totalTimeLabel,
              ),
            ),
            Container(width: 1, height: 44, color: BrandColors.neutralBorder),
            Expanded(
              child: _headline(
                l10n.dashboardWordsMastered.toUpperCase(),
                '${stats.totalWords}',
              ),
            ),
          ],
        ),
        ProfileStyles.gap24,
        _chartCard(
          l10n.dashboardTimeLearned3days,
          l10n,
          timeValues: timeDays.map((d) => d.minutes).toList(),
          labels: timeDays.map((d) => formatChartDate(d.date)).toList(),
          suffix: 'm',
        ),
        ProfileStyles.gap16,
        _chartCard(
          l10n.dashboardWordsMastered3days,
          l10n,
          timeValues: wordsDays.map((d) => d.count).toList(),
          labels: wordsDays.map((d) => formatChartDate(d.date)).toList(),
        ),
        ProfileStyles.gap24,
        Row(
          children: [
            Expanded(child: _subStat(l10n.dashboardExercise, stats.exercise)),
            const SizedBox(width: 12),
            Expanded(child: _subStat(l10n.dashboardExam, stats.exam)),
          ],
        ),
        ProfileStyles.gap12,
        Row(
          children: [
            Expanded(
              child: _subStat(l10n.dashboardLessonTrainer, stats.lessonTrainer),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _subStat(l10n.dashboardVocabTrainer, stats.vocabTrainer),
            ),
          ],
        ),
      ],
    );
  }

  Widget _headline(String label, String value) => Column(
    children: [
      Text(label, style: ProfileStyles.statLabel, textAlign: TextAlign.center),
      ProfileStyles.gap8,
      Text(value, style: ProfileStyles.statValue),
    ],
  );

  Widget _chartCard(
    String title,
    AppLocalizations l10n, {
    required List<int> timeValues,
    required List<String> labels,
    String suffix = '',
  }) {
    return Container(
      decoration: ProfileStyles.cardDecoration,
      padding: ProfileStyles.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: ProfileStyles.chartTitleStyle),
          ProfileStyles.gap12,
          if (timeValues.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                l10n.dashboardNoChartData,
                style: ProfileStyles.noDataStyle,
              ),
            )
          else
            MiniBarChart(values: timeValues, labels: labels, suffix: suffix),
        ],
      ),
    );
  }

  Widget _subStat(String label, GlobalStatsBucket bucket) {
    return Container(
      decoration: ProfileStyles.subStatDecoration,
      padding: ProfileStyles.subStatPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: ProfileStyles.subStatLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          ProfileStyles.gap8,
          Text('${bucket.questions}', style: ProfileStyles.subStatValue),
          Text(bucket.timeLabel, style: ProfileStyles.subStatTime),
        ],
      ),
    );
  }
}
