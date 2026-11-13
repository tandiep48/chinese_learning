/// Review module — data access for the saved-word review lists.
///
/// Ported from `yi-chinese-manage/lib/api/learner/vocab.ts`
/// (`getVocabReview` / `getReviewRecent` / `getVocabReviewCount`). The Review
/// tab is **watch-only** — it reads the two priority-ordered word lists and the
/// due count; there is no submit here. Reads validate via the shared `VocabPage`
/// (plan rule 6).
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/validators.dart';
import '../../../shared/data/vocab_row.dart';

/// Server caps each list at 100 words; the UI pages 50 at a time (≤ 2 pages).
const int reviewPageSize = 50;

final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  return ReviewRepository(ref.read(apiClientProvider));
});

/// How many words are waiting in the review list (the Review tab badge).
final reviewCountProvider = FutureProvider<int>((ref) {
  return ref.read(reviewRepositoryProvider).getReviewCount();
});

class ReviewRepository {
  ReviewRepository(this._api);

  final ApiClient _api;

  /// `POST /api/vocab/review/query` — critical ∪ unsure ∪ incomplete, by priority.
  Future<VocabPage> getReviewList(int page, int pageSize) async {
    final data = await _api.postRaw(
      '/api/vocab/review/query',
      body: {'page': page, 'page_size': pageSize},
    );
    return VocabPage.fromJson(asMap(data, what: 'review'));
  }

  /// `POST /api/vocab/review-recent/query` — most recently mastered words.
  Future<VocabPage> getRecentList(int page, int pageSize) async {
    final data = await _api.postRaw(
      '/api/vocab/review-recent/query',
      body: {'page': page, 'page_size': pageSize},
    );
    return VocabPage.fromJson(asMap(data, what: 'review-recent'));
  }

  /// `GET /api/vocab/review/count` → `{ total }`.
  Future<int> getReviewCount() async {
    final data = asMap(
      await _api.getRaw('/api/vocab/review/count'),
      what: 'review-count',
    );
    return optInt(data, 'total') ?? 0;
  }
}
