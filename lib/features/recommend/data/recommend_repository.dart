/// Recommend module — data access for the recommendation feed.
///
/// Ported from `getRecommendations` (`yi-chinese-manage/lib/api/learner/practice.ts`)
/// and `getVocabHasHistory` (`.../vocab.ts`). Raw JSON, login-required. Reads
/// validate via the model `fromJson` (plan rule 6).
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/validators.dart';
import 'models/recommended_practice.dart';

final recommendRepositoryProvider = Provider<RecommendRepository>((ref) {
  return RecommendRepository(ref.read(apiClientProvider));
});

class RecommendRepository {
  RecommendRepository(this._api);

  final ApiClient _api;

  /// `GET /api/practice/recommend` → `{ recommendations: [...] }`.
  Future<List<RecommendedPractice>> getRecommendations() async {
    final data = asMap(
      await _api.getRaw('/api/practice/recommend'),
      what: 'recommend',
    );
    return modelList(data, 'recommendations', RecommendedPractice.fromJson);
  }

  /// `GET /api/vocab/has_history` → `{ has_history }`. Distinguishes a brand-new
  /// learner (no vocab history) from one who has simply cleared everything.
  Future<bool> getHasHistory() async {
    final data = asMap(
      await _api.getRaw('/api/vocab/has_history'),
      what: 'has-history',
    );
    return optBool(data, 'has_history');
  }
}
