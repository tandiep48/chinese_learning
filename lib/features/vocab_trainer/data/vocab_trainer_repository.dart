/// Vocab trainer — data access (words + batch submit).
///
/// Raw JSON, login-required, best-effort. Ported from
/// `yi-chinese-manage/lib/api/learner/vocabTrainer.ts`:
///   • `POST /api/vocab/words { passage_id }` → `{ words: [...] }`
///   • `POST /api/vocab/submit-batch { session_id, records }` — fire-and-forget
/// Both soft-fail to an empty / no-op result when signed out, like the web.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/validators.dart';
import 'trainer_word.dart';

final vocabTrainerRepositoryProvider = Provider<VocabTrainerRepository>((ref) {
  return VocabTrainerRepository(ref.read(apiClientProvider));
});

/// One buffered answer for `submit-batch` (mirrors `VocabTrainerRecord`).
class VocabRecord {
  const VocabRecord({
    required this.type,
    required this.word,
    required this.roundNum,
    required this.userAnswer,
    required this.isCorrect,
    required this.pinyin,
    required this.meaningEn,
  });

  final String type; // "typing" | "meaning" (reading) | "listen"
  final String word;
  final int roundNum;
  final String userAnswer;
  final bool isCorrect;
  final String pinyin;
  final String meaningEn;

  Map<String, dynamic> toJson() => {
        'type': type,
        'word': word,
        'round_num': roundNum,
        'user_answer': userAnswer,
        'is_correct': isCorrect,
        'response_time_ms': 0,
        'game_info': {'pinyin': pinyin, 'meaning_en': meaningEn},
      };
}

class VocabTrainerRepository {
  VocabTrainerRepository(this._api);

  final ApiClient _api;

  /// Resolve the part's trainer words; returns [] on any failure.
  Future<List<TrainerWord>> resolveWords(String passageId) async {
    try {
      final data =
          await _api.postRaw('/api/vocab/words', body: {'passage_id': passageId});
      final rows = modelList(asMap(data, what: 'words'), 'words', TrainerWord.fromJson);
      return rows.where((w) => w.word.isNotEmpty).toList();
    } catch (_) {
      return const [];
    }
  }

  /// Submit a group's buffered answers — best-effort, never throws.
  Future<void> submitBatch(int sessionId, List<VocabRecord> records) async {
    if (records.isEmpty) return;
    try {
      await _api.postRaw('/api/vocab/submit-batch', body: {
        'session_id': sessionId,
        'records': [for (final r in records) r.toJson()],
      });
    } catch (_) {
      // Best-effort progress logging.
    }
  }
}
