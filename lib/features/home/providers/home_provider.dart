/// Home module — providers backing the home screen.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/home_repository.dart';
import '../data/models/current_lesson.dart';

/// The resume-lesson card's data. Auto-disposed so it refetches on revisit and
/// can be refreshed with `ref.refresh(currentLessonProvider.future)`.
final currentLessonProvider = FutureProvider.autoDispose<CurrentLesson>((ref) {
  return ref.read(homeRepositoryProvider).getCurrentLesson();
});
