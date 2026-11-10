/// Competition — the waiting screen (web `WaitingScreen`).
///
/// Shown after this player finishes, while the others are still playing. The
/// subtitle lists whoever has finished so far and the scoreboard keeps updating.
library;

import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../providers/competition_controller.dart';
import '../styles/competition_styles.dart';
import '../widgets/ranking_list.dart';

class CompetitionWaitingView extends StatelessWidget {
  const CompetitionWaitingView({super.key, required this.controller});

  final CompetitionController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final subtitle = controller.waitingUsers.isNotEmpty
        ? l10n.competitionFinishedList(controller.waitingUsers.join(', '))
        : l10n.competitionWaitingOthers;

    return SingleChildScrollView(
      padding: CompetitionStyles.pagePadding,
      child: Container(
        padding: CompetitionStyles.panelPadding,
        decoration: CompetitionStyles.panel,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.competitionYouFinished, style: CompetitionStyles.h1),
            const SizedBox(height: 6),
            Text(subtitle, style: CompetitionStyles.subtitle),
            CompetitionStyles.gap16,
            RankingList(scores: controller.scores),
          ],
        ),
      ),
    );
  }
}
