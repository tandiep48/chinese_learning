/// Lessons module — learner Books browsing models.
///
/// Ported from `yi-chinese-manage/lib/types/book.ts`. Raw JSON (web
/// `legacyApiFetch`): `/api/lesson/books` → `{ books: [LearnerBookSummary] }`,
/// `/api/lesson/book/:code` → `LearnerBookDetail` (unwrapped by the repository).
/// Every `fromJson` validates its fields (plan rule 6).
library;

import '../../../../core/api/validators.dart';

/// One book card on the Books list.
class LearnerBookSummary {
  const LearnerBookSummary({
    required this.bookCode,
    required this.coverUrl,
    required this.lessonCount,
    required this.partCount,
    required this.doneCount,
    this.name,
  });

  final String bookCode;
  final String coverUrl;
  final int lessonCount;
  final int partCount;
  final int doneCount;
  final String? name;

  factory LearnerBookSummary.fromJson(Map<String, dynamic> json) {
    return LearnerBookSummary(
      bookCode: requireString(json, 'book_code'),
      coverUrl: requireString(json, 'cover_url'),
      lessonCount: requireInt(json, 'lesson_count'),
      partCount: requireInt(json, 'part_count'),
      doneCount: requireInt(json, 'done_count'),
      name: optString(json, 'name'),
    );
  }
}

/// One part (passage) within a lesson.
class LearnerBookPart {
  const LearnerBookPart({
    required this.part,
    required this.passageId,
    this.completed = false,
  });

  final String part;
  final String passageId;
  final bool completed;

  factory LearnerBookPart.fromJson(Map<String, dynamic> json) {
    return LearnerBookPart(
      part: requireStringOrNum(json, 'part'),
      passageId: requireString(json, 'passage_id'),
      completed: optBool(json, 'completed'),
    );
  }
}

/// One lesson within a book, with its parts.
class LearnerBookLesson {
  const LearnerBookLesson({
    required this.lesson,
    required this.partCount,
    required this.doneCount,
    required this.parts,
    this.title,
  });

  final String lesson;
  final int partCount;
  final int doneCount;
  final List<LearnerBookPart> parts;
  final String? title;

  factory LearnerBookLesson.fromJson(Map<String, dynamic> json) {
    return LearnerBookLesson(
      lesson: requireStringOrNum(json, 'lesson'),
      partCount: requireInt(json, 'part_count'),
      doneCount: requireInt(json, 'done_count'),
      parts: modelList(json, 'parts', LearnerBookPart.fromJson),
      title: optString(json, 'title'),
    );
  }
}

/// A book's detail: its lessons and their parts.
class LearnerBookDetail {
  const LearnerBookDetail({
    required this.bookCode,
    required this.lessons,
    this.bookName,
  });

  final String bookCode;
  final List<LearnerBookLesson> lessons;
  final String? bookName;

  factory LearnerBookDetail.fromJson(Map<String, dynamic> json) {
    return LearnerBookDetail(
      bookCode: requireString(json, 'book_code'),
      lessons: modelList(json, 'lessons', LearnerBookLesson.fromJson),
      bookName: optString(json, 'book_name'),
    );
  }
}
