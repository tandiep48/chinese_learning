/// Practice module — the type-4 reorder chips.
///
/// Ported from `question-types/Reorder.tsx`. Chips move between a pool and the
/// answer row by tapping; the shuffle order is fixed at session load (held in
/// [GroupUIState.chipShuffle]) so rendering stays pure.
library;

import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../data/group_state.dart';
import '../data/models/practice_question.dart';
import '../data/practice_engine.dart';
import '../styles/practice_styles.dart';
import 'group_props.dart';

class ReorderChips extends StatelessWidget {
  const ReorderChips({
    super.key,
    required this.q,
    required this.blockId,
    required this.state,
    required this.onToggle,
  });

  final PracticeQuestion q;
  final String blockId;
  final GroupUIState state;
  final ToggleCb onToggle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final order = state.chipOrder[blockId] ?? const <String>[];
    final shuffle = state.chipShuffle[blockId] ?? q.options.keys.toList();
    final inAnswer = order.toSet();
    final isCorrect = answersMatch(state.userAnswers[blockId], q.answer);
    final pool = shuffle.where((k) => !inAnswer.contains(k)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.practiceYourOrder, style: PracticeStyles.reorderLabelStyle),
        PracticeStyles.gap8,
        _tray(order, isCorrect, inAnswer: true),
        PracticeStyles.gap12,
        Text(
          l10n.practiceSentencesClickAdd,
          style: PracticeStyles.reorderLabelStyle,
        ),
        PracticeStyles.gap8,
        _tray(pool, isCorrect, inAnswer: false),
      ],
    );
  }

  Widget _tray(List<String> keys, bool isCorrect, {required bool inAnswer}) {
    return Container(
      width: double.infinity,
      decoration: PracticeStyles.chipTrayDecoration,
      padding: PracticeStyles.chipTrayPadding,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final key in keys)
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: state.checked ? null : () => onToggle(blockId, key),
                child: Container(
                  decoration: PracticeStyles.chipDecoration(
                    inAnswer: inAnswer,
                    checked: state.checked,
                    correct: isCorrect,
                  ),
                  padding: PracticeStyles.chipPadding,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(key, style: PracticeStyles.chipKeyStyle),
                      PracticeStyles.wGap8,
                      Text(
                        (q.options[key] ?? '').toString(),
                        style: PracticeStyles.chipTextStyle,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
