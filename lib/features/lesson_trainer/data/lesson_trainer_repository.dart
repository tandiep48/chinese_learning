/// Lesson trainer — data access for the graded lesson session.
///
/// Raw JSON, login-required. Ported from
/// `yi-chinese-manage/lib/api/learner/lessons.ts`:
///   • `POST /api/lesson/start` { passage_id, mode:"part" } → [LessonSessionResponse]
///   • `POST /api/lesson/submit` — logs one answer (best-effort, never throws)
///   • `POST /api/lesson/part-complete` — saves the round score (best-effort)
/// "part" mode drives one passage; "master" mode drills several at once.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/validators.dart';
import 'models/lesson_task.dart';

final lessonTrainerRepositoryProvider = Provider<LessonTrainerRepository>((
  ref,
) {
  return LessonTrainerRepository(ref.read(apiClientProvider));
});

class LessonTrainerRepository {
  LessonTrainerRepository(this._api);

  final ApiClient _api;

  /// One part ("part" mode) or several at once ("master" mode, `passage_ids`).
  Future<LessonSessionResponse> startSession(
    List<String> passageIds, {
    bool master = false,
  }) async {
    final data = await _api.postRaw(
      '/api/lesson/start',
      body: master
          ? {'passage_ids': passageIds, 'mode': 'master'}
          : {'passage_id': passageIds.first, 'mode': 'part'},
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
      await _api.postRaw(
        '/api/lesson/submit',
        body: {
          'session_id': sessionId,
          'passage_id': task.passageId,
          'line_id': task.lineId,
          'type': task.type,
          'user_answer': userAnswer,
          'correct_answer': task.correctAnswer,
          'is_correct': isCorrect,
          'response_time_ms': responseMs,
          'game_info': gameInfo,
        },
      );
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
    bool master = false,
  }) async {
    try {
      await _api.postRaw(
        '/api/lesson/part-complete',
        body: {
          'passage_id': passageId,
          'total': total,
          'correct': correct,
          'mode': master ? 'master' : 'part',
        },
      );
    } catch (_) {
      // Best-effort.
    }
  }
}
