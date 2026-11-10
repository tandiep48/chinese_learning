/// Practice module — the type-2 group layout.
///
/// Ported from `question-types/Type2Group.tsx`: one shared passage (read or
/// heard) followed by several multiple-choice questions about it.
library;

import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../data/group_state.dart';
import '../data/models/practice_question.dart';
import '../data/practice_engine.dart';
import '../styles/practice_styles.dart';
import 'feedback.dart';
import 'group_props.dart';
import 'option_widgets.dart';
import 'practice_audio.dart';

class Type2Group extends StatelessWidget {
  const Type2Group({
    super.key,
    required this.group,
    required this.state,
    required this.category,
    required this.cb,
  });

  final PracticeGroup group;
  final GroupUIState state;
  final PracticeCategory category;
  final GroupCallbacks cb;

  PracticeQuestion? get _passage {
    for (final q in group.questions) {
      if (q.content != null && q.content!.isNotEmpty) return q;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isListening = group.questions.first.skill == 'listening';
    final passage = _passage;
    final multi = group.questions.length > 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isListening && passage != null && passage.audioKeys.isNotEmpty) ...[
          AudioControl(
            audioKey: passage.audioKeys.first,
            level: passage.level,
            category: category,
            label: l10n.practicePlayPassage,
          ),
          PracticeStyles.gap16,
        ] else if (!isListening && passage?.content != null) ...[
          Text(passage!.content!, style: PracticeStyles.paragraphStyle),
          PracticeStyles.gap16,
        ],
        for (var idx = 0; idx < group.questions.length; idx++)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _block(l10n, idx, isListening, multi),
          ),
      ],
    );
  }

  Widget _block(AppLocalizations l10n, int idx, bool isListening, bool multi) {
    final q = group.questions[idx];
    final blockId = 'q-$idx';
    final blockCorrect = state.checked
        ? answersMatch(state.userAnswers[blockId], q.answer)
        : null;
    final keyIdx = idx == 0 && q.audioKeys.length == 2 ? 1 : 0;

    return Container(
      decoration: PracticeStyles.questionBlockDecoration(correct: blockCorrect),
      padding: PracticeStyles.blockPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (multi) QNum(n: idx + 1),
          if (isListening) ...[
            if (q.audioKeys.isNotEmpty) ...[
              AudioControl(
                audioKey: q.audioKeys[keyIdx],
                level: q.level,
                category: category,
                label: l10n.practiceQuestionNumber(idx + 1),
              ),
              PracticeStyles.gap12,
            ],
          ] else if (q.question != null) ...[
            Text(q.question!, style: PracticeStyles.questionTextStyle),
            PracticeStyles.gap12,
          ],
          MCOptions(
            q: q,
            blockId: blockId,
            state: state,
            onSelect: cb.onSelectMC,
          ),
          AnswerFeedback(
            q: q,
            chosen: state.userAnswers[blockId] ?? '',
            checked: state.checked,
          ),
        ],
      ),
    );
  }
}
