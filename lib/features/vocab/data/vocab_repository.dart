/// Vocab module — data access for the selection table.
///
/// Ported from `yi-chinese-manage/lib/api/learner/vocab.ts`. All raw JSON,
/// login-required, paginated with the shared [VocabPage] envelope:
///   • POST `/api/vocab/table/query`        — free / standard / book / unsure / unlearn
///   • POST `/api/vocab/search/query`       — debounced search
///   • POST `/api/user/learned-vocab/query` — the `recent` mode
///   • GET  `/api/vocab/saved-books`        — the Book-mode picker
///   • GET  `/api/competition/book-passages`— a saved book's parts
/// Book parts and saved books share the competition endpoints.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/validators.dart';
import '../../../shared/data/vocab_row.dart';
import 'vocab_select_logic.dart';

final vocabRepositoryProvider = Provider<VocabRepository>((ref) {
  return VocabRepository(ref.read(apiClientProvider));
});

class VocabRepository {
  VocabRepository(this._api);

  final ApiClient _api;

  /// A page of the vocab table for free / standard / book / unsure / unlearn.
  Future<VocabPage> getTable({
    required VocabMode mode,
    String? hskLevel,
    List<String> passages = const [],
    String? bookCode,
    required int page,
    required int pageSize,
  }) async {
    final body = <String, dynamic>{
      'mode': mode.wire,
      'page': page,
      'page_size': pageSize,
      if (hskLevel != null && hskLevel.isNotEmpty) 'hsk_level': hskLevel,
      if (mode == VocabMode.standard) 'passages': passages,
      if (mode == VocabMode.book && bookCode != null && bookCode.isNotEmpty)
        'book_code': bookCode,
    };
    final data = await _api.postRaw('/api/vocab/table/query', body: body);
    return VocabPage.fromJson(asMap(data, what: 'vocab table'));
  }

  /// The `recent` mode: the user's mastered words, most-recent first.
  Future<VocabPage> getLearnedVocab(int page, int pageSize) async {
    final data = await _api.postRaw(
      '/api/user/learned-vocab/query',
      body: {'page': page, 'page_size': pageSize},
    );
    return VocabPage.fromJson(asMap(data, what: 'learned vocab'));
  }

  /// Debounced search across word / pinyin / meanings.
  Future<VocabPage> search(String query, int page, int pageSize) async {
    final body = <String, dynamic>{
      'page': page,
      'page_size': pageSize,
      if (query.trim().isNotEmpty) 'q': query,
    };
    final data = await _api.postRaw('/api/vocab/search/query', body: body);
    return VocabPage.fromJson(asMap(data, what: 'vocab search'));
  }

  /// The books the user has saved words in (Book-mode picker). Soft-fails to [].
  Future<List<({String code, String name})>> getSavedBooks() async {
    try {
      final data = await _api.getRaw('/api/vocab/saved-books');
      final rows = (asMap(data, what: 'books')['books'] as List? ?? const []);
      return [
        for (final r in rows)
          if (r is Map)
            (
              code: (r['book_code'] ?? '').toString(),
              name: (r['name'] == null || '${r['name']}'.isEmpty)
                  ? (r['book_code'] ?? '').toString()
                  : '${r['name']}',
            ),
      ];
    } catch (_) {
      return const [];
    }
  }

  /// A saved book's parts the user has words in (passage ids).
  Future<List<String>> getBookPassages(String bookCode) async {
    final data = await _api.getRaw(
      '/api/competition/book-passages',
      query: {'book_code': bookCode},
    );
    final rows =
        (asMap(data, what: 'passages')['passages'] as List? ?? const []);
    return [
      for (final r in rows)
        if (r is Map && r['passage_id'] != null) r['passage_id'].toString(),
    ];
  }
}
