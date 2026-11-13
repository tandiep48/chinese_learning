/// Profile module — Riverpod reads for the statistics sections.
///
/// The learned-vocab list paginates in the screen itself (it calls the
/// repository directly for "load more"); these three cover the one-shot reads.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/activity_day.dart';
import '../data/models/global_stats.dart';
import '../data/profile_repository.dart';

final globalStatsProvider = FutureProvider<GlobalStats>((ref) {
  return ref.read(profileRepositoryProvider).getGlobalStats();
});

final learnedWordsDaysProvider = FutureProvider<List<LearnedWordsDay>>((ref) {
  return ref.read(profileRepositoryProvider).getLearnedWordsLast3Days();
});

final timeLearnedDaysProvider = FutureProvider<List<TimeLearnedDay>>((ref) {
  return ref.read(profileRepositoryProvider).getTimeLearnedLast3Days();
});
