/// Lessons module — the HSK level grid (Library's HSK tab).
///
/// Body-only grid of HSK level cards, ported from
/// `yi-chinese-manage/app/learner/hsk/page.tsx` (`.level-picker-grid`). Each
/// card uses the level's brand tint and GCS cover image, falling back to the
/// level label when the image is unavailable. Grid is 3 columns, 2 at ≤700px and
/// 1 at ≤440px; the Continue panel sits above it. Tapping a level opens its
/// lessons (`/hsk/:level`).
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../home/widgets/recent_lesson_panel.dart';
import '../data/models/hsk_level.dart';
import '../styles/lessons_styles.dart';

class HskLevelsView extends StatelessWidget {
  const HskLevelsView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return LayoutBuilder(
      builder: (context, box) {
        final columns = LessonsStyles.levelGridColumns(box.maxWidth);
        final contentWidth =
            box.maxWidth - LessonsStyles.levelGridPadding.horizontal;
        final cardWidth =
            (contentWidth - LessonsStyles.levelGridGap * (columns - 1)) /
            columns;
        final iconSize = math.min(
          LessonsStyles.levelIconMax,
          (cardWidth - LessonsStyles.levelCardPadding.horizontal) *
              LessonsStyles.levelIconFraction,
        );
        final cardHeight = math.max(
          LessonsStyles.levelCardMinHeight,
          iconSize + LessonsStyles.levelCardPadding.vertical,
        );

        return ListView(
          padding: LessonsStyles.levelGridPadding,
          children: [
            const RecentLessonPanelLoader(),
            Text(
              l10n.hskSelectLevelTitle,
              style: LessonsStyles.pickerTitleStyle,
              textAlign: TextAlign.center,
            ),
            LessonsStyles.pickerTitleGap,
            Text(
              l10n.hskSelectLevelSubtitle,
              style: LessonsStyles.pickerSubtitleStyle,
              textAlign: TextAlign.center,
            ),
            LessonsStyles.pickerHeaderGap,
            GridView.count(
              crossAxisCount: columns,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: LessonsStyles.levelGridGap,
              crossAxisSpacing: LessonsStyles.levelGridGap,
              childAspectRatio: cardWidth / cardHeight,
              children: [
                for (final lvl in hskLevels)
                  _LevelCard(level: lvl, iconSize: iconSize),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _LevelCard extends StatelessWidget {
  const _LevelCard({required this.level, required this.iconSize});

  final HskLevel level;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: level.color,
      borderRadius: LessonsStyles.levelCardRadius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/hsk/${level.key}'),
        child: Padding(
          padding: LessonsStyles.levelCardPadding,
          child: Center(
            child: SizedBox(
              width: iconSize,
              height: iconSize,
              child: Image.network(
                hskImageUrl(level.level),
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => Center(
                  child: Text(
                    level.label,
                    style: LessonsStyles.levelLabelStyle,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
