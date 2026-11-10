/// Competition — the score rows shared by the live scoreboard, the waiting
/// screen and the final ranking (web `RankingList` / `renderScoreList()`).
library;

import 'package:flutter/material.dart';

import '../data/models/competition_models.dart';
import '../styles/competition_styles.dart';

class RankingList extends StatelessWidget {
  const RankingList({super.key, required this.scores});

  final List<CompetitionScore> scores;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < scores.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          Container(
            padding: CompetitionStyles.rankingRowPadding,
            decoration: CompetitionStyles.rankingRow,
            child: Row(
              children: [
                Text(
                  '#${scores[i].rank == 0 ? i + 1 : scores[i].rank}',
                  style: CompetitionStyles.rankBadge,
                ),
                CompetitionStyles.wgap12,
                Expanded(
                  child: Text(
                    scores[i].username,
                    style: CompetitionStyles.rankName,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '${scores[i].totalPoints} pts',
                  style: CompetitionStyles.rankPoints,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
