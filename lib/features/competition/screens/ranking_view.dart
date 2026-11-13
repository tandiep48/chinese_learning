/// Competition — the final ranking screen (web `RankingScreen`).
///
/// The final ranking once every player has finished (or the section timed out),
/// with the Back to Lobby button that returns the whole room.
library;

import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../providers/competition_controller.dart';
import '../styles/competition_styles.dart';
import '../widgets/ranking_list.dart';

class CompetitionRankingView extends StatelessWidget {
  const CompetitionRankingView({super.key, required this.controller});

  final CompetitionController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
      padding: CompetitionStyles.pagePadding,
      child: Container(
        padding: CompetitionStyles.panelPadding,
        decoration: CompetitionStyles.panel,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.competitionRanking, style: CompetitionStyles.h1),
            CompetitionStyles.gap16,
            RankingList(scores: controller.scores),
            CompetitionStyles.gap16,
            FilledButton(
              style: CompetitionStyles.primaryButton,
              onPressed: controller.returnToLobby,
              child: Text(l10n.competitionBackToLobby),
            ),
          ],
        ),
      ),
    );
  }
}
