/// Recommend module — one recommended practice group.
///
/// Ported from `RecommendedPractice` in
/// `yi-chinese-manage/lib/types/dashboard.ts`. Raw JSON from
/// `GET /api/practice/recommend` (under `{ recommendations: [...] }`). Only the
/// fields the card and the launch need are kept. `fromJson` validates (rule 6).
library;

import '../../../../core/api/validators.dart';

class RecommendedPractice {
  const RecommendedPractice({
    required this.level,
    required this.lesson,
    required this.progress,
    required this.category,
    required this.questionCount,
    required this.status,
    required this.recentMatchedWords,
    this.skill,
  });

  final int level;
  final int lesson;
  final String progress;
  final String category; // "practice" | "exam"
  final int questionCount;
  final String status; // "Not start" | "Finish and success" | "Finish and fail"
  final List<String> recentMatchedWords;
  final String? skill; // "listening" | "reading" | null

  factory RecommendedPractice.fromJson(Map<String, dynamic> json) {
    return RecommendedPractice(
      level: optInt(json, 'level') ?? 0,
      lesson: optInt(json, 'lesson') ?? 0,
      progress: optString(json, 'progress') ?? '',
      category: optString(json, 'category') ?? 'practice',
      questionCount: optInt(json, 'question_count') ?? 0,
      status: optString(json, 'status') ?? 'Not start',
      recentMatchedWords: stringList(json, 'recent_matched_words'),
      skill: optString(json, 'skill'),
    );
  }
}
