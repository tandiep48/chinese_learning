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

/// `typing` records as "typing"; `reading` records as "meaning"; `listen`
/// records as "listen" (the web `MATCH_CONFIG` `db` values).
const Map<String, String> vocabActivityDb = {
  'typing': 'typing',
  'reading': 'meaning',
  'listen': 'listen',
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

/// Pinyin identity for the homophone check (case/space-insensitive, tones kept);
/// blank pinyin falls back to the word so distinct words never clash.
String pinyinKey(TrainerWord row) {
  final p = row.pinyin.toLowerCase().replaceAll(RegExp(r'\s+'), '');
  return p.isNotEmpty ? p : '__${row.word}';
}

List<int> _balancedSizes(int n, int k) {
  final base = n ~/ k;
  var rem = n % k;
  return [for (var i = 0; i < k; i++) base + (rem-- > 0 ? 1 : 0)];
}

/// Group so no group repeats a [keyFn] value. Homophones (same pinyin) sound
/// identical, so a listening group holding two of them has no distinguishable
/// answer; the group count grows to max(ceil(n/5), maxFrequency) and the most
/// constrained words are placed first. Ported from `buildGroupsAvoidingKey`.
List<List<TrainerWord>> buildGroupsAvoidingKey(
  List<TrainerWord> rows,
  String Function(TrainerWord) keyFn,
) {
  final shuffled = _shuffle(rows);
  final n = shuffled.length;
  if (n == 0) return const [];

  final freq = <String, int>{};
  for (final r in shuffled) {
    final k = keyFn(r);
    freq[k] = (freq[k] ?? 0) + 1;
  }
  final maxFreq = freq.values.fold(0, (a, b) => a > b ? a : b);
  final groupCount = [
    (n / vocabGroupSize).ceil(),
    maxFreq,
    1,
  ].reduce((a, b) => a > b ? a : b);
  final sizes = _balancedSizes(n, groupCount);
  final ordered = [...shuffled]
    ..sort((a, b) => freq[keyFn(b)]! - freq[keyFn(a)]!);
  final groups = List.generate(groupCount, (_) => <TrainerWord>[]);

  int emptiestWithRoom(bool Function(List<TrainerWord>) allow) {
    var best = -1;
    for (var idx = 0; idx < groups.length; idx++) {
      final g = groups[idx];
      if (g.length >= sizes[idx] || !allow(g)) continue;
      if (best == -1 || g.length < groups[best].length) best = idx;
    }
    return best;
  }

  for (final row in ordered) {
    final key = keyFn(row);
    var slot = emptiestWithRoom((g) => !g.any((r) => keyFn(r) == key));
    if (slot == -1) slot = emptiestWithRoom((_) => true);
    groups[slot].add(row);
  }
  return groups;
}

/// Build the interleaved activity list. Defaults to all three skills in the web
/// order (typing → listen → reading); [types] restricts it to a chosen subset
/// (the Vocab section's train-type picker). The `listen` match pairs audio →
/// meaning, so its groups avoid same-pinyin homophones.
List<VocabActivity> buildActivities(
  List<TrainerWord> rows, {
  List<String>? types,
}) {
  const supported = ['typing', 'listen', 'reading'];
  final selected = types == null
      ? supported
      : supported.where(types.contains).toList();
  final effective = selected.isEmpty ? supported : selected;
  if (rows.isEmpty) return const [];

  final groupsByType = [
    for (final type in effective)
      (
        type: type,
        groups: type == 'listen'
            ? buildGroupsAvoidingKey(rows, pinyinKey)
            : _buildGroups(_shuffle(rows)),
      ),
  ];
  final roundCount = groupsByType
      .map((g) => g.groups.length)
      .fold(0, (a, b) => a > b ? a : b);

  final list = <VocabActivity>[];
  for (var round = 0; round < roundCount; round++) {
    for (final entry in groupsByType) {
      if (round < entry.groups.length) {
        list.add(
          VocabActivity(
            groupIndex: round,
            type: entry.type,
            words: entry.groups[round],
          ),
        );
      }
    }
  }
  return list;
}
