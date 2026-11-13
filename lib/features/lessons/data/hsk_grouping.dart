/// Lessons module — group an HSK level's passages into lessons and parts.
///
/// Ported from the grouping/sorting helpers in
/// `yi-chinese-manage/lib/lessons/lessons.ts` (`groupPassagesByLesson`,
/// `sortLessonNums`, `sortPartsByNumber`, `lessonTitle`), which themselves port
/// `Learning/web_app/static/shared/passage_picker.js`. Passage ids are
/// `H<level>_<lesson>_<part>`; the lesson number is segment 2, the part number
/// segment 3. The HSK1 pinyin (`H1_1_1`) and Numbers (`H1_5_99`) special-cases
/// are deferred for this slice (port plan, Slice N2), so passages are grouped
/// as-is.
library;

import 'models/picker_passage.dart';

/// A lesson within an HSK level: its number (or `Other`), an optional title
/// taken from its first part, and its parts sorted by part number.
class HskLesson {
  const HskLesson({required this.lesson, required this.parts, this.title});

  final String lesson;
  final String? title;
  final List<PickerPassage> parts;

  int get partCount => parts.length;
  bool get isOther => lesson == 'Other';
}

/// Part number from a passage id (`H1_10_3` → 3); unparseable ids sort last.
int _partNumber(String passageId) {
  final seg = passageId.split('_');
  if (seg.length >= 3) {
    final n = int.tryParse(seg[2]);
    if (n != null) return n;
  }
  return 1 << 30;
}

/// Lesson title = the part-1 passage's title, falling back to any part's title.
String? _lessonTitle(List<PickerPassage> parts) {
  for (final p in parts) {
    final seg = p.passageId.split('_');
    final isPart1 = seg.length >= 3 && seg[2] == '1';
    if (isPart1 && p.title != null && p.title!.isNotEmpty) return p.title;
  }
  for (final p in parts) {
    if (p.title != null && p.title!.isNotEmpty) return p.title;
  }
  return null;
}

/// Numeric lesson order; `Other` always sorts last (mirrors `sortLessonNums`).
int _compareLessonNums(String a, String b) {
  if (a == 'Other') return 1;
  if (b == 'Other') return -1;
  final na = int.tryParse(a);
  final nb = int.tryParse(b);
  if (na != null && nb != null) return na.compareTo(nb);
  return a.compareTo(b);
}

/// Group [passages] into sorted lessons, each with its parts sorted by number.
List<HskLesson> groupPassagesIntoLessons(List<PickerPassage> passages) {
  final grouped = <String, List<PickerPassage>>{};
  for (final p in passages) {
    final seg = p.passageId.split('_');
    final lessonNum = seg.length >= 2 ? seg[1] : 'Other';
    (grouped[lessonNum] ??= []).add(p);
  }

  final keys = grouped.keys.toList()..sort(_compareLessonNums);
  return [
    for (final k in keys)
      HskLesson(
        lesson: k,
        title: _lessonTitle(grouped[k]!),
        parts: [...grouped[k]!]
          ..sort(
            (a, b) =>
                _partNumber(a.passageId).compareTo(_partNumber(b.passageId)),
          ),
      ),
  ];
}
