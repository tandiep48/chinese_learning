/// Lessons module — lesson-study data access.
///
/// All reads use the raw (legacy) JSON path (web `legacyApiFetch`); the payload
/// is nested under a key the repository unwraps. Ported from
/// `yi-chinese-manage/lib/api/learner/{books,lessons}.ts`:
///   • `/api/lesson/books`            → `{ books: [...] }`
///   • `/api/lesson/book/:code`       → `LearnerBookDetail` (no wrapper)
///   • `/api/lesson/passages?hsk=`    → `{ passages: [...] }`
///   • `/api/lesson/passage/:id`      → `{ passage: {...} }`
///   • `/api/lesson/vocab/:id`        → `{ passage_id, vocab: [...] }`
///   • `/api/lesson/grammar/:id`      → `{ grammar: [...] }` (lesson-wide)
/// The graded trainer (`/start`, `/submit`) lives in the lesson_trainer module.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/validators.dart';
import 'models/learner_book.dart';
import 'models/lesson_grammar.dart';
import 'models/lesson_passage.dart';
import 'models/lesson_vocab_row.dart';
import 'models/picker_passage.dart';
import 'models/picker_progress.dart';
import 'models/translation_row.dart';

final lessonRepositoryProvider = Provider<LessonRepository>((ref) {
  return LessonRepository(ref.read(apiClientProvider));
});

class LessonRepository {
  LessonRepository(this._api);

  final ApiClient _api;

  Future<List<LearnerBookSummary>> getLearnerBooks() async {
    final data = await _api.getRaw('/api/lesson/books');
    return modelList(
      asMap(data, what: 'books'),
      'books',
      LearnerBookSummary.fromJson,
    );
  }

  Future<LearnerBookDetail> getLearnerBook(String code) async {
    final data = await _api.getRaw(
      '/api/lesson/book/${Uri.encodeComponent(code)}',
    );
    return LearnerBookDetail.fromJson(asMap(data, what: 'book'));
  }

  Future<List<PickerPassage>> getPassages(String hskLevel) async {
    final data = await _api.getRaw(
      '/api/lesson/passages',
      query: {'hsk_level': hskLevel},
    );
    return modelList(
      asMap(data, what: 'passages'),
      'passages',
      PickerPassage.fromJson,
    );
  }

  /// Learn-progress per lesson and part; empty when the call fails (progress is
  /// decorative, never blocks the picker).
  Future<PickerProgressSummary> getPickerProgress(String hskLevel) async {
    try {
      final data = await _api.getRaw(
        '/api/lesson/picker-progress',
        query: {'hsk_level': hskLevel},
      );
      return PickerProgressSummary.fromJson(asMap(data, what: 'progress'));
    } catch (_) {
      return PickerProgressSummary.empty;
    }
  }

  /// Records the part as the most recent lesson (the home "Continue" panel).
  /// Best-effort — never blocks navigation.
  Future<void> saveRecentLearning(String passageId) async {
    try {
      await _api.postRaw(
        '/api/user/recent-learning',
        body: {'passage_id': passageId},
      );
    } catch (_) {}
  }

  /// The words the learner saved from a book-lesson part (`GET /api/vocab/saved`).
  Future<Set<String>> getSavedWords(String passageId) async {
    final data = await _api.getRaw(
      '/api/vocab/saved',
      query: {'passage_id': passageId},
    );
    final words =
        asMap(data, what: 'saved words')['words'] as List? ?? const [];
    return {for (final w in words) w.toString()};
  }

  Future<void> addSavedWord(String passageId, String cn) async {
    await _api.postRaw(
      '/api/vocab/saved',
      body: {'passage_id': passageId, 'cn': cn},
    );
  }

  Future<void> removeSavedWord(String passageId, String cn) async {
    await _api.deleteRaw(
      '/api/vocab/saved',
      body: {'passage_id': passageId, 'cn': cn},
    );
  }

  Future<LessonPassageDetail> getLessonPassageDetail(String passageId) async {
    final data = await _api.getRaw(
      '/api/lesson/passage/${Uri.encodeComponent(passageId)}',
    );
    final map = asMap(data, what: 'passage');
    return LessonPassageDetail.fromJson(asMap(map['passage'], what: 'passage'));
  }

  Future<List<LessonVocabRow>> getLessonPassageVocab(String passageId) async {
    final data = await _api.getRaw(
      '/api/lesson/vocab/${Uri.encodeComponent(passageId)}',
    );
    return modelList(
      asMap(data, what: 'vocab'),
      'vocab',
      LessonVocabRow.fromJson,
    );
  }

  /// Lesson translation sentences for an HSK level + lesson number.
  Future<List<TranslationRow>> getLessonTranslations(
    String hskLevel,
    String lesson,
  ) async {
    final data = await _api.getRaw(
      '/api/translation/lesson',
      query: {'hsk_level': hskLevel, 'lesson': lesson},
    );
    return modelList(
      asMap(data, what: 'translations'),
      'translations',
      TranslationRow.fromJson,
    );
  }

  /// Lesson-wide grammar rules (all parts) for the passage's lesson.
  Future<List<LessonGrammarRule>> getLessonGrammar(String passageId) async {
    final data = await _api.getRaw(
      '/api/lesson/grammar/${Uri.encodeComponent(passageId)}',
    );
    return modelList(
      asMap(data, what: 'grammar'),
      'grammar',
      LessonGrammarRule.fromJson,
    );
  }
}
