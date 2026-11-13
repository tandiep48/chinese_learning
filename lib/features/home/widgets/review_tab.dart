/// Home module — the dashboard's Review tab.
///
/// Hosts the review module's watch-only word browser (`ReviewView`): two tabs
/// (Recent / Review) over `/api/vocab/{review-recent,review}/query`. Ported from
/// the web `vocab-review/VocabReviewPage.tsx` (embedded).
library;

import 'package:flutter/material.dart';

import '../../review/widgets/review_view.dart';

class ReviewTab extends StatelessWidget {
  const ReviewTab({super.key});

  @override
  Widget build(BuildContext context) => const ReviewView();
}
