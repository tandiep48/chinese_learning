/// Practice module — the per-group answer state and its pure transitions.
///
/// Ported from `yi-chinese-manage/lib/practice/groupState.ts`. The runner holds
/// a [GroupUIState] per group and applies these value→value transitions; each is
/// a no-op once the group is [checked], matching the engine, which froze its
/// inputs at that point.
library;

import 'dart:math';

import 'practice_engine.dart';
import 'models/practice_question.dart';

final Random _rng = Random();

/// The one active blank in a type-6 group (only one at a time).
class ActiveBlank {
  const ActiveBlank(this.blockId, this.index);

  final String blockId;
  final int index;
}

/// The result of [GroupUIState.check]: the frozen state and the count to add.
class CheckResult {
  const CheckResult(this.state, this.correct);

  final GroupUIState state;
  final int correct;
}

class GroupUIState {
  const GroupUIState({
    required this.userAnswers,
    required this.chipOrder,
    required this.chipShuffle,
    required this.blankState,
    required this.activeBlank,
    required this.checked,
    required this.correctCount,
    required this.correctTotal,
    required this.startTime,
    required this.perQuestionTimeMs,
  });

  final Map<String, String> userAnswers; // blockId -> selected key(s)
  final Map<String, List<String>> chipOrder; // type 4: blockId -> ordered keys
  final Map<String, List<String>> chipShuffle; // type 4: fixed shuffled pool
  final Map<String, Map<int, String>> blankState; // type 6: blockId -> {i: key}
  final ActiveBlank? activeBlank;
  final bool checked;
  final int correctCount;
  final int correctTotal;
  final int startTime;
  final int perQuestionTimeMs;

  factory GroupUIState.fresh(PracticeGroup group) {
    final chipShuffle = <String, List<String>>{};
    for (var idx = 0; idx < group.questions.length; idx++) {
      final q = group.questions[idx];
      if (q.type == 4) {
        // Shuffle once at load so render stays pure.
        chipShuffle['q-$idx'] = q.options.keys.toList()..shuffle(_rng);
      }
    }
    return GroupUIState(
      userAnswers: const {},
      chipOrder: const {},
      chipShuffle: chipShuffle,
      blankState: const {},
      activeBlank: null,
      checked: false,
      correctCount: 0,
      correctTotal: 0,
      startTime: 0,
      perQuestionTimeMs: 0,
    );
  }

  GroupUIState _copy({
    Map<String, String>? userAnswers,
    Map<String, List<String>>? chipOrder,
    Map<String, Map<int, String>>? blankState,
    ActiveBlank? activeBlank,
    bool clearActiveBlank = false,
    bool? checked,
    int? correctCount,
    int? correctTotal,
    int? startTime,
    int? perQuestionTimeMs,
  }) {
    return GroupUIState(
      userAnswers: userAnswers ?? this.userAnswers,
      chipOrder: chipOrder ?? this.chipOrder,
      chipShuffle: chipShuffle,
      blankState: blankState ?? this.blankState,
      activeBlank: clearActiveBlank ? null : (activeBlank ?? this.activeBlank),
      checked: checked ?? this.checked,
      correctCount: correctCount ?? this.correctCount,
      correctTotal: correctTotal ?? this.correctTotal,
      startTime: startTime ?? this.startTime,
      perQuestionTimeMs: perQuestionTimeMs ?? this.perQuestionTimeMs,
    );
  }

  /// Stamp the group's start time (the runner calls this when a group mounts).
  GroupUIState withStartTime(int millis) => _copy(startTime: millis);

  /// Plain multiple choice: one answer per block, replacing what was there.
  GroupUIState selectMC(String blockId, String key) {
    if (checked) return this;
    return _copy(userAnswers: {...userAnswers, blockId: key});
  }

  /// Unique-key-per-row selection (t5 grouped layouts). Picking the same key
  /// again clears the row, freeing that key for another row.
  GroupUIState selectKey(String blockId, String key) {
    if (checked) return this;
    final ua = {...userAnswers};
    if (ua[blockId] == key) {
      ua.remove(blockId);
    } else {
      ua[blockId] = key;
    }
    return _copy(userAnswers: ua);
  }

  /// Type 4: chips move between pool and answer row; the answer is the chip
  /// keys in the order they were added.
  GroupUIState toggleChip(String blockId, String key) {
    if (checked) return this;
    final order = [...(chipOrder[blockId] ?? const <String>[])];
    final at = order.indexOf(key);
    if (at >= 0) {
      order.removeAt(at);
    } else {
      order.add(key);
    }
    return _copy(
      chipOrder: {...chipOrder, blockId: order},
      userAnswers: {...userAnswers, blockId: order.join()},
    );
  }

  /// Type 6: target a blank. Only one blank in the group is active at a time.
  GroupUIState focusBlank(String blockId, int index) {
    if (checked) return this;
    return _copy(activeBlank: ActiveBlank(blockId, index));
  }

  /// Type 6: drop the shared option [key] into the active blank, and rebuild
  /// that block's answer from its blanks in index order.
  GroupUIState assignT6(String key) {
    if (checked || activeBlank == null) return this;
    final target = activeBlank!;
    final blockBlanks = {
      ...(blankState[target.blockId] ?? const <int, String>{}),
    };
    blockBlanks[target.index] = key;
    final nextBlankState = {...blankState, target.blockId: blockBlanks};
    final sortedIndexes = blockBlanks.keys.toList()..sort();
    final joined = sortedIndexes.map((i) => blockBlanks[i] ?? '').join();
    return _copy(
      blankState: nextBlankState,
      userAnswers: {...userAnswers, target.blockId: joined},
      clearActiveBlank: true,
    );
  }

  /// Grade the group and freeze it; returns null if already checked. [elapsedMs]
  /// is passed in (not read from a clock) to keep this pure.
  CheckResult? check(PracticeGroup group, int elapsedMs) {
    if (checked) return null;
    final score = scoreGroup(group, userAnswers);
    final denom = group.questions.isEmpty ? 1 : group.questions.length;
    final perQ = (elapsedMs / denom).round();
    return CheckResult(
      _copy(
        checked: true,
        correctCount: score.correct,
        correctTotal: group.questions.length,
        perQuestionTimeMs: perQ,
      ),
      score.correct,
    );
  }
}
