/// Vocab trainer — the activity-building engine.
///
/// Ported from `yi-chinese-manage/lib/lessons/vocabTrainer.ts`
/// (`buildActivities`, `buildGroups`, `groupSizes`): the words are worked in
/// small groups, each activity type getting its own independent random grouping,
/// interleaved round by round. This slice ships the two no-audio skills —
/// `typing` (type the word) and `reading` (match word → meaning); the `listen`
/// match needs audio and lands with Slice R0.
library;

import 'dart:math';

import 'trainer_word.dart';

const int vocabGroupSize = 5;

/// `typing` records as "typing"; `reading` records as "meaning" (the web
/// `MATCH_CONFIG.reading.db`).
const Map<String, String> vocabActivityDb = {
  'typing': 'typing',
  'reading': 'meaning',
};

class VocabActivity {
  const VocabActivity({
    required this.groupIndex,
    required this.type,
    required this.words,
  });

  final int groupIndex;
  final String type; // 'typing' | 'reading'
  final List<TrainerWord> words;
}

/// Reported once per word on solve. [dbType] is the recorded answer type
/// ("typing" / "meaning"); [wrongAttempts] marks a word that needed a retry.
typedef VocabRecordFn = void Function(
  TrainerWord row,
  String dbType,
  String answer,
  bool isCorrect,
  int wrongAttempts,
);

List<T> _shuffle<T>(List<T> input) {
  final arr = [...input];
  final rng = Random();
  for (var i = arr.length - 1; i > 0; i--) {
    final j = rng.nextInt(i + 1);
    final tmp = arr[i];
    arr[i] = arr[j];
    arr[j] = tmp;
  }
  return arr;
}

/// Group sizes for `n` words: groups of [vocabGroupSize], avoiding a lone
/// trailing word by borrowing one from the previous group.
List<int> groupSizes(int n) {
  final sizes = <int>[];
  for (var i = 0; i < n; i += vocabGroupSize) {
    sizes.add(min(vocabGroupSize, n - i));
  }
  if (sizes.length > 1 && sizes.last == 1) {
    sizes[sizes.length - 1] = 2;
    sizes[sizes.length - 2] -= 1;
  }
  return sizes;
}

List<List<TrainerWord>> _buildGroups(List<TrainerWord> rows) {
  final sizes = groupSizes(rows.length);
  final groups = <List<TrainerWord>>[];
  var i = 0;
  for (final size in sizes) {
    groups.add(rows.sublist(i, i + size));
    i += size;
  }
  return groups;
}

/// Build the interleaved activity list (typing + reading).
List<VocabActivity> buildActivities(List<TrainerWord> rows) {
  const types = ['typing', 'reading'];
  if (rows.isEmpty) return const [];

  final groupsByType = [
    for (final type in types) (type: type, groups: _buildGroups(_shuffle(rows))),
  ];
  final roundCount =
      groupsByType.map((g) => g.groups.length).fold(0, (a, b) => a > b ? a : b);

  final list = <VocabActivity>[];
  for (var round = 0; round < roundCount; round++) {
    for (final entry in groupsByType) {
      if (round < entry.groups.length) {
        list.add(VocabActivity(
          groupIndex: round,
          type: entry.type,
          words: entry.groups[round],
        ));
      }
    }
  }
  return list;
}
