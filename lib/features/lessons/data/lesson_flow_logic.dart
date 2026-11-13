/// Lessons module — pure helpers for rolling through a lesson's parts.
///
/// Ported from `lib/lessons/lessons.ts` (`isBookPassageId`,
/// `hskLevelFromPassageId`, `nextLessonFirstPassageId`) as used by `LessonFlow`.
library;

import 'hsk_grouping.dart';

/// Book passages are `<book_code>_<lesson>_<part>`; HSK ones start with `H<n>`.
bool isBookPassageId(String passageId) {
  final prefix = passageId.split('_').first;
  return prefix.isNotEmpty &&
      !RegExp(r'^H\d+$', caseSensitive: false).hasMatch(prefix);
}

/// `H2_3_1` → `HSK2` (prefix → level key; unknown prefixes pass through).
String hskLevelKeyFromPassageId(String passageId) {
  final prefix = passageId.split('_').first;
  final m = RegExp(r'^H(\d+)$', caseSensitive: false).firstMatch(prefix);
  return m == null ? prefix : 'HSK${m.group(1)}';
}

/// The lesson number (segment 2) of a passage id, or '' when absent.
String lessonOfPassageId(String passageId) {
  final seg = passageId.split('_');
  return seg.length >= 2 ? seg[1] : '';
}

/// The first part of the lesson after [currentPassageId]'s, or null at the last
/// lesson (and for books, which have no next-lesson roll).
String? nextLessonFirstPassageId(
  String currentPassageId,
  List<HskLesson> lessons,
) {
  if (currentPassageId.isEmpty || isBookPassageId(currentPassageId)) {
    return null;
  }
  final current = lessonOfPassageId(currentPassageId);
  final idx = lessons.indexWhere((l) => l.lesson == current);
  if (idx < 0 || idx + 1 >= lessons.length) return null;
  final next = lessons[idx + 1];
  if (next.isOther || next.parts.isEmpty) return null;
  return next.parts.first.passageId;
}

/// Ordered part ids of [passageId]'s lesson within [lessons].
List<String> hskLessonPartIds(String passageId, List<HskLesson> lessons) {
  final current = lessonOfPassageId(passageId);
  for (final l in lessons) {
    if (l.lesson == current) return [for (final p in l.parts) p.passageId];
  }
  return const [];
}
