/// Lessons module — providers backing the browse + study screens.
///
/// All auto-disposed so revisiting refetches; the family providers key by book
/// code / passage id.
library;

import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/hsk_grouping.dart';
import '../data/lesson_repository.dart';
import '../data/models/learner_book.dart';
import '../data/models/lesson_grammar.dart';
import '../data/models/lesson_passage.dart';
import '../data/models/lesson_vocab_row.dart';
import '../data/models/translation_row.dart';
import '../data/pinyin_data.dart';

final learnerBooksProvider =
    FutureProvider.autoDispose<List<LearnerBookSummary>>((ref) {
      return ref.read(lessonRepositoryProvider).getLearnerBooks();
    });

final learnerBookProvider = FutureProvider.autoDispose
    .family<LearnerBookDetail, String>((ref, code) {
      return ref.read(lessonRepositoryProvider).getLearnerBook(code);
    });

/// HSK level → its lessons (grouped from `/api/lesson/passages?hsk_level=`),
/// keyed by level key (e.g. `HSK1`).
final hskLessonsProvider = FutureProvider.autoDispose
    .family<List<HskLesson>, String>((ref, levelKey) async {
      final passages = await ref
          .read(lessonRepositoryProvider)
          .getPassages(levelKey);
      return groupPassagesIntoLessons(passages);
    });

final passageDetailProvider = FutureProvider.autoDispose
    .family<LessonPassageDetail, String>((ref, id) {
      return ref.read(lessonRepositoryProvider).getLessonPassageDetail(id);
    });

final passageVocabProvider = FutureProvider.autoDispose
    .family<List<LessonVocabRow>, String>((ref, id) {
      return ref.read(lessonRepositoryProvider).getLessonPassageVocab(id);
    });

/// Lesson-wide grammar rules for a passage's lesson (`/api/lesson/grammar/:id`).
final lessonGrammarProvider = FutureProvider.autoDispose
    .family<List<LessonGrammarRule>, String>((ref, id) {
      return ref.read(lessonRepositoryProvider).getLessonGrammar(id);
    });

/// Lesson translations, keyed by passage id. The HSK level + lesson number are
/// parsed from the id (`H<level>_<lesson>_<part>`), mirroring the backend.
final lessonTranslationsProvider = FutureProvider.autoDispose
    .family<List<TranslationRow>, String>((ref, id) {
      final parts = id.split('_');
      final hskLevel = parts.isNotEmpty
          ? parts[0].replaceFirst(RegExp(r'^[hH]'), '')
          : '';
      final lesson = parts.length > 1 ? parts[1] : '';
      return ref
          .read(lessonRepositoryProvider)
          .getLessonTranslations(hskLevel, lesson);
    });

/// The advanced pinyin matrix, loaded from the bundled asset.
final advancedPinyinProvider = FutureProvider<AdvancedPinyinData>((ref) async {
  final raw = await rootBundle.loadString(
    'assets/pinyin/advanced_pinyin_data.json',
  );
  return AdvancedPinyinData.fromJson(jsonDecode(raw) as Map<String, dynamic>);
});
