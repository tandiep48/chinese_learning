/// Recommend module — pure filtering / paging / selection helpers.
///
/// Ported from `lib/recommend/recommendLogic.ts`.
library;

import 'models/recommended_practice.dart';

const int recommendPageSize = 10;

/// Stable identity of a recommendation (`category|level|lesson|progress`).
String recommendationKey(RecommendedPractice r) =>
    '${r.category.isEmpty ? 'practice' : r.category}|${r.level}|${r.lesson}|${r.progress}';

List<RecommendedPractice> filterRecommendations(
  List<RecommendedPractice> recs, {
  required String level,
  required String skill,
  required String category,
  required String status,
}) {
  return [
    for (final r in recs)
      if ((level == 'all' || '${r.level}' == level) &&
          (skill == 'all' || r.skill == skill) &&
          (category == 'all' || r.category == category) &&
          (status == 'all' ||
              (r.status.isEmpty ? 'Not start' : r.status) == status))
        r,
  ];
}

int totalPages(int totalItems) =>
    totalItems <= 0 ? 1 : (totalItems / recommendPageSize).ceil();

/// Up to 7 page buttons with `null` (ellipsis) gaps for longer ranges.
List<int?> pageNumbers(int current, int total) {
  if (total <= 7) return [for (var i = 1; i <= total; i++) i];
  if (current <= 4) return [1, 2, 3, 4, 5, null, total];
  if (current >= total - 3) {
    return [1, null, total - 4, total - 3, total - 2, total - 1, total];
  }
  return [1, null, current - 1, current, current + 1, null, total];
}
