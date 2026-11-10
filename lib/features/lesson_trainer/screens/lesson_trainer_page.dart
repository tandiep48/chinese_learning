/// Lesson trainer — the graded session runner (milestone step 6).
///
/// Ported from `LessonTrainerPage` + `useLessonTrainer`: starts a part session
/// (`POST /api/lesson/start`), walks its tasks rendering the matching task
/// widget, logs each answer (`/submit`), then on the last task saves the score
/// (`/part-complete`) and shows the recap. Retry re-runs the missed tasks.
/// Listening tasks need audio (Slice R0) and are filtered out for now.
///
/// Embedded in the milestone: [onExit] leaves the part, [onFinished] fires once
/// the round is scored and the learner taps Continue on the recap, so the
/// milestone can advance.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/loading_view.dart';
import '../data/lesson_trainer_repository.dart';
import '../data/missed_task.dart';
import '../data/models/lesson_task.dart';
import '../styles/lesson_trainer_styles.dart';
import '../widgets/choice_task.dart';
import '../widgets/lesson_trainer_recap.dart';
import '../widgets/reorder_task.dart';
import '../widgets/typing_task.dart';

enum _Screen { loading, blocked, training, complete }

class LessonTrainerPage extends ConsumerStatefulWidget {
  const LessonTrainerPage({
    super.key,
    required this.passageId,
    required this.onExit,
    required this.onFinished,
  });

  final String passageId;
  final VoidCallback onExit;
  final VoidCallback onFinished;

  @override
  ConsumerState<LessonTrainerPage> createState() => _LessonTrainerPageState();
}

class _LessonTrainerPageState extends ConsumerState<LessonTrainerPage> {
  _Screen _screen = _Screen.loading;
  String? _blockedMessage;
  int _sessionId = 0;
  List<LessonTask> _tasks = const [];
  int _index = 0;
  final List<MissedTask> _missed = [];
  int _total = 0;
  int _correct = 0;

  @override
  void initState() {
    super.initState();
    _start();
  }

  LessonTrainerRepository get _repo =>
      ref.read(lessonTrainerRepositoryProvider);

  Future<void> _start() async {
    try {
      final session = await _repo.startSession(widget.passageId);
      // Listening tasks need audio (Slice R0); drop them for now.
      final tasks =
          session.tasks.where((t) => t.type != 'listening').toList();
      if (!mounted) return;
      if (tasks.isEmpty) {
        setState(() {
          _screen = _Screen.blocked;
          _blockedMessage = AppLocalizations.of(context).trainerNoTasks;
        });
        return;
      }
      setState(() {
        _sessionId = session.sessionId;
        _tasks = tasks;
        _total = tasks.length;
        _index = 0;
        _missed.clear();
        _screen = _Screen.training;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _screen = _Screen.blocked;
        _blockedMessage = AppLocalizations.of(context).trainerLoadFailed;
      });
    }
  }

  void _onResolved(
      LessonTask task, String answer, bool correct, bool skipped, int ms) {
    if (!correct) _missed.add(MissedTask(task, answer));
    _repo.submitAnswer(
      sessionId: _sessionId,
      task: task,
      userAnswer: answer,
      isCorrect: correct,
      skipped: skipped,
      responseMs: ms,
    );
  }

  void _advance() {
    if (_index + 1 >= _tasks.length) {
      _finish();
    } else {
      setState(() => _index++);
    }
  }

  Future<void> _finish() async {
    _correct = (_total - _missed.length).clamp(0, _total);
    await _repo.completePart(
      passageId: widget.passageId,
      total: _total,
      correct: _correct,
    );
    if (!mounted) return;
    setState(() => _screen = _Screen.complete);
  }

  void _retryMissed() {
    final retry = _missed.map((m) => m.task).toList()..shuffle();
    setState(() {
      _tasks = retry;
      _total = retry.length;
      _index = 0;
      _missed.clear();
      _screen = _Screen.training;
    });
  }

  Widget _taskWidget(LessonTask task) {
    final key = ValueKey('task-$_index');
    switch (task.type) {
      case 'typing':
        return TypingTask(
          key: key,
          task: task,
          onResolved: (a, c, s, ms) => _onResolved(task, a, c, s, ms),
          onAdvance: _advance,
          onExit: widget.onExit,
        );
      case 'reorder':
        return ReorderTask(
          key: key,
          task: task,
          onResolved: (a, c, s, ms) => _onResolved(task, a, c, s, ms),
          onAdvance: _advance,
          onExit: widget.onExit,
        );
      default: // meaning (listening filtered out)
        return ChoiceTask(
          key: key,
          task: task,
          onResolved: (a, c, s, ms) => _onResolved(task, a, c, s, ms),
          onAdvance: _advance,
          onExit: widget.onExit,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    switch (_screen) {
      case _Screen.loading:
        return const Center(child: LoadingView());
      case _Screen.blocked:
        return Center(
          child: EmptyState(
            icon: Icons.inbox_outlined,
            title: _blockedMessage ?? l10n.trainerNoTasks,
          ),
        );
      case _Screen.complete:
        return LessonTrainerRecap(
          missed: List.unmodifiable(_missed),
          total: _total,
          correct: _correct,
          onRetry: _retryMissed,
          onDone: widget.onFinished,
          onExit: widget.onExit,
        );
      case _Screen.training:
        return Column(
          children: [
            Padding(
              padding: LessonTrainerStyles.progressPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: _total == 0 ? 0 : _index / _total,
                      minHeight: LessonTrainerStyles.progressHeight,
                      backgroundColor: LessonTrainerStyles.progressTrack,
                      valueColor: const AlwaysStoppedAnimation(
                          LessonTrainerStyles.progressFill),
                    ),
                  ),
                  LessonTrainerStyles.progressCounterGap,
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      l10n.trainerTaskCounter(_index + 1, _total),
                      style: LessonTrainerStyles.counterStyle,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: _taskWidget(_tasks[_index])),
          ],
        );
    }
  }
}
