/// Practice module — the Exam HSK-level grid (Library "Exam" tab body).
///
/// Ported from `PracticeSelectPage.tsx` with `category="exam"`; opens a level's
/// exam lessons (`/exam/:level`). Body-only so it mounts inside the Library tab
/// bar.
library;

import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import 'practice_level_grid.dart';

class ExamLevelsView extends StatelessWidget {
  const ExamLevelsView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PracticeLevelGrid(
      subtitle: l10n.examChooseLevel,
      label: l10n.dashboardExam,
      routeBase: '/exam',
    );
  }
}
