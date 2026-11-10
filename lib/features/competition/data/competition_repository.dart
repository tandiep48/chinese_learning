/// Competition — REST data access (the non-socket half of Learn Together).
///
/// Ported from `yi-chinese-manage/lib/api/learner/competition.ts` +
/// `getSavedBooks`. Room creation and the two book-mode lookups go over HTTP;
/// everything else about a live room flows over the socket. Login-required and
/// non-enveloped (raw JSON), matching the backend's
/// `routes/competition/competition_routes.py` and `/api/vocab/saved-books`.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/validators.dart';
import '../../vocab_trainer/data/trainer_word.dart';
import 'models/competition_models.dart';

final competitionRepositoryProvider = Provider<CompetitionRepository>((ref) {
  return CompetitionRepository(ref.read(apiClientProvider));
});

class CompetitionRepository {
  CompetitionRepository(this._api);

  final ApiClient _api;

  /// `POST /api/competition/rooms` -> `{ room }`. The server normalizes a full
  /// activity_type selection back to "all" and answers 404 when the picked parts
  /// have no material (the thrown [ApiException] carries that message).
  Future<CompetitionRoom> createRoom(CompetitionRoomSettings settings) async {
    final data = await _api.postRaw(
      '/api/competition/rooms',
      body: settings.toJson(),
    );
    return CompetitionRoom.fromJson(
      asMap(asMap(data, what: 'room')['room'], what: 'room'),
    );
  }

  /// `GET /api/competition/book-passages?book_code=` -> the parts of that book the
  /// signed-in user has saved words in. Rejects on a failed request so the caller
  /// can tell "the lookup broke" from "this book has no saved parts".
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

  /// `GET /api/competition/sessions/<id>/book-words` -> the book room's shared pool,
  /// frozen server-side at session start. Soft-fails to [] (web parity).
  Future<List<TrainerWord>> getSessionBookWords(int sessionId) async {
    try {
      final data = await _api.getRaw(
        '/api/competition/sessions/$sessionId/book-words',
      );
      final rows = modelList(
        asMap(data, what: 'words'),
        'words',
        TrainerWord.fromJson,
      );
      return rows.where((w) => w.word.isNotEmpty).toList();
    } catch (_) {
      return const [];
    }
  }

  /// The public passage vocabulary across the picked parts, for a vocab room.
  /// `POST /api/vocab/words { passage_ids }` -> `{ words }`. Soft-fails to [].
  Future<List<TrainerWord>> resolveWords(List<String> passageIds) async {
    try {
      final data = await _api.postRaw(
        '/api/vocab/words',
        body: {'passage_ids': passageIds},
      );
      final rows = modelList(
        asMap(data, what: 'words'),
        'words',
        TrainerWord.fromJson,
      );
      return rows.where((w) => w.word.isNotEmpty).toList();
    } catch (_) {
      return const [];
    }
  }

  /// `GET /api/vocab/saved-books` -> the books the host has saved words in, for the
  /// Book-mode source picker. Soft-fails to [].
  Future<List<SavedBook>> getSavedBooks() async {
    try {
      final data = await _api.getRaw('/api/vocab/saved-books');
      final rows = (asMap(data, what: 'books')['books'] as List? ?? const []);
      return [
        for (final r in rows)
          if (r is Map) SavedBook.fromJson(r.cast<String, dynamic>()),
      ];
    } catch (_) {
      return const [];
    }
  }
}
