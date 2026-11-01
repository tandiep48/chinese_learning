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
/// The graded trainer (`/start`, `/submit`) and grammar are out of this slice.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/validators.dart';
import 'models/learner_book.dart';
import 'models/lesson_passage.dart';
import 'models/lesson_vocab_row.dart';
import 'models/picker_passage.dart';

final lessonRepositoryProvider = Provider<LessonRepository>((ref) {
  return LessonRepository(ref.read(apiClientProvider));
});

class LessonRepository {
  LessonRepository(this._api);

  final ApiClient _api;

  Future<List<LearnerBookSummary>> getLearnerBooks() async {
    final data = await _api.getRaw('/api/lesson/books');
    return modelList(asMap(data, what: 'books'), 'books', LearnerBookSummary.fromJson);
  }

  Future<LearnerBookDetail> getLearnerBook(String code) async {
    final data = await _api.getRaw('/api/lesson/book/${Uri.encodeComponent(code)}');
    return LearnerBookDetail.fromJson(asMap(data, what: 'book'));
  }

  Future<List<PickerPassage>> getPassages(String hskLevel) async {
    final data = await _api.getRaw('/api/lesson/passages', query: {'hsk_level': hskLevel});
    return modelList(asMap(data, what: 'passages'), 'passages', PickerPassage.fromJson);
  }

  Future<LessonPassageDetail> getLessonPassageDetail(String passageId) async {
    final data = await _api.getRaw('/api/lesson/passage/${Uri.encodeComponent(passageId)}');
    final map = asMap(data, what: 'passage');
    return LessonPassageDetail.fromJson(asMap(map['passage'], what: 'passage'));
  }

  Future<List<LessonVocabRow>> getLessonPassageVocab(String passageId) async {
    final data = await _api.getRaw('/api/lesson/vocab/${Uri.encodeComponent(passageId)}');
    return modelList(asMap(data, what: 'vocab'), 'vocab', LessonVocabRow.fromJson);
  }
}
