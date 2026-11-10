/// Practice module — the type-6 group layout.
///
/// Ported from `question-types/Type6Group.tsx`: numbered blanks across several
/// sentences drawing from one shared option pool at the bottom. The learner
/// targets a blank, then picks a word; a word already placed anywhere in the
/// group is disabled.
library;

import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../data/group_state.dart';
import '../data/models/practice_question.dart';
import '../data/practice_engine.dart';
import '../styles/practice_styles.dart';
import 'blanked_content.dart';
import 'feedback.dart';
import 'group_props.dart';
import 'practice_audio.dart';

class Type6Group extends StatelessWidget {
  const Type6Group({
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isListening = group.questions.first.skill == 'listening';
    PracticeQuestion? passage;
    for (final q in group.questions) {
      if (q.content != null && q.content!.isNotEmpty) {
        passage = q;
        break;
      }
    }
    final multi = group.questions.length > 1;

    // Shared options across every blank in the group (insertion order).
    final sharedOpts = <String, dynamic>{};
    for (final q in group.questions) {
      sharedOpts.addAll(q.options);
    }
    final usedKeys = <String>{};
    for (final blanks in state.blankState.values) {
      for (final k in blanks.values) {
        if (k.isNotEmpty) usedKeys.add(k);
      }
    }

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
        ],
        for (var idx = 0; idx < group.questions.length; idx++)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _block(idx, isListening, multi),
          ),
        PracticeStyles.gap8,
        Text(
          l10n.practiceChooseFromOptions,
          style: PracticeStyles.groupHeaderStyle,
        ),
        PracticeStyles.gap8,
        _sharedOptions(sharedOpts, usedKeys),
      ],
    );
  }

  Widget _block(int idx, bool isListening, bool multi) {
    final q = group.questions[idx];
    final blockId = 'q-$idx';
    final blockBlanks = state.blankState[blockId] ?? const <int, String>{};
    final fillCount = countBlanks(q.content);
    final fills = List<String?>.generate(fillCount, (i) => blockBlanks[i]);
    final blockCorrect = state.checked
        ? answersMatch(state.userAnswers[blockId], q.answer)
        : null;

    return Container(
      decoration: PracticeStyles.questionBlockDecoration(correct: blockCorrect),
      padding: PracticeStyles.blockPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (multi) QNum(n: idx + 1),
          if (!isListening && q.content != null) ...[
            BlankedContent(
              content: q.content,
              interactive: true,
              fills: fills,
              blockId: blockId,
              activeBlank: state.activeBlank,
              onBlankClick: cb.onBlankClick,
            ),
          ],
          AnswerFeedback(
            q: q,
            chosen: state.userAnswers[blockId] ?? '',
            checked: state.checked,
          ),
        ],
      ),
    );
  }

  Widget _sharedOptions(Map<String, dynamic> sharedOpts, Set<String> usedKeys) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final e in sharedOpts.entries) ...[
          PracticeStyles.optionGap,
          Builder(
            builder: (_) {
              final used = usedKeys.contains(e.key);
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: used || state.checked
                      ? null
                      : () => cb.onAssignT6(e.key),
                  child: Container(
                    decoration: PracticeStyles.optionDecoration(
                      selected: used,
                      checked: false,
                      correct: false,
                      wrong: false,
                    ),
                    padding: PracticeStyles.optionPadding,
                    child: Row(
                      children: [
                        Text(e.key, style: PracticeStyles.optionKeyStyle),
                        PracticeStyles.optionKeyGap,
                        Expanded(
                          child: Text(
                            e.value.toString(),
                            style: PracticeStyles.optionTextStyle,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ],
    );
  }
}
