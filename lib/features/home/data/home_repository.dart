/// Home module — dashboard data access.
///
/// Reads the learner's current lesson from the raw (legacy) endpoint
/// `GET /api/user/dashboard-current-lesson` (web `legacyApiFetch`). The rich
/// dashboard (stats, charts, recommendations) is deferred per the port plan.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/validators.dart';
import 'models/current_lesson.dart';

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return HomeRepository(ref.read(apiClientProvider));
});

class HomeRepository {
  HomeRepository(this._api);

  final ApiClient _api;

  Future<CurrentLesson> getCurrentLesson({int page = 1, int pageSize = 5}) async {
    final data = await _api.getRaw(
      '/api/user/dashboard-current-lesson',
      query: {'page': page, 'page_size': pageSize},
    );
    return CurrentLesson.fromJson(asMap(data, what: 'dashboard'));
  }
}
