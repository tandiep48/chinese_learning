/// Lessons module — the HSK level grid (Library's HSK tab).
///
/// Body-only grid of HSK level cards, ported from
/// `yi-chinese-manage/app/learner/hsk/page.tsx` (`.level-picker-grid`). Each
/// card uses the level's brand tint and GCS cover image, falling back to the
/// level label when the image is unavailable. Tapping a level opens its lessons
/// (`/hsk/:level`).
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../data/models/hsk_level.dart';
import '../styles/lessons_styles.dart';

class HskLevelsView extends StatelessWidget {
  const HskLevelsView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListView(
      padding: LessonsStyles.levelGridPadding,
      children: [
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
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: LessonsStyles.levelGridSpacing,
          crossAxisSpacing: LessonsStyles.levelGridSpacing,
          childAspectRatio: LessonsStyles.levelCardAspectRatio,
          children: [
            for (final lvl in hskLevels) _LevelCard(level: lvl),
          ],
        ),
      ],
    );
  }
}

class _LevelCard extends StatelessWidget {
  const _LevelCard({required this.level});

  final HskLevel level;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: level.color,
      borderRadius: LessonsStyles.levelCardRadius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/hsk/${level.key}'),
        child: Padding(
          padding: LessonsStyles.levelCardImagePadding,
          child: Center(
            child: Image.network(
              hskImageUrl(level.level),
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => Text(
                level.label,
                style: LessonsStyles.levelLabelStyle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
