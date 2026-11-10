/// Lessons module — one lesson translation sentence.
///
/// Ported from `TranslationRow` in `yi-chinese-manage/lib/types/lesson.ts`. Raw
/// JSON from `GET /api/translation/lesson?hsk_level=&lesson=` →
/// `{ translations: [...] }`. `fromJson` validates (plan rule 6).
library;

import '../../../../core/api/validators.dart';

class TranslationRow {
  const TranslationRow({
    required this.translationId,
    required this.cn,
    this.vn,
    this.en,
  });

  final String translationId;
  final String cn;
  final String? vn;
  final String? en;

  factory TranslationRow.fromJson(Map<String, dynamic> json) {
    return TranslationRow(
      translationId: optString(json, 'translation_id') ?? '',
      cn: optString(json, 'cn') ?? '',
      vn: optString(json, 'vn'),
      en: optString(json, 'en'),
    );
  }
}
