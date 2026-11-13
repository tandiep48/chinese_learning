/// Practice module — the Practice HSK-level grid (Library "Practice" tab body).
///
/// Ported from `PracticeSelectPage.tsx` with `category="practice"`; opens a
/// level's practice lessons (`/practice/:level`). Body-only so it mounts inside
/// the Library tab bar (mirrors [ExamLevelsView]).
library;

import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import 'practice_level_grid.dart';

class PracticeLevelsView extends StatelessWidget {
  const PracticeLevelsView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PracticeLevelGrid(
      subtitle: l10n.practiceChooseLevel,
      label: l10n.libraryTabPractice,
      routeBase: '/practice',
    );
  }
}
