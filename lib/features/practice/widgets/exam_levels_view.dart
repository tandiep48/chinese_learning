/// Practice module — the Exam HSK-level grid (Library "Exam" tab body).
///
/// Ported from `PracticeSelectPage.tsx` with `category="exam"`: HSK 1–6 cards,
/// each opening that level's exam lessons (`/exam/:level`). Body-only so it
/// mounts inside the Library tab bar.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../styles/practice_styles.dart';

class ExamLevelsView extends StatelessWidget {
  const ExamLevelsView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListView(
      padding: PracticeStyles.screenPadding,
      children: [
        Text(l10n.examChooseLevel, style: PracticeStyles.pageSubtitle),
        PracticeStyles.gap16,
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.35,
          children: [for (var n = 1; n <= 6; n++) _levelCard(context, l10n, n)],
        ),
      ],
    );
  }

  Widget _levelCard(BuildContext context, AppLocalizations l10n, int n) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => context.push('/exam/$n'),
        child: Container(
          decoration: PracticeStyles.levelCardDecoration,
          padding: PracticeStyles.levelCardPadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: PracticeStyles.levelIconDecoration,
                child: Text('$n', style: PracticeStyles.levelIconText),
              ),
              const SizedBox(height: 8),
              Text(
                '${l10n.dashboardExam} $n',
                style: PracticeStyles.levelLabel,
              ),
              const SizedBox(height: 2),
              Text(
                'HSK $n · ${l10n.examListeningReading}',
                style: PracticeStyles.levelSub,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
