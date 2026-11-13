/// Practice module — the session shapes served by `/api/practice/*`.
///
/// Ported from `yi-chinese-manage/lib/types/practice.ts` (`PracticeQuestion`,
/// `PracticeGroup`, `PracticeSessionData`). Raw JSON, login-required. These feed
/// the practice/exam engine (`practice_engine.dart`) and the group-layout
/// widgets. Every `fromJson` validates its fields (plan rule 6).
library;

import '../../../../core/api/validators.dart';

/// Practice category: Exercise (`practice`) or Exam (`exam`).
enum PracticeCategory {
  practice,
  exam;

  /// Wire value sent to / received from the backend.
  String get wire => name;

  static PracticeCategory fromWire(String? value) =>
      value == 'exam' ? PracticeCategory.exam : PracticeCategory.practice;
}

/// One question in a group. `type` is 1..6; `skill` is "listening" | "reading".
/// `options` values are strings, or booleans for True/False (type 1).
class PracticeQuestion {
  const PracticeQuestion({
    required this.level,
    required this.lesson,
    required this.no,
    required this.skill,
    required this.type,
    required this.answer,
    required this.audioKeys,
    required this.options,
    required this.progress,
    this.content,
    this.question,
    this.image,
    this.category,
    this.unitId,
  });

  final int level;
  final String lesson;
  final int no;
  final String skill;
  final int type;
  final String answer;
  final List<String> audioKeys;
  final Map<String, dynamic> options;
  final String progress;
  final String? content;
  final String? question;
  final String? image;
  final PracticeCategory? category;
  final String? unitId;

  factory PracticeQuestion.fromJson(Map<String, dynamic> json) {
    return PracticeQuestion(
      level: requireInt(json, 'level'),
      lesson: requireStringOrNum(json, 'lesson'),
      no: requireInt(json, 'no'),
      skill: optString(json, 'skill') ?? 'listening',
      type: requireInt(json, 'type'),
      answer: optString(json, 'answer') ?? '',
      audioKeys: stringList(json, 'audio_key'),
      options: json['options'] == null
          ? const <String, dynamic>{}
          : asMap(json['options'], what: 'options'),
      progress: optString(json, 'progress') ?? '',
      content: optString(json, 'content'),
      question: optString(json, 'question'),
      image: optString(json, 'image'),
      category: json['category'] == null
          ? null
          : PracticeCategory.fromWire(optString(json, 'category')),
      unitId: optString(json, 'unit_id'),
    );
  }
}

/// A set of questions sharing one `progress` marker.
class PracticeGroup {
  const PracticeGroup({
    required this.progress,
    required this.lesson,
    required this.questions,
    this.category,
  });

  final String progress;
  final String lesson;
  final List<PracticeQuestion> questions;
  final PracticeCategory? category;

  factory PracticeGroup.fromJson(Map<String, dynamic> json) {
    return PracticeGroup(
      progress: optString(json, 'progress') ?? '',
      lesson: requireStringOrNum(json, 'lesson'),
      questions: modelList(json, 'questions', PracticeQuestion.fromJson),
      category: json['category'] == null
          ? null
          : PracticeCategory.fromWire(optString(json, 'category')),
    );
  }
}

/// A whole session: ordered groups plus the lesson/level metadata.
class PracticeSessionData {
  const PracticeSessionData({
    required this.groups,
    this.number,
    this.level,
    this.lesson,
    this.totalGroups,
  });

  final List<PracticeGroup> groups;
  final String? number;
  final String? level;
  final String? lesson;
  final int? totalGroups;

  factory PracticeSessionData.fromJson(Map<String, dynamic> json) {
    return PracticeSessionData(
      groups: modelList(json, 'groups', PracticeGroup.fromJson),
      number: json['number'] == null
          ? null
          : requireStringOrNum(json, 'number'),
      level: json['level'] == null ? null : requireStringOrNum(json, 'level'),
      lesson: json['lesson'] == null
          ? null
          : requireStringOrNum(json, 'lesson'),
      totalGroups: optInt(json, 'total_groups'),
    );
  }
}
