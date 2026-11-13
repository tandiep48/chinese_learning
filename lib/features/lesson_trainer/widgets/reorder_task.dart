/// Lesson trainer — the sentence-reorder task.
///
/// Ported from `ReorderTask.tsx`: tap a source chip to append it to the answer
/// row (tap a placed chip to send it back); the answer auto-submits once the row
/// matches the target order. The Check button submits the current order. A
/// wrong/skipped answer reveals the correct sentence and locks the chips.
/// Drag-to-reposition is omitted (tap is the primary mobile interaction).
library;

import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../data/answer_match.dart';
import '../data/models/lesson_task.dart';
import '../styles/lesson_trainer_styles.dart';
import 'task_contract.dart';
import 'task_instruction.dart';
import 'trainer_bottom_bar.dart';

class _Chip {
  const _Chip(this.id, this.token);
  final int id;
  final String token;
}

class ReorderTask extends StatefulWidget {
  const ReorderTask({
    super.key,
    required this.task,
    required this.onResolved,
    required this.onAdvance,
    required this.onExit,
  });

  final LessonTask task;
  final TaskResolved onResolved;
  final VoidCallback onAdvance;
  final VoidCallback onExit;

  @override
  State<ReorderTask> createState() => _ReorderTaskState();
}

class _ReorderTaskState extends State<ReorderTask> {
  late List<_Chip> _source;
  final List<_Chip> _target = [];
  bool _answered = false;
  bool _correct = false;
  late final int _start = DateTime.now().millisecondsSinceEpoch;

  @override
  void initState() {
    super.initState();
    final presented = widget.task.shuffledTokens.isNotEmpty
        ? widget.task.shuffledTokens
        : widget.task.tokens;
    _source = [
      for (var i = 0; i < presented.length; i++) _Chip(i, presented[i]),
    ];
  }

  void _commit(String answer, bool correct) {
    if (_answered) return;
    setState(() {
      _answered = true;
      _correct = correct;
    });
    widget.onResolved(
      answer,
      correct,
      false,
      DateTime.now().millisecondsSinceEpoch - _start,
    );
  }

  void _autoCheck() {
    final order = _target.map((c) => c.token).toList();
    if (reorderMatches(order, widget.task.tokens)) {
      _commit(order.join(), true);
    }
  }

  void _tap(_Chip chip, {required bool inTarget}) {
    if (_answered) return;
    setState(() {
      if (inTarget) {
        _target.remove(chip);
        _source.add(chip);
      } else {
        _source.remove(chip);
        _target.add(chip);
      }
    });
    _autoCheck();
  }

  void _check() {
    if (_answered || _target.isEmpty) return;
    final order = _target.map((c) => c.token).toList();
    _commit(order.join(), reorderMatches(order, widget.task.tokens));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final showError = _answered && !_correct;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: LessonTrainerStyles.contentPadding,
            child: Container(
              decoration: LessonTrainerStyles.taskCardDecoration,
              padding: LessonTrainerStyles.taskCardPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TaskInstruction(
                    icon: Icons.swap_horiz,
                    text: l10n.lessonInstructionReorder,
                  ),
                  LessonTrainerStyles.instructionGap,
                  Text(
                    l10n.lessonYourSentence,
                    style: LessonTrainerStyles.reorderLabelStyle,
                  ),
                  LessonTrainerStyles.reorderRowGap,
                  Container(
                    constraints: const BoxConstraints(
                      minHeight: LessonTrainerStyles.reorderTargetMinHeight,
                    ),
                    decoration: LessonTrainerStyles.reorderTargetDecoration,
                    padding: LessonTrainerStyles.reorderTargetPadding,
                    child: _ChipWrap(
                      chips: _target,
                      onTap: (c) => _tap(c, inTarget: true),
                    ),
                  ),
                  LessonTrainerStyles.reorderSectionGap,
                  Text(
                    l10n.lessonAvailableWords,
                    style: LessonTrainerStyles.reorderLabelStyle,
                  ),
                  LessonTrainerStyles.reorderRowGap,
                  _ChipWrap(
                    chips: _source,
                    onTap: (c) => _tap(c, inTarget: false),
                  ),
                  if (showError) ...[
                    LessonTrainerStyles.feedbackGap,
                    Text(
                      '${l10n.lessonCorrectAnswerLabel} ${widget.task.correctAnswer}',
                      style: LessonTrainerStyles.correctionStyle,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        TrainerBottomBar(
          exitLabel: l10n.milestoneQuit,
          onExit: widget.onExit,
          primaryLabel: _answered ? l10n.trainerNext : l10n.trainerCheck,
          onPrimary: _answered
              ? widget.onAdvance
              : (_target.isEmpty ? null : _check),
        ),
      ],
    );
  }
}

class _ChipWrap extends StatelessWidget {
  const _ChipWrap({required this.chips, required this.onTap});

  final List<_Chip> chips;
  final void Function(_Chip chip) onTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: LessonTrainerStyles.chipSpacing,
      runSpacing: LessonTrainerStyles.chipSpacing,
      children: [
        for (final chip in chips)
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => onTap(chip),
              child: Container(
                decoration: LessonTrainerStyles.chipDecoration,
                padding: LessonTrainerStyles.chipPadding,
                child: Text(
                  chip.token,
                  style: LessonTrainerStyles.chipTextStyle,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
