/// Practice module — the HSK-level grid shared by the Practice and Exam tabs.
///
/// Ported from `PracticeSelectPage.tsx` + `practice-select.css`: one mint
/// `.practice-card` per level (big number, "Practice/Exam N", an `HSK N` pill and
/// "Listening & Reading"), in 1 / 2 / 3 columns at <480 / ≥480 / ≥768px.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../styles/practice_styles.dart';

class PracticeLevelGrid extends StatelessWidget {
  const PracticeLevelGrid({
    super.key,
    required this.subtitle,
    required this.label,
    required this.routeBase,
  });

  /// "Choose an HSK set to begin your … session."
  final String subtitle;

  /// "Practice" / "Exam".
  final String label;

  /// `/practice` or `/exam`; levels open `<base>/<n>`.
  final String routeBase;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final columns = width >= 768 ? 3 : (width >= 480 ? 2 : 1);

    return ListView(
      padding: PracticeStyles.screenPadding,
      children: [
        Text(subtitle, style: PracticeStyles.pageSubtitle),
        PracticeStyles.gap16,
        GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 18,
          crossAxisSpacing: 18,
          childAspectRatio: columns == 1 ? 2.4 : 1.25,
          children: [
            for (var n = 1; n <= 6; n++)
              _LevelCard(
                level: n,
                label: '$label $n',
                sub: l10n.examListeningReading,
                onTap: () => context.push('$routeBase/$n'),
              ),
          ],
        ),
      ],
    );
  }
}

class _LevelCard extends StatelessWidget {
  const _LevelCard({
    required this.level,
    required this.label,
    required this.sub,
    required this.onTap,
  });

  final int level;
  final String label;
  final String sub;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: PracticeStyles.levelCardDecoration,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: PracticeStyles.levelCardPadding,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('$level', style: PracticeStyles.levelIconText),
                const SizedBox(height: 12),
                Text(label, style: PracticeStyles.levelLabel),
                const SizedBox(height: 12),
                Container(
                  decoration: PracticeStyles.levelBadgeDecoration,
                  padding: PracticeStyles.levelBadgePadding,
                  child: Text(
                    'HSK $level',
                    style: PracticeStyles.levelBadgeText,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  sub,
                  textAlign: TextAlign.center,
                  style: PracticeStyles.levelSub,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
