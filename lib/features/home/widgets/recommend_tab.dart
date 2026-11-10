/// Home module — the dashboard's Recommend tab.
///
/// Hosts the recommend module's `RecommendView`: the `/api/practice/recommend`
/// feed, each card launching a practice session in the P2 runner. Ported from
/// the web `recommend/RecommendPage.tsx` (embedded).
library;

import 'package:flutter/material.dart';

import '../../recommend/widgets/recommend_view.dart';

class RecommendTab extends StatelessWidget {
  const RecommendTab({super.key});

  @override
  Widget build(BuildContext context) => const RecommendView();
}
