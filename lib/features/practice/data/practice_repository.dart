/// Practice module — data access for practice/exam sessions.
///
/// Ported from `yi-chinese-manage/lib/api/learner/practice.ts` (`/api/practice/*`,
/// raw JSON, login-required). Covers loading a session and submitting answers;
/// the recommend card and review history reads land with their own slices
/// (Recommend / Review). Reads validate via the model `fromJson` (plan rule 6);
/// submit is best-effort and never throws.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/validators.dart';
import 'models/practice_answer_row.dart';
import 'models/practice_question.dart';

final practiceRepositoryProvider = Provider<PracticeRepository>((ref) {
  return PracticeRepository(ref.read(apiClientProvider));
});

/// One item in the multi-select queue posted to `/api/practice/multi`.
class PracticeMultiItem {
  const PracticeMultiItem({
    required this.level,
    required this.lesson,
    required this.progress,
    this.category,
    this.unitIds,
  });

  final int level;
  final String lesson;
  final String progress;
  final PracticeCategory? category;
  final List<String>? unitIds;

  Map<String, dynamic> toJson() => {
    'level': level,
    'lesson': lesson,
    'progress': progress,
    if (category != null) 'category': category!.wire,
    if (unitIds != null) 'unit_ids': unitIds,
  };
}

class PracticeRepository {
  PracticeRepository(this._api);

  final ApiClient _api;

  /// Available lessons for a level: `GET /api/practice/<number>?category=`.
  Future<List<String>> getLessons(
    String number,
    PracticeCategory category,
  ) async {
    final data = asMap(
      await _api.getRaw(
        '/api/practice/$number',
        query: {'category': category.wire},
      ),
      what: 'lessons',
    );
    return stringList(data, 'lessons');
  }

  /// All questions for one lesson, grouped by progress:
  /// `GET /api/practice/<number>/<lesson>?category=`.
  Future<PracticeSessionData> getLesson(
    String number,
    String lesson,
    PracticeCategory category,
  ) async {
    final data = await _api.getRaw(
      '/api/practice/$number/${Uri.encodeComponent(lesson)}',
      query: {'category': category.wire},
    );
    return PracticeSessionData.fromJson(asMap(data, what: 'session'));
  }

  /// One progress group (deep link):
  /// `GET /api/practice/<level>/<lesson>/<progress>?category=` →
  /// `{ level, lesson, progress, questions }`.
  Future<PracticeGroup> getProgressGroup(
    String level,
    String lesson,
    String progress,
    PracticeCategory category,
  ) async {
    final data = await _api.getRaw(
      '/api/practice/$level/${Uri.encodeComponent(lesson)}'
      '/${Uri.encodeComponent(progress)}',
      query: {'category': category.wire},
    );
    return PracticeGroup.fromJson(asMap(data, what: 'group'));
  }

  /// Combined questions for several selected groups:
  /// `POST /api/practice/multi { items }`.
  Future<PracticeSessionData> getMulti(List<PracticeMultiItem> items) async {
    final data = await _api.postRaw(
      '/api/practice/multi',
      body: {
        'items': [for (final i in items) i.toJson()],
      },
    );
    return PracticeSessionData.fromJson(asMap(data, what: 'session'));
  }

  /// Persist a session's answered questions: `POST /api/practice/submit`.
  /// Best-effort — logging must never block the UI.
  Future<void> submit({
    required int sessionId,
    required int? hskLevel,
    required String? lesson,
    required List<PracticeAnswerRow> answers,
  }) async {
    if (answers.isEmpty) return;
    try {
      await _api.postRaw(
        '/api/practice/submit',
        body: {
          'session_id': sessionId,
          'hsk_level': hskLevel,
          'lesson': lesson,
          'answers': [for (final a in answers) a.toJson()],
        },
      );
    } catch (_) {
      // Best-effort persistence.
    }
  }
}
