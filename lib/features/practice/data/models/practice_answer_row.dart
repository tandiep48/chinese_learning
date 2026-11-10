/// Practice module — one answered-question row posted to `/api/practice/submit`.
///
/// Ported from `PracticeAnswerRow` in `yi-chinese-manage/lib/types/practice.ts`.
/// Write-only (built by the engine, serialized on submit), so it has `toJson`
/// but no `fromJson`.
library;

import 'practice_question.dart';

class PracticeAnswerRow {
  const PracticeAnswerRow({
    required this.hskLevel,
    required this.lesson,
    required this.questionNo,
    required this.skill,
    required this.type,
    required this.category,
    required this.userAnswer,
    required this.isCorrect,
    required this.responseTimeMs,
  });

  final int hskLevel;
  final String lesson;
  final int questionNo;
  final String skill;
  final int type;
  final PracticeCategory category;
  final String userAnswer;
  final bool isCorrect;
  final int responseTimeMs;

  Map<String, dynamic> toJson() => {
    'hsk_level': hskLevel,
    'lesson': lesson,
    'question_no': questionNo,
    'skill': skill,
    'type': type,
    'category': category.wire,
    'user_answer': userAnswer,
    'is_correct': isCorrect,
    'response_time_ms': responseTimeMs,
  };
}
