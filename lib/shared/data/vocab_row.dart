/// Shared — a normalized vocabulary row + its paginated envelope.
///
/// Ported from `VocabRow` / `VocabTableResponse` in
/// `yi-chinese-manage/lib/types/vocab.ts`. Served by several `/api/vocab/*` and
/// `/api/user/*` reads (learned-vocab, review, review-recent), so it lives in
/// `shared/` and both the profile and review modules use it (plan rule 2). Each
/// `fromJson` validates (rule 6).
library;

import '../../core/api/validators.dart';

class VocabRow {
  const VocabRow({
    required this.word,
    required this.cn,
    required this.pinyin,
    required this.meaningVn,
    required this.meaningEn,
    required this.level,
    this.audioKey,
  });

  final String word;
  final String cn;
  final String pinyin;
  final String meaningVn;
  final String meaningEn;
  final String level;
  final String? audioKey;

  factory VocabRow.fromJson(Map<String, dynamic> json) {
    return VocabRow(
      word: optString(json, 'word') ?? optString(json, 'cn') ?? '',
      cn: optString(json, 'cn') ?? '',
      pinyin: optString(json, 'pinyin') ?? '',
      meaningVn: optString(json, 'meaning_vn') ?? '',
      meaningEn: optString(json, 'meaning_en') ?? '',
      level: optString(json, 'level') ?? '',
      audioKey: optString(json, 'audio_key'),
    );
  }
}

/// One page of a vocab query (`{ rows, page, page_size, total, total_pages }`).
class VocabPage {
  const VocabPage({
    required this.rows,
    required this.page,
    required this.totalPages,
    required this.total,
  });

  final List<VocabRow> rows;
  final int page;
  final int totalPages;
  final int total;

  bool get hasMore => page < totalPages;

  factory VocabPage.fromJson(Map<String, dynamic> json) {
    return VocabPage(
      rows: modelList(json, 'rows', VocabRow.fromJson),
      page: optInt(json, 'page') ?? 1,
      totalPages: optInt(json, 'total_pages') ?? 1,
      total: optInt(json, 'total') ?? 0,
    );
  }
}
