/// Profile module — data access for learning statistics.
///
/// Ported from `yi-chinese-manage/lib/api/learner/{dashboard,vocab}.ts`
/// (`/api/user/*`, raw JSON, login-required). Reads validate via the model
/// `fromJson` (plan rule 6).
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/validators.dart';
import '../../../shared/data/vocab_row.dart';
import 'models/activity_day.dart';
import 'models/global_stats.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(ref.read(apiClientProvider));
});

class ProfileRepository {
  ProfileRepository(this._api);

  final ApiClient _api;

  /// `GET /api/user/global-stats`.
  Future<GlobalStats> getGlobalStats() async {
    final data = await _api.getRaw('/api/user/global-stats');
    return GlobalStats.fromJson(asMap(data, what: 'global-stats'));
  }

  /// `GET /api/user/learned-words-last-3-days` → `{ days: [...] }`.
  Future<List<LearnedWordsDay>> getLearnedWordsLast3Days() async {
    final data = asMap(
      await _api.getRaw('/api/user/learned-words-last-3-days'),
      what: 'days',
    );
    return modelList(data, 'days', LearnedWordsDay.fromJson);
  }

  /// `GET /api/user/time-learned-last-3-days` → `{ days: [...] }`.
  Future<List<TimeLearnedDay>> getTimeLearnedLast3Days() async {
    final data = asMap(
      await _api.getRaw('/api/user/time-learned-last-3-days'),
      what: 'days',
    );
    return modelList(data, 'days', TimeLearnedDay.fromJson);
  }

  /// `POST /api/user/learned-vocab/query { page, page_size }` (recent-first).
  Future<VocabPage> getLearnedVocab(int page, int pageSize) async {
    final data = await _api.postRaw(
      '/api/user/learned-vocab/query',
      body: {'page': page, 'page_size': pageSize},
    );
    return VocabPage.fromJson(asMap(data, what: 'learned-vocab'));
  }
}
