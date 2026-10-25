/// Lessons module — passage content for the lesson-study reader.
///
/// Ported from `yi-chinese-manage/lib/types/lesson.ts`
/// (`LessonPassageDetail` + `LessonPassageLine`). Raw JSON:
/// `/api/lesson/passage/:id` → `{ passage: LessonPassageDetail }` (the
/// repository unwraps `passage`). Every `fromJson` validates its fields
/// (plan rule 6).
library;

import '../../../../core/api/validators.dart';

/// One line of a passage: hanzi content with pinyin and translations, plus the
/// word tokens the Lesson Summary makes tappable.
class LessonPassageLine {
  const LessonPassageLine({
    required this.lineId,
    required this.flag,
    required this.tokens,
    required this.translationEn,
    required this.translationVi,
    this.speaker,
    this.content,
    this.pinyin,
    this.audioKey,
  });

  final int lineId;
  final int flag;
  final List<String> tokens;
  final String? translationEn;
  final String? translationVi;
  final String? speaker;
  final String? content;
  final String? pinyin;
  final String? audioKey;

  factory LessonPassageLine.fromJson(Map<String, dynamic> json) {
    final translations = json['translations'];
    final t = translations == null
        ? const <String, dynamic>{}
        : asMap(translations, what: 'translations');
    return LessonPassageLine(
      lineId: requireInt(json, 'line_id'),
      flag: optInt(json, 'flag') ?? 0,
      tokens: stringList(json, 'tokens'),
      translationEn: optString(t, 'en'),
      translationVi: optString(t, 'vi'),
      speaker: optString(json, 'speaker'),
      content: optString(json, 'content'),
      pinyin: optString(json, 'pinyin'),
      audioKey: optString(json, 'audio_key'),
    );
  }
}

class LessonPassageDetail {
  const LessonPassageDetail({
    required this.passageId,
    required this.lines,
    this.hskLevel,
    this.bookCode,
    this.title,
  });

  final String passageId;
  final List<LessonPassageLine> lines;
  final String? hskLevel;
  final String? bookCode;
  final String? title;

  factory LessonPassageDetail.fromJson(Map<String, dynamic> json) {
    return LessonPassageDetail(
      passageId: requireString(json, 'passage_id'),
      lines: modelList(json, 'lines', LessonPassageLine.fromJson),
      hskLevel: optString(json, 'hsk_level'),
      bookCode: optString(json, 'book_code'),
      title: optString(json, 'title'),
    );
  }
}
