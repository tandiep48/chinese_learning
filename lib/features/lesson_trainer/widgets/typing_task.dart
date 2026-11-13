/// Lesson trainer — the typing task.
///
/// Ported from `TypingTask.tsx`: the Chinese sentence is shown as the prompt and
/// the learner types it; the answer auto-submits once it matches (the Check
/// button or the keyboard's done action submits whatever is typed). A wrong/
/// skipped answer tints the prompt card red and reveals the correct sentence
/// (with pinyin). Per-character glow is simplified to the whole-prompt reveal
/// shown in the approved mockup.
library;

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../data/answer_match.dart';
import '../data/models/lesson_task.dart';
import '../styles/lesson_trainer_styles.dart';
import 'task_contract.dart';
import 'task_instruction.dart';
import 'trainer_bottom_bar.dart';

class TypingTask extends StatefulWidget {
  const TypingTask({
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
  State<TypingTask> createState() => _TypingTaskState();
}

class _TypingTaskState extends State<TypingTask> {
  final _controller = TextEditingController();
  bool _answered = false;
  bool _correct = false;
  late final int _start = DateTime.now().millisecondsSinceEpoch;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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

  void _onChanged(String value) {
    if (_answered) return;
    if (answersMatch(value, widget.task.correctAnswer)) {
      _commit(value, true);
    } else {
      setState(() {}); // refresh the Check button's enabled state
    }
  }

  void _check() {
    final v = _controller.text.trim();
    if (v.isEmpty || _answered) return;
    _commit(v, answersMatch(v, widget.task.correctAnswer));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final task = widget.task;
    final showError = _answered && !_correct;
    final canCheck = _controller.text.trim().isNotEmpty;

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
                    icon: Icons.keyboard_outlined,
                    text: l10n.lessonInstructionTyping,
                  ),
                  LessonTrainerStyles.instructionGap,
                  Container(
                    decoration: LessonTrainerStyles.promptCardDecoration(
                      error: showError,
                    ),
                    padding: LessonTrainerStyles.promptCardPadding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          task.content,
                          textAlign: TextAlign.center,
                          style: LessonTrainerStyles.promptSentenceStyle,
                        ),
                        LessonTrainerStyles.promptInputGap,
                        TextField(
                          controller: _controller,
                          enabled: !_answered,
                          autofocus: true,
                          textInputAction: TextInputAction.done,
                          style: LessonTrainerStyles.typingInputStyle,
                          cursorColor: BrandColors.navTeal,
                          decoration: LessonTrainerStyles.typingInputDecoration(
                            l10n.lessonTypingPlaceholder,
                          ),
                          onChanged: _onChanged,
                          onSubmitted: (_) => _check(),
                        ),
                        if (showError) ...[
                          LessonTrainerStyles.feedbackGap,
                          Text(
                            '✕ ${task.correctAnswer}'
                            '${task.pinyin != null && task.pinyin!.isNotEmpty ? ' (${task.pinyin})' : ''}',
                            textAlign: TextAlign.center,
                            style: LessonTrainerStyles.correctionStyle,
                          ),
                        ] else if (_answered &&
                            task.pinyin != null &&
                            task.pinyin!.isNotEmpty) ...[
                          LessonTrainerStyles.feedbackGap,
                          Text(
                            task.pinyin!,
                            textAlign: TextAlign.center,
                            style: LessonTrainerStyles.pinyinRevealStyle,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        TrainerBottomBar(
          exitLabel: l10n.milestoneQuit,
          onExit: widget.onExit,
          primaryLabel: _answered ? l10n.trainerNext : l10n.trainerCheck,
          onPrimary: _answered ? widget.onAdvance : (canCheck ? _check : null),
        ),
      ],
    );
  }
}
