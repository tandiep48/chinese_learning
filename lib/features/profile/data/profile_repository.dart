/// Profile module — data access for learning statistics.
///
/// Ported from `yi-chinese-manage/lib/api/learner/{dashboard,vocab}.ts`
/// (`/api/user/*`, raw JSON, login-required). Reads validate via the model
/// `fromJson` (plan rule 6).
library;

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/validators.dart';
import '../../auth/data/models/auth_user.dart';
import 'models/activity_day.dart';
import 'models/global_stats.dart';
import 'models/review_models.dart';

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

  /// `GET /api/user/profile-summary` — the user with avatar and HSK level
  /// recomputed server-side (the other summary stats are not used).
  Future<AuthUser> getProfileSummary() async {
    final data = asMap(
      await _api.getRaw('/api/user/profile-summary'),
      what: 'profile-summary',
    );
    return AuthUser.fromJson(asMap(data['user'], what: 'user'));
  }

  /// `POST /api/user/avatar` (multipart `avatar` field). Returns the new
  /// public avatar URL. Throws [ApiException] with the server's message.
  Future<String?> uploadAvatar(String filePath, String fileName) async {
    final form = FormData.fromMap({
      'avatar': await MultipartFile.fromFile(filePath, filename: fileName),
    });
    final data = asMap(
      await _api.postRaw('/api/user/avatar', body: form),
      what: 'avatar',
    );
    return optString(data, 'avatar_url');
  }

  /// `POST /api/user/change-password`. Throws [ApiException] carrying the
  /// server's message on a 400/500.
  Future<void> changePassword(
    String newPassword,
    String confirmPassword,
  ) async {
    await _api.postRaw(
      '/api/user/change-password',
      body: {'new_password': newPassword, 'confirm_password': confirmPassword},
    );
  }

  /// `POST /api/practice/history/query` — past sessions with backend filters.
  /// [level] is `1..6` and [category] `practice|exam`; null means all.
  Future<ReviewHistoryPage> getPracticeHistory({
    required int page,
    String? level,
    String? category,
    required String sort,
  }) async {
    final data = await _api.postRaw(
      '/api/practice/history/query',
      body: {
        'page': page,
        'sort': sort,
        'level': ?level,
        'category': ?category,
      },
    );
    return ReviewHistoryPage.fromJson(asMap(data, what: 'history'));
  }

  /// `GET /api/practice/history/:id` — every answered question of a session.
  Future<ReviewDetail> getPracticeHistoryDetail(int sessionId) async {
    final data = await _api.getRaw('/api/practice/history/$sessionId');
    return ReviewDetail.fromJson(asMap(data, what: 'history detail'));
  }
}
