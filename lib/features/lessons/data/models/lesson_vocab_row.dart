/// Lessons module — one vocabulary row for a passage (word popups / summary).
///
/// Ported from `yi-chinese-manage/lib/types/vocab.ts` (`LessonVocabRow`). Raw
/// JSON: `/api/lesson/vocab/:id` → `{ passage_id, vocab: [LessonVocabRow] }`.
/// `audio_key` can arrive empty/absent, so it is optional here. `fromJson`
/// validates its fields (plan rule 6).
library;

import '../../../../core/api/validators.dart';

class LessonVocabRow {
  const LessonVocabRow({
    required this.cn,
    required this.pinyin,
    required this.meaningVn,
    required this.meaningEn,
    required this.hskLevel,
    this.audioKey,
  });

  final String cn;
  final String pinyin;
  final String meaningVn;
  final String meaningEn;
  final String hskLevel;
  final String? audioKey;

  factory LessonVocabRow.fromJson(Map<String, dynamic> json) {
    return LessonVocabRow(
      cn: requireString(json, 'cn'),
      pinyin: requireString(json, 'pinyin'),
      meaningVn: requireString(json, 'meaning_vn'),
      meaningEn: requireString(json, 'meaning_en'),
      hskLevel: requireString(json, 'hsk_level'),
      audioKey: optString(json, 'audio_key'),
    );
  }
}
