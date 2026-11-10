/// Lesson trainer — data access for the graded lesson session.
///
/// Raw JSON, login-required. Ported from
/// `yi-chinese-manage/lib/api/learner/lessons.ts`:
///   • `POST /api/lesson/start` { passage_id, mode:"part" } → [LessonSessionResponse]
///   • `POST /api/lesson/submit` — logs one answer (best-effort, never throws)
///   • `POST /api/lesson/part-complete` — saves the round score (best-effort)
/// Only single-part ("part") mode is used here; master mode is deferred.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/validators.dart';
import 'models/lesson_task.dart';

final lessonTrainerRepositoryProvider = Provider<LessonTrainerRepository>((ref) {
  return LessonTrainerRepository(ref.read(apiClientProvider));
});

class LessonTrainerRepository {
  LessonTrainerRepository(this._api);

  final ApiClient _api;

  Future<LessonSessionResponse> startSession(String passageId) async {
    final data = await _api.postRaw(
      '/api/lesson/start',
      body: {'passage_id': passageId, 'mode': 'part'},
    );
    return LessonSessionResponse.fromJson(asMap(data, what: 'session'));
  }

  /// Log one answer — best-effort, mirrors the web's fire-and-forget submit.
  Future<void> submitAnswer({
    required int sessionId,
    required LessonTask task,
    required String userAnswer,
    required bool isCorrect,
    required bool skipped,
    required int responseMs,
  }) async {
    final gameInfo = <String, dynamic>{
      if (skipped) 'skipped': true,
      if (task.options.isNotEmpty) 'options': task.options,
      if (task.shuffledTokens.isNotEmpty) 'tokens': task.shuffledTokens,
    };
    try {
      await _api.postRaw('/api/lesson/submit', body: {
        'session_id': sessionId,
        'passage_id': task.passageId,
        'line_id': task.lineId,
        'type': task.type,
        'user_answer': userAnswer,
        'correct_answer': task.correctAnswer,
        'is_correct': isCorrect,
        'response_time_ms': responseMs,
        'game_info': gameInfo,
      });
    } catch (_) {
      // Best-effort logging: a failed submit never blocks the round.
    }
  }

  /// Save the round score — best-effort. The server stores it only at/above the
  /// pass threshold and grants word mastery on a perfect round.
  Future<void> completePart({
    required String passageId,
    required int total,
    required int correct,
  }) async {
    try {
      await _api.postRaw('/api/lesson/part-complete', body: {
        'passage_id': passageId,
        'total': total,
        'correct': correct,
        'mode': 'part',
      });
    } catch (_) {
      // Best-effort.
    }
  }
}
