/// Home module — the learner's current (resume) lesson for the
/// "continue where you left off" card.
///
/// Ported from `yi-chinese-manage/lib/types/dashboard.ts`
/// (`DashboardCurrentLesson` + `DashboardLesson`). Raw JSON from
/// `GET /api/user/dashboard-current-lesson?page=&page_size=`; this slice reads
/// only `has_recent` + `lesson` (the `vocab`/`progress` payloads are deferred).
/// `fromJson` validates its fields (plan rule 6).
library;

import '../../../../core/api/validators.dart';

class CurrentLesson {
  const CurrentLesson({required this.hasRecent, this.lesson});

  final bool hasRecent;
  final CurrentLessonInfo? lesson;

  factory CurrentLesson.fromJson(Map<String, dynamic> json) {
    final hasRecent = optBool(json, 'has_recent');
    final lessonJson = json['lesson'];
    return CurrentLesson(
      hasRecent: hasRecent,
      lesson: (hasRecent && lessonJson != null)
          ? CurrentLessonInfo.fromJson(asMap(lessonJson, what: 'lesson'))
          : null,
    );
  }
}

class CurrentLessonInfo {
  const CurrentLessonInfo({
    required this.passageId,
    required this.hskLevel,
    required this.level,
    required this.lesson,
    required this.part,
    this.updatedAt,
  });

  final String passageId;
  final String hskLevel;
  final int level;
  final int lesson;
  final int part;
  final String? updatedAt;

  factory CurrentLessonInfo.fromJson(Map<String, dynamic> json) {
    return CurrentLessonInfo(
      passageId: requireString(json, 'passage_id'),
      hskLevel: requireString(json, 'hsk_level'),
      level: requireInt(json, 'level'),
      lesson: requireInt(json, 'lesson'),
      part: requireInt(json, 'part'),
      updatedAt: optString(json, 'updated_at'),
    );
  }
}
