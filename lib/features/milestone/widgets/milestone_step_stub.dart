/// Milestone module — the placeholder panel for a step not yet built.
///
/// Slice N5 ships only step 4 (the reader) live; steps 1/2/3/5/6 show this
/// "coming soon" panel so the bar, navigation and gating are exercised
/// end-to-end. N6–N8 replace each panel with its real activity.
library;

import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/empty_state.dart';
import '../milestone_steps.dart';
import '../styles/milestone_styles.dart';

class MilestoneStepStub extends StatelessWidget {
  const MilestoneStepStub({super.key, required this.step});

  final int step;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListView(
      padding: MilestoneStyles.stubPadding,
      children: [
        EmptyState(
          icon: milestoneStepIcon(step),
          title: milestoneStepTitle(l10n, step),
          message: l10n.milestoneStepComingSoon,
        ),
      ],
    );
  }
}
