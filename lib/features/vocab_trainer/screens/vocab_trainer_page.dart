/// Vocab trainer — the batch runner (milestone step 3).
///
/// Ported from `VocabTrainerPage` + `useVocabTrainer` (embedded mode): resolves
/// the part's words (`POST /api/vocab/words`), builds the interleaved typing /
/// reading-match activities, walks them one group at a time buffering answers,
/// flushes each group to `POST /api/vocab/submit-batch` on advance, then shows
/// the recap. Retry re-runs the missed words. Listening match needs audio and is
/// deferred (Slice R0). [onFinished] fires when the learner finishes the recap so
/// the milestone can advance.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/loading_view.dart';
import '../data/trainer_word.dart';
import '../data/vocab_activity.dart';
import '../data/vocab_trainer_repository.dart';
import '../styles/vocab_trainer_styles.dart';
import '../widgets/match_activity.dart';
import '../widgets/typing_activity.dart';
import '../widgets/vocab_trainer_recap.dart';

enum _Screen { loading, blocked, training, complete }

class VocabTrainerPage extends ConsumerStatefulWidget {
  const VocabTrainerPage({
    super.key,
    required this.passageId,
    required this.onExit,
    required this.onFinished,
  });

  final String passageId;
  final VoidCallback onExit;
  final VoidCallback onFinished;

  @override
  ConsumerState<VocabTrainerPage> createState() => _VocabTrainerPageState();
}

class _VocabTrainerPageState extends ConsumerState<VocabTrainerPage> {
  _Screen _screen = _Screen.loading;
  List<VocabActivity> _activities = const [];
  int _index = 0;
  final List<VocabRecord> _pending = [];
  final List<TrainerWord> _missed = [];
  int _total = 0;
  int _correct = 0;
  late final int _sessionId = DateTime.now().millisecondsSinceEpoch;

  VocabTrainerRepository get _repo => ref.read(vocabTrainerRepositoryProvider);

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    final rows = await _repo.resolveWords(widget.passageId);
    if (!mounted) return;
    if (rows.isEmpty) {
      setState(() => _screen = _Screen.blocked);
      return;
    }
    setState(() {
      _activities = buildActivities(rows);
      _index = 0;
      _total = 0;
      _correct = 0;
      _missed.clear();
      _pending.clear();
      _screen = _Screen.training;
    });
  }

  void _record(
      TrainerWord row, String dbType, String answer, bool correct, int wrongAttempts) {
    final clean = correct && wrongAttempts == 0;
    _total += 1;
    if (clean) {
      _correct += 1;
    } else {
      _missed.add(row);
    }
    _pending.add(VocabRecord(
      type: dbType,
      word: row.word,
      roundNum: 1,
      userAnswer: answer,
      isCorrect: clean,
      pinyin: row.pinyin,
      meaningEn: row.meaningEn,
    ));
  }

  void _flush() {
    if (_pending.isEmpty) return;
    final batch = [..._pending];
    _pending.clear();
    _repo.submitBatch(_sessionId, batch);
  }

  void _advance() {
    _flush();
    if (_index + 1 >= _activities.length) {
      setState(() => _screen = _Screen.complete);
    } else {
      setState(() => _index++);
    }
  }

  void _retry() {
    final seen = <String>{};
    final unique = <TrainerWord>[];
    for (final w in _missed) {
      if (seen.add(w.word)) unique.add(w);
    }
    if (unique.isEmpty) return;
    setState(() {
      _activities = buildActivities(unique);
      _index = 0;
      _total = 0;
      _correct = 0;
      _missed.clear();
      _pending.clear();
      _screen = _Screen.training;
    });
  }

  Widget _activityWidget(VocabActivity activity) {
    final key = ValueKey('act-$_index');
    if (activity.type == 'typing') {
      return TypingActivity(
        key: key,
        activity: activity,
        onRecord: _record,
        onAdvance: _advance,
        onExit: widget.onExit,
      );
    }
    return MatchActivity(
      key: key,
      activity: activity,
      onRecord: _record,
      onAdvance: _advance,
      onExit: widget.onExit,
    );
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
            title: l10n.vocabNoWords,
          ),
        );
      case _Screen.complete:
        final seen = <String>{};
        final uniqueMissed = <TrainerWord>[];
        for (final w in _missed) {
          if (seen.add(w.word)) uniqueMissed.add(w);
        }
        return VocabTrainerRecap(
          missed: uniqueMissed,
          total: _total,
          correct: _correct,
          onRetry: _retry,
          onDone: widget.onFinished,
          onExit: widget.onExit,
        );
      case _Screen.training:
        final activity = _activities[_index];
        final totalGroups =
            _activities.isEmpty ? 1 : _activities.last.groupIndex + 1;
        return Column(
          children: [
            Padding(
              padding: VocabTrainerStyles.progressPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: _activities.isEmpty ? 0 : _index / _activities.length,
                      minHeight: VocabTrainerStyles.progressHeight,
                      backgroundColor: VocabTrainerStyles.progressTrack,
                      valueColor:
                          const AlwaysStoppedAnimation(BrandColors.navTeal),
                    ),
                  ),
                  VocabTrainerStyles.progressCounterGap,
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      l10n.vocabGroupCounter(activity.groupIndex + 1, totalGroups),
                      style: VocabTrainerStyles.counterStyle,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: _activityWidget(activity)),
          ],
        );
    }
  }
}
