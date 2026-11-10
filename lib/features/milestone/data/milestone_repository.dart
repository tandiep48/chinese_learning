/// Milestone module — data access for the six-step lesson-part flow.
///
/// Raw (legacy) JSON, login-required. Ported from
/// `yi-chinese-manage/lib/api/learner/milestone.ts`:
///   • `GET  /api/lesson/milestone?passage_id=` → [Milestone]
///   • `POST /api/lesson/milestone { passage_id, step }` — records one PASSIVE
///     step (1, 2, 4, 5) and returns the recomputed milestone. The graded steps
///     (3, 6) are refused by the server on purpose — they are recorded by the
///     vocab trainer's batch submit and `/api/lesson/part-complete` respectively.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/validators.dart';
import 'milestone.dart';

final milestoneRepositoryProvider = Provider<MilestoneRepository>((ref) {
  return MilestoneRepository(ref.read(apiClientProvider));
});

class MilestoneRepository {
  MilestoneRepository(this._api);

  final ApiClient _api;

  Future<Milestone> getMilestone(String passageId) async {
    final data = await _api.getRaw(
      '/api/lesson/milestone',
      query: {'passage_id': passageId},
    );
    return Milestone.fromJson(asMap(data, what: 'milestone'));
  }

  /// Record a passive step (1, 2, 4, 5); returns the recomputed milestone.
  Future<Milestone> markStep(String passageId, int step) async {
    final data = await _api.postRaw(
      '/api/lesson/milestone',
      body: {'passage_id': passageId, 'step': step},
    );
    return Milestone.fromJson(asMap(data, what: 'milestone'));
  }
}
