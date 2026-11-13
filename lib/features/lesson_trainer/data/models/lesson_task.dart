/// Lesson trainer — one graded task + the session wrapper.
///
/// Ported from `yi-chinese-manage/lib/types/lesson.ts` (`LessonTask`,
/// `LessonSessionResponse`), built server-side by `build_lesson_tasks()` and
/// returned by `POST /api/lesson/start`. `type` selects the activity:
/// listening / meaning are multiple-choice, typing types the sentence, reorder
/// arranges chips. `fromJson` validates its fields (plan rule 6).
library;

import '../../../../core/api/validators.dart';

class LessonTask {
  const LessonTask({
    required this.type,
    required this.passageId,
    required this.lineId,
    required this.content,
    required this.correctAnswer,
    this.options = const [],
    this.tokens = const [],
    this.shuffledTokens = const [],
    this.pinyin,
    this.audioKey,
    this.hskLevel,
    this.bookCode,
  });

  final String type; // listening | meaning | typing | reorder
  final String passageId;
  final int lineId;
  final String content; // the Chinese sentence (shown, typed, or revealed)
  final String correctAnswer;
  final List<String> options; // listening / meaning
  final List<String> tokens; // reorder: correct order
  final List<String> shuffledTokens; // reorder: presented order
  final String? pinyin; // typing: revealed after answering
  final String? audioKey;
  final String? hskLevel;
  final String? bookCode;

  factory LessonTask.fromJson(Map<String, dynamic> json) {
    return LessonTask(
      type: requireString(json, 'type'),
      passageId: requireString(json, 'passage_id'),
      lineId: requireInt(json, 'line_id'),
      content: optString(json, 'content') ?? '',
      correctAnswer: optString(json, 'correct_answer') ?? '',
      options: stringList(json, 'options'),
      tokens: stringList(json, 'tokens'),
      shuffledTokens: stringList(json, 'shuffled_tokens'),
      pinyin: optString(json, 'pinyin'),
      audioKey: optString(json, 'audio_key'),
      hskLevel: optString(json, 'hsk_level'),
      bookCode: optString(json, 'book_code'),
    );
  }
}

class LessonSessionResponse {
  const LessonSessionResponse({required this.sessionId, required this.tasks});

  final int sessionId;
  final List<LessonTask> tasks;

  factory LessonSessionResponse.fromJson(Map<String, dynamic> json) {
    return LessonSessionResponse(
      sessionId: requireInt(json, 'session_id'),
      tasks: modelList(json, 'tasks', LessonTask.fromJson),
    );
  }
}
