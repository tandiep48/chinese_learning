/// Vocab trainer — one normalized word row.
///
/// Ported from `VocabRow` (`yi-chinese-manage/lib/types/vocab.ts`), the shape
/// `POST /api/vocab/words` returns. `meaning` picks the language-aware gloss like
/// the web `pickMeaning` (VI → Vietnamese, falling back to English; EN the
/// reverse). `fromJson` tolerates missing optional fields (plan rule 6 for the
/// required `word`).
library;

import '../../../core/api/validators.dart';

class TrainerWord {
  const TrainerWord({
    required this.word,
    this.pinyin = '',
    this.meaningVn = '',
    this.meaningEn = '',
    this.audioKey = '',
    this.level = '',
  });

  final String word;
  final String pinyin;
  final String meaningVn;
  final String meaningEn;
  final String audioKey;
  final String level;

  String meaning(bool isVi) {
    final vn = meaningVn;
    final en = meaningEn;
    return (isVi ? (vn.isNotEmpty ? vn : en) : (en.isNotEmpty ? en : vn));
  }

  factory TrainerWord.fromJson(Map<String, dynamic> json) {
    return TrainerWord(
      word: requireString(json, 'word'),
      pinyin: optString(json, 'pinyin') ?? '',
      meaningVn: optString(json, 'meaning_vn') ?? '',
      meaningEn: optString(json, 'meaning_en') ?? '',
      audioKey: optString(json, 'audio_key') ?? '',
      level: optString(json, 'level') ?? '',
    );
  }
}
