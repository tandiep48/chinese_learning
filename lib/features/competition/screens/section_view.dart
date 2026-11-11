/// Competition — the in-room play screen (web `SectionScreen`).
///
/// The room bar with the task/group counter and the player's live score, the
/// trainer for the room's mode, and the live scoreboard. Vocab rooms resolve and
/// group their words client-side (book rooms fetch the server-frozen pool); lesson
/// rooms walk the task list the server generated at session start. Every answer
/// goes straight out over the socket. Reuses the solo trainers' activity/task
/// widgets, including the listening (audio) skills.
library;

import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../lesson_trainer/data/models/lesson_task.dart';
import '../../lesson_trainer/widgets/choice_task.dart';
import '../../lesson_trainer/widgets/reorder_task.dart';
import '../../lesson_trainer/widgets/typing_task.dart';
import '../../vocab_trainer/data/trainer_word.dart';
import '../../vocab_trainer/data/vocab_activity.dart';
import '../../vocab_trainer/widgets/match_activity.dart';
import '../../vocab_trainer/widgets/typing_activity.dart';
import '../data/models/competition_models.dart';
import '../data/room_logic.dart';
import '../providers/competition_controller.dart';
import '../styles/competition_styles.dart';
import '../widgets/ranking_list.dart';

enum _Status { loading, playing, empty }

class CompetitionSectionView extends StatefulWidget {
  const CompetitionSectionView({super.key, required this.controller});

  final CompetitionController controller;

  @override
  State<CompetitionSectionView> createState() => _CompetitionSectionViewState();
}

class _CompetitionSectionViewState extends State<CompetitionSectionView> {
  CompetitionController get c => widget.controller;

  late final bool _isLesson = c.room?.category == CompetitionCategory.lesson;
  _Status _status = _Status.loading;
  List<VocabActivity> _activities = const [];
  List<LessonTask> _tasks = const [];
  int _index = 0;

  @override
  void initState() {
    super.initState();
    if (_isLesson) {
      _tasks = [...(c.session?.lessonTasks ?? const [])];
      _status = _tasks.isEmpty ? _Status.empty : _Status.playing;
    } else {
      _loadWords();
    }
  }

  Future<void> _loadWords() async {
    final room = c.room;
    final session = c.session;
    if (room == null) {
      setState(() => _status = _Status.empty);
      return;
    }
    final isBook = room.category == CompetitionCategory.book;
    final List<TrainerWord> rows;
    if (isBook) {
      rows = session == null
          ? const []
          : await c.repo.getSessionBookWords(session.id);
    } else {
      rows = await c.repo.resolveWords(room.passageIds);
    }
    if (!mounted) return;
    setState(() {
      if (rows.isEmpty) {
        _status = _Status.empty;
      } else {
        _activities = buildActivities(rows);
        _index = 0;
        _status = _Status.playing;
      }
    });
  }

  void _advanceVocab() {
    if (_index + 1 >= _activities.length) {
      c.finishTrainer();
    } else {
      setState(() => _index++);
    }
  }

  void _advanceLesson() {
    if (_index + 1 >= _tasks.length) {
      c.finishTrainer();
    } else {
      setState(() => _index++);
    }
  }

  void _recordVocab(
    TrainerWord row,
    String dbType,
    String answer,
    bool correct,
    int wrongAttempts,
  ) {
    c.sendVocabAnswer(row.word, dbType, correct, 0, wrongAttempts);
  }

  void _recordLesson(
    LessonTask task,
    String answer,
    bool correct,
    bool skipped,
    int ms,
  ) {
    c.sendLessonAnswer(
      lessonItemKey(task.passageId, task.lineId),
      task.type,
      correct,
      ms,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final room = c.room;
    final myMatches = c.scores.where((s) => s.userId == c.userId);
    final myScore = myMatches.isEmpty ? null : myMatches.first;

    final counterText = _isLesson
        ? (_tasks.isEmpty
              ? ''
              : l10n.trainerTaskCounter(_index + 1, _tasks.length))
        : (_activities.isEmpty
              ? ''
              : l10n.vocabGroupCounter(
                  _activities[_index].groupIndex + 1,
                  _activities.last.groupIndex + 1,
                ));

    return Column(
      children: [
        Padding(
          padding: CompetitionStyles.pagePadding,
          child: Container(
            padding: CompetitionStyles.roomBarPadding,
            decoration: CompetitionStyles.roomBar,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.competitionRoomLabel,
                        style: CompetitionStyles.muted,
                      ),
                      Text(
                        room?.roomCode ?? '',
                        style: CompetitionStyles.roomCode,
                      ),
                    ],
                  ),
                ),
                if (counterText.isNotEmpty) ...[
                  Text(counterText, style: CompetitionStyles.muted),
                  CompetitionStyles.wgap12,
                ],
                Container(
                  padding: CompetitionStyles.scorePillPadding,
                  decoration: CompetitionStyles.scorePill,
                  child: Text(
                    l10n.competitionPoints(myScore?.totalPoints ?? 0),
                    style: CompetitionStyles.scorePillText,
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(child: _trainerBody(l10n)),
        _scoreboard(l10n),
      ],
    );
  }

  Widget _trainerBody(AppLocalizations l10n) {
    if (_status == _Status.loading) {
      return Center(
        child: Text(l10n.competitionLoading, style: CompetitionStyles.muted),
      );
    }
    if (_status == _Status.empty) {
      return Center(
        child: Text(
          _isLesson ? l10n.competitionNoTasks : l10n.competitionNoWords,
          style: CompetitionStyles.muted,
        ),
      );
    }
    if (_isLesson) {
      final task = _tasks[_index];
      final key = ValueKey('ctask-$_index');
      switch (task.type) {
        case 'typing':
          return TypingTask(
            key: key,
            task: task,
            onResolved: (a, correct, skipped, ms) =>
                _recordLesson(task, a, correct, skipped, ms),
            onAdvance: _advanceLesson,
            onExit: c.leaveRoom,
          );
        case 'reorder':
          return ReorderTask(
            key: key,
            task: task,
            onResolved: (a, correct, skipped, ms) =>
                _recordLesson(task, a, correct, skipped, ms),
            onAdvance: _advanceLesson,
            onExit: c.leaveRoom,
          );
        default:
          return ChoiceTask(
            key: key,
            task: task,
            onResolved: (a, correct, skipped, ms) =>
                _recordLesson(task, a, correct, skipped, ms),
            onAdvance: _advanceLesson,
            onExit: c.leaveRoom,
          );
      }
    }

    final activity = _activities[_index];
    final key = ValueKey('cact-$_index');
    if (activity.type == 'typing') {
      return TypingActivity(
        key: key,
        activity: activity,
        onRecord: _recordVocab,
        onAdvance: _advanceVocab,
        onExit: c.leaveRoom,
      );
    }
    return MatchActivity(
      key: key,
      activity: activity,
      onRecord: _recordVocab,
      onAdvance: _advanceVocab,
      onExit: c.leaveRoom,
    );
  }

  Widget _scoreboard(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: CompetitionStyles.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.competitionScoreboard, style: CompetitionStyles.h2),
          CompetitionStyles.gap8,
          RankingList(scores: c.scores),
        ],
      ),
    );
  }
}
