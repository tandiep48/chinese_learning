/// Profile module — the practice-review shapes served by `/api/practice/history`.
///
/// Ported from `lib/types/practice.ts` (`ReviewSessionSummary`,
/// `ReviewQuestion`, `ReviewSessionDetail`). Raw JSON, login-required; every
/// `fromJson` validates its fields (plan rule 6).
library;

import '../../../../core/api/validators.dart';

/// One past practice / exam session in the list.
class ReviewSession {
  const ReviewSession({
    required this.sessionId,
    required this.endedAt,
    required this.total,
    required this.levels,
    required this.lessons,
  });

  final int sessionId;
  final DateTime? endedAt;
  final int total;
  final List<int> levels;
  final List<String> lessons;

  factory ReviewSession.fromJson(Map<String, dynamic> json) {
    final levels = json['levels'];
    final lessons = json['lessons'];
    return ReviewSession(
      sessionId: requireInt(json, 'session_id'),
      endedAt: DateTime.tryParse(optString(json, 'ended_at') ?? '')?.toLocal(),
      total: optInt(json, 'total') ?? 0,
      levels: levels is List
          ? [
              for (final l in levels)
                if (int.tryParse('$l') != null) int.parse('$l'),
            ]
          : const [],
      lessons: lessons is List ? [for (final l in lessons) '$l'] : const [],
    );
  }
}

class ReviewHistoryPage {
  const ReviewHistoryPage({required this.sessions, required this.hasMore});

  final List<ReviewSession> sessions;
  final bool hasMore;

  factory ReviewHistoryPage.fromJson(Map<String, dynamic> json) {
    return ReviewHistoryPage(
      sessions: modelList(json, 'sessions', ReviewSession.fromJson),
      hasMore: json['has_more'] == true,
    );
  }
}

/// One answered question, read-only.
class ReviewQuestion {
  const ReviewQuestion({
    required this.level,
    required this.skill,
    required this.answer,
    required this.userAnswer,
    required this.isCorrect,
    required this.audioKeys,
    required this.options,
    required this.category,
    this.content,
    this.question,
    this.image,
  });

  final int level;
  final String skill;
  final String answer;
  final String? userAnswer;
  final bool isCorrect;
  final List<String> audioKeys;

  /// Values are strings, or booleans for True/False questions.
  final Map<String, dynamic> options;
  final String category;
  final String? content;
  final String? question;
  final String? image;

  factory ReviewQuestion.fromJson(Map<String, dynamic> json) {
    return ReviewQuestion(
      level: optInt(json, 'level') ?? 1,
      skill: optString(json, 'skill') ?? 'listening',
      answer: optString(json, 'answer') ?? '',
      userAnswer: optString(json, 'user_answer'),
      isCorrect: json['is_correct'] == true,
      audioKeys: stringList(json, 'audio_key'),
      options: json['options'] is Map
          ? Map<String, dynamic>.from(json['options'] as Map)
          : const <String, dynamic>{},
      category: optString(json, 'category') == 'exam' ? 'exam' : 'practice',
      content: optString(json, 'content'),
      question: optString(json, 'question'),
      image: optString(json, 'image'),
    );
  }
}

class ReviewDetail {
  const ReviewDetail({required this.questions});

  final List<ReviewQuestion> questions;

  factory ReviewDetail.fromJson(Map<String, dynamic> json) => ReviewDetail(
    questions: modelList(json, 'questions', ReviewQuestion.fromJson),
  );
}
