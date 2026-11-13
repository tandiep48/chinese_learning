/// Vocab module — pure helpers behind the learner vocab selection page.
///
/// Ported from `yi-chinese-manage/lib/vocab/vocabSelect.ts`: which modes carry no
/// filters, and how lessons/parts group and sort. Free of UI/i18n — label text
/// comes in through callbacks.
library;

const int vocabDefaultPageSize = 20;

/// The six table modes. `recent` is served by a separate endpoint; `book` shows
/// one saved book's words; the rest share `/api/vocab/table/query`.
enum VocabMode {
  free('free'),
  standard('standard'),
  book('book'),
  unsure('unsure'),
  unlearn('unlearn'),
  recent('recent');

  const VocabMode(this.wire);
  final String wire;
}

/// These load straight from the user's own history, with no HSK/lesson filters.
bool isHistoryMode(VocabMode mode) =>
    mode == VocabMode.unsure ||
    mode == VocabMode.unlearn ||
    mode == VocabMode.recent;

/// One passage split into lesson/part (passage ids look like "H2_3_1").
class PassageMeta {
  const PassageMeta({
    required this.passageId,
    required this.lesson,
    required this.part,
  });
  final String passageId;
  final String lesson;
  final String part;
}

/// One picker option (value + label, optionally grouped).
class VocabOption {
  const VocabOption({required this.value, required this.label, this.group});
  final String value;
  final String label;
  final String? group;
}

/// 'Other' sinks to the bottom; the rest sort numerically.
int numericSort(String a, String b) {
  if (a == 'Other') return 1;
  if (b == 'Other') return -1;
  final na = int.tryParse(a), nb = int.tryParse(b);
  if (na != null && nb != null) return na - nb;
  return a.compareTo(b);
}

Map<String, List<PassageMeta>> groupPassagesByLesson(List<String> passageIds) {
  final grouped = <String, List<PassageMeta>>{};
  for (final id in passageIds) {
    final parts = id.split('_');
    final lesson = parts.length >= 2 ? parts[1] : 'Other';
    final part = parts.length >= 3 ? parts[2] : id;
    (grouped[lesson] ??= []).add(
      PassageMeta(passageId: id, lesson: lesson, part: part),
    );
  }
  return grouped;
}

List<VocabOption> buildLessonOptions(
  Map<String, List<PassageMeta>> grouped,
  String Function(String lesson) lessonLabel,
) {
  final keys = grouped.keys.toList()..sort(numericSort);
  return [for (final k in keys) VocabOption(value: k, label: lessonLabel(k))];
}

List<VocabOption> buildPartOptions(
  List<String> lessons,
  Map<String, List<PassageMeta>> grouped,
  String Function(String lesson) lessonLabel,
  String Function(String part) partLabel,
) {
  final showGroups = lessons.length > 1;
  final options = <VocabOption>[];
  final sortedLessons = [...lessons]..sort(numericSort);
  for (final lesson in sortedLessons) {
    final passages = grouped[lesson];
    if (passages == null || passages.isEmpty) continue;
    final groupLabel = lessonLabel(lesson);
    final sorted = [...passages]
      ..sort(
        (a, b) => (int.tryParse(a.part) ?? 0) - (int.tryParse(b.part) ?? 0),
      );
    for (final p in sorted) {
      options.add(
        VocabOption(
          value: p.passageId,
          label: partLabel(p.part),
          group: showGroups ? groupLabel : null,
        ),
      );
    }
  }
  return options;
}
