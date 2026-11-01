/// Lessons module — providers backing the browse + study screens.
///
/// All auto-disposed so revisiting refetches; the family providers key by book
/// code / passage id.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/lesson_repository.dart';
import '../data/models/learner_book.dart';
import '../data/models/lesson_passage.dart';
import '../data/models/lesson_vocab_row.dart';

final learnerBooksProvider =
    FutureProvider.autoDispose<List<LearnerBookSummary>>((ref) {
  return ref.read(lessonRepositoryProvider).getLearnerBooks();
});

final learnerBookProvider =
    FutureProvider.autoDispose.family<LearnerBookDetail, String>((ref, code) {
  return ref.read(lessonRepositoryProvider).getLearnerBook(code);
});

final passageDetailProvider =
    FutureProvider.autoDispose.family<LessonPassageDetail, String>((ref, id) {
  return ref.read(lessonRepositoryProvider).getLessonPassageDetail(id);
});

final passageVocabProvider =
    FutureProvider.autoDispose.family<List<LessonVocabRow>, String>((ref, id) {
  return ref.read(lessonRepositoryProvider).getLessonPassageVocab(id);
});
