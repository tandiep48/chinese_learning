/// Lessons module — a passage entry in the lesson picker.
///
/// Ported from `yi-chinese-manage/lib/types/lesson.ts` (`PickerPassage`). Raw
/// JSON: `/api/lesson/passages?hsk_level=` → `{ passages: [PickerPassage] }`.
/// `fromJson` validates its fields (plan rule 6).
library;

import '../../../../core/api/validators.dart';

class PickerPassage {
  const PickerPassage({
    required this.passageId,
    required this.hskLevel,
    this.lineCount,
    this.title,
  });

  final String passageId;
  final String hskLevel;
  final int? lineCount;
  final String? title;

  factory PickerPassage.fromJson(Map<String, dynamic> json) {
    return PickerPassage(
      passageId: requireString(json, 'passage_id'),
      hskLevel: requireString(json, 'hsk_level'),
      lineCount: optInt(json, 'line_count'),
      title: optString(json, 'title'),
    );
  }
}
