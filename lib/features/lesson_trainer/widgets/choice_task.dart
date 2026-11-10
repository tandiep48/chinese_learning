/// Lesson trainer — the multiple-choice task (meaning).
///
/// Ported from the meaning branch of `ChoiceTask.tsx`: the Chinese sentence with
/// numbered options; tapping an option locks the board, turning the correct
/// option green and a wrong pick red. The listening variant (audio) is deferred
/// with Slice R0 and filtered out of the session for now.
library;

import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../data/answer_match.dart';
import '../data/models/lesson_task.dart';
import '../styles/lesson_trainer_styles.dart';
import 'task_contract.dart';
import 'task_instruction.dart';
import 'trainer_bottom_bar.dart';

class ChoiceTask extends StatefulWidget {
  const ChoiceTask({
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
  State<ChoiceTask> createState() => _ChoiceTaskState();
}

class _ChoiceTaskState extends State<ChoiceTask> {
  bool _answered = false;
  String? _selected;
  late final int _start = DateTime.now().millisecondsSinceEpoch;

  void _commit(String answer, bool correct, bool skipped) {
    if (_answered) return;
    setState(() => _answered = true);
    widget.onResolved(answer, correct, skipped,
        DateTime.now().millisecondsSinceEpoch - _start);
  }

  void _choose(String opt) {
    if (_answered) return;
    setState(() => _selected = opt);
    _commit(opt, answersMatch(opt, widget.task.correctAnswer), false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final task = widget.task;
    final options = task.options;

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
                    icon: Icons.menu_book_outlined,
                    text: l10n.lessonInstructionMeaning,
                  ),
                  LessonTrainerStyles.instructionGap,
                  Text(
                    task.content,
                    textAlign: TextAlign.center,
                    style: LessonTrainerStyles.promptSentenceStyle,
                  ),
                  LessonTrainerStyles.instructionGap,
                  for (var i = 0; i < options.length; i++) ...[
                    if (i > 0) LessonTrainerStyles.optionGap,
                    _Option(
                      index: i,
                      label: options[i],
                      answered: _answered,
                      isCorrectOption:
                          answersMatch(options[i], task.correctAnswer),
                      isSelected: options[i] == _selected,
                      onTap: () => _choose(options[i]),
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
          primaryLabel: _answered ? l10n.trainerNext : l10n.trainerSkip,
          onPrimary: _answered
              ? widget.onAdvance
              : () => _commit('', false, true),
        ),
      ],
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({
    required this.index,
    required this.label,
    required this.answered,
    required this.isCorrectOption,
    required this.isSelected,
    required this.onTap,
  });

  final int index;
  final String label;
  final bool answered;
  final bool isCorrectOption;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: LessonTrainerStyles.optionRadius,
        onTap: answered ? null : onTap,
        child: Container(
          decoration: LessonTrainerStyles.optionDecoration(
            answered: answered,
            isCorrectOption: isCorrectOption,
            isSelected: isSelected,
          ),
          padding: LessonTrainerStyles.optionPadding,
          child: Row(
            children: [
              Text('${index + 1}', style: LessonTrainerStyles.optionKeyStyle),
              LessonTrainerStyles.optionKeyGap,
              Expanded(
                child: Text(label, style: LessonTrainerStyles.optionTextStyle),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
