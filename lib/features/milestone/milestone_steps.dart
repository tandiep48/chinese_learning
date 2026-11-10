/// Milestone module — the step → title / icon lookup, shared by the bar and the
/// step panels. Titles mirror `STEP_TITLE_KEYS` in
/// `yi-chinese-manage/components/page/learner/milestone/MilestoneBar.tsx`.
library;

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

String milestoneStepTitle(AppLocalizations l10n, int step) {
  switch (step) {
    case 1:
      return l10n.milestoneStepVocabSummary;
    case 2:
      return l10n.milestoneStepVocabLearner;
    case 3:
      return l10n.milestoneStepVocabTrainer;
    case 4:
      return l10n.milestoneStepLessonSummary;
    case 5:
      return l10n.milestoneStepLessonLearner;
    case 6:
      return l10n.milestoneStepLessonTrainer;
    default:
      return '';
  }
}

IconData milestoneStepIcon(int step) {
  switch (step) {
    case 1:
      return Icons.list_alt_outlined;
    case 2:
      return Icons.style_outlined;
    case 3:
      return Icons.quiz_outlined;
    case 4:
      return Icons.menu_book_outlined;
    case 5:
      return Icons.view_agenda_outlined;
    case 6:
      return Icons.fact_check_outlined;
    default:
      return Icons.circle_outlined;
  }
}
