/// Practice module — the practice/exam runner (milestone-independent).
///
/// Ported from `PracticeRunner.tsx` + `usePracticeEngine.ts`: loads a session
/// (`/api/practice/*`), holds per-group answer state across navigation, scores on
/// Check, and submits on Finish. Usable standalone (via the `/practice` route) or
/// embedded (pass [PracticeOptions.onExit] / [onFinished]). The two desktop
/// shells collapse to one phone layout: topbar + question card + nav.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/loading_view.dart';
import '../data/group_state.dart';
import '../data/models/practice_answer_row.dart';
import '../data/models/practice_question.dart';
import '../data/practice_engine.dart';
import '../data/practice_repository.dart';
import '../styles/practice_styles.dart';
import '../widgets/group_props.dart';
import '../widgets/practice_audio.dart';
import '../widgets/question_group.dart';

/// How the runner is parameterised (a subset of the web `PracticeEngineOptions`).
class PracticeOptions {
  const PracticeOptions({
    required this.category,
    this.number,
    this.lessonId,
    this.progress,
    this.multi = false,
    this.items,
    this.onExit,
    this.onFinished,
  });

  final PracticeCategory category;
  final String? number; // hsk level (absent in multi mode)
  final String? lessonId;
  final String? progress; // deep-link to one progress group
  final bool multi;
  final List<PracticeMultiItem>? items;
  final VoidCallback? onExit;
  final VoidCallback? onFinished;
}

enum _Screen { loading, practice, result }

class PracticeRunnerPage extends ConsumerStatefulWidget {
  const PracticeRunnerPage({super.key, required this.options});

  final PracticeOptions options;

  @override
  ConsumerState<PracticeRunnerPage> createState() => _PracticeRunnerPageState();
}

class _PracticeRunnerPageState extends ConsumerState<PracticeRunnerPage> {
  _Screen _screen = _Screen.loading;
  bool _error = false;
  bool _submitting = false;
  List<PracticeGroup> _groups = const [];
  List<GroupUIState> _states = [];
  int _index = 0;
  int _score = 0;
  int _sessionId = 0;
  ({int score, int total, ResultTier tier})? _result;

  PracticeOptions get _opts => widget.options;
  PracticeRepository get _repo => ref.read(practiceRepositoryProvider);

  int _nowMs() => DateTime.now().millisecondsSinceEpoch;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    // Best-effort: stop any clip still playing when the runner leaves.
    ref.read(practiceAudioProvider).stop();
    super.dispose();
  }

  void _fail() {
    if (!mounted) return;
    setState(() {
      _error = true;
      _screen = _Screen.loading;
    });
  }

  Future<void> _load() async {
    try {
      List<PracticeGroup> loaded;
      if (_opts.multi) {
        final queue = _opts.items ?? const <PracticeMultiItem>[];
        if (queue.isEmpty) return _fail();
        loaded = (await _repo.getMulti(queue)).groups;
      } else if (_opts.progress != null && _opts.progress!.isNotEmpty) {
        loaded = [
          await _repo.getProgressGroup(
            _opts.number ?? '',
            _opts.lessonId ?? '',
            _opts.progress!,
            _opts.category,
          ),
        ];
      } else {
        loaded = (await _repo.getLesson(
          _opts.number ?? '',
          _opts.lessonId ?? '',
          _opts.category,
        )).groups;
      }
      if (!mounted) return;
      if (loaded.isEmpty) return _fail();
      final states = loaded.map(GroupUIState.fresh).toList();
      states[0] = states[0].withStartTime(_nowMs());
      setState(() {
        _groups = loaded;
        _states = states;
        _index = 0;
        _score = 0;
        _error = false;
        _sessionId = _nowMs();
        _screen = _Screen.practice;
      });
    } catch (_) {
      _fail();
    }
  }

  void _updateCurrent(GroupUIState Function(GroupUIState) fn) {
    setState(() => _states[_index] = fn(_states[_index]));
  }

  void _visit(int i) {
    if (i < 0 || i >= _groups.length) return;
    ref.read(practiceAudioProvider).stop();
    setState(() {
      _index = i;
      if (_states[i].startTime == 0) {
        _states[i] = _states[i].withStartTime(_nowMs());
      }
    });
  }

  void _check() {
    final s = _states[_index];
    final group = _groups[_index];
    final start = s.startTime == 0 ? _nowMs() : s.startTime;
    final elapsed = (_nowMs() - start).clamp(0, 1 << 31).toInt();
    final res = s.check(group, elapsed);
    if (res == null) return;
    setState(() {
      _states[_index] = res.state;
      _score += res.correct;
    });
  }

  Future<void> _finish() async {
    final checked = _states.map((s) => s.checked).toList();
    if (!allChecked(checked)) {
      final i = firstUncheckedAfter(checked, -1);
      if (i != -1) _visit(i);
      return;
    }
    setState(() => _submitting = true);
    ref.read(practiceAudioProvider).stop();
    final answers = <PracticeAnswerRow>[];
    for (var i = 0; i < _groups.length; i++) {
      answers.addAll(
        buildAnswerRows(
          _groups[i],
          _states[i].userAnswers,
          _states[i].perQuestionTimeMs,
          _opts.category,
        ),
      );
    }
    await _repo.submit(
      sessionId: _sessionId,
      hskLevel: int.tryParse(_opts.number ?? ''),
      lesson: _opts.lessonId,
      answers: answers,
    );
    if (!mounted) return;
    final total = _groups.fold<int>(0, (a, g) => a + g.questions.length);
    final pct = total > 0 ? _score / total : 0.0;
    setState(() {
      _result = (score: _score, total: total, tier: resultTier(pct));
      _screen = _Screen.result;
      _submitting = false;
    });
    _opts.onFinished?.call();
  }

  void _retry() {
    setState(() {
      _screen = _Screen.loading;
      _error = false;
      _result = null;
    });
    _load();
  }

  void _back() {
    final onExit = _opts.onExit;
    if (onExit != null) {
      onExit();
    } else if (context.canPop()) {
      context.pop();
    } else {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (_screen) {
      case _Screen.loading:
        return Scaffold(
          body: Center(
            child: _error
                ? Text(
                    l10n.practiceLoadFailed,
                    style: const TextStyle(color: BrandColors.danger),
                  )
                : const LoadingView(),
          ),
        );
      case _Screen.result:
        return Scaffold(body: SafeArea(child: _buildResult(l10n)));
      case _Screen.practice:
        return Scaffold(body: SafeArea(child: _buildPractice(l10n)));
    }
  }

  Widget _buildResult(AppLocalizations l10n) {
    final r = _result!;
    return Center(
      child: SingleChildScrollView(
        padding: PracticeStyles.screenPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              PracticeStyles.resultIcon(r.tier.index),
              size: 64,
              color: BrandColors.navTeal,
            ),
            PracticeStyles.gap16,
            Text(
              l10n.practiceCompleteTitle,
              style: PracticeStyles.resultTitleStyle,
            ),
            PracticeStyles.gap8,
            Text(
              '${l10n.practiceSetLabel} ${_opts.number ?? ''}',
              style: PracticeStyles.resultSubStyle,
            ),
            PracticeStyles.gap16,
            Text(
              '${r.score} / ${r.total}',
              style: PracticeStyles.resultScoreStyle,
            ),
            Text(
              l10n.practiceCorrectAnswers,
              style: PracticeStyles.resultSubStyle,
            ),
            PracticeStyles.gap16,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  style: PracticeStyles.navButtonStyle,
                  onPressed: _back,
                  child: Text('← ${l10n.practiceBack}'),
                ),
                PracticeStyles.wGap8,
                FilledButton(
                  style: PracticeStyles.finishButtonStyle,
                  onPressed: _retry,
                  child: Text(l10n.practiceRetry),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPractice(AppLocalizations l10n) {
    final checked = _states.map((s) => s.checked).toList();
    final everyChecked = allChecked(checked);
    final checkedCount = checked.where((c) => c).length;
    final progressPct = _groups.isEmpty ? 0.0 : checkedCount / _groups.length;
    final hasNextUnchecked = firstUncheckedAfter(checked, _index) != -1;
    final group = _groups[_index];
    final st = _states[_index];
    final canCheck =
        !st.checked && st.userAnswers.length >= group.questions.length;
    final listening = group.questions.first.skill == 'listening';

    final cb = GroupCallbacks(
      onSelectMC: (b, k) => _updateCurrent((s) => s.selectMC(b, k)),
      onSelectKey: (b, k) => _updateCurrent((s) => s.selectKey(b, k)),
      onToggleChip: (b, k) => _updateCurrent((s) => s.toggleChip(b, k)),
      onBlankClick: (b, i) => _updateCurrent((s) => s.focusBlank(b, i)),
      onAssignT6: (k) => _updateCurrent((s) => s.assignT6(k)),
    );

    return Column(
      children: [
        // Topbar.
        Padding(
          padding: PracticeStyles.screenPadding,
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                tooltip: l10n.practiceBack,
                onPressed: _back,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: progressPct,
                        minHeight: PracticeStyles.progressHeight,
                        backgroundColor: PracticeStyles.progressTrack,
                        valueColor: const AlwaysStoppedAnimation(
                          BrandColors.navTeal,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_index + 1} / ${_groups.length}',
                      textAlign: TextAlign.right,
                      style: PracticeStyles.counterStyle,
                    ),
                  ],
                ),
              ),
              PracticeStyles.wGap8,
              Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    size: 18,
                    color: BrandColors.navTeal,
                  ),
                  const SizedBox(width: 4),
                  Text('$_score', style: PracticeStyles.scoreBadgeStyle),
                ],
              ),
            ],
          ),
        ),
        // Scrollable card.
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: PracticeStyles.skillTagPadding,
                  decoration: PracticeStyles.skillTagDecoration(listening),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        listening ? Icons.headphones : Icons.menu_book_outlined,
                        size: 15,
                        color: BrandColors.navTeal,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        listening
                            ? l10n.practiceListening
                            : l10n.practiceReading,
                        style: PracticeStyles.skillTagStyle,
                      ),
                    ],
                  ),
                ),
                PracticeStyles.gap12,
                Container(
                  decoration: PracticeStyles.cardDecoration,
                  padding: PracticeStyles.cardPadding,
                  child: QuestionGroup(
                    group: group,
                    state: st,
                    category: _opts.category,
                    cb: cb,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Nav.
        _buildNav(
          l10n,
          checked: st.checked,
          canCheck: canCheck,
          everyChecked: everyChecked,
          hasNextUnchecked: hasNextUnchecked,
        ),
      ],
    );
  }

  Widget _buildNav(
    AppLocalizations l10n, {
    required bool checked,
    required bool canCheck,
    required bool everyChecked,
    required bool hasNextUnchecked,
  }) {
    final buttons = <Widget>[];
    if (_index > 0) {
      buttons.add(
        Expanded(
          child: OutlinedButton(
            style: PracticeStyles.navButtonStyle,
            onPressed: () => _visit(_index - 1),
            child: Text('← ${l10n.practicePrevious}'),
          ),
        ),
      );
    }
    if (!checked) {
      buttons.add(
        Expanded(
          child: FilledButton(
            style: PracticeStyles.checkButtonStyle,
            onPressed: canCheck ? _check : null,
            child: Text(l10n.practiceCheck),
          ),
        ),
      );
    }
    if (!everyChecked && hasNextUnchecked) {
      buttons.add(
        Expanded(
          child: OutlinedButton(
            style: PracticeStyles.navButtonStyle,
            onPressed: () {
              final n = firstUncheckedAfter(
                _states.map((s) => s.checked).toList(),
                _index,
              );
              if (n != -1) _visit(n);
            },
            child: Text('${l10n.practiceSkip} →'),
          ),
        ),
      );
    }
    if (everyChecked) {
      buttons.add(
        Expanded(
          child: FilledButton(
            style: PracticeStyles.finishButtonStyle,
            onPressed: _submitting ? null : _finish,
            child: Text(
              _submitting ? l10n.practiceSubmitting : l10n.practiceFinish,
            ),
          ),
        ),
      );
    }

    final spaced = <Widget>[];
    for (var i = 0; i < buttons.length; i++) {
      if (i > 0) spaced.add(PracticeStyles.wGap8);
      spaced.add(buttons[i]);
    }
    return Padding(
      padding: PracticeStyles.screenPadding,
      child: Row(children: spaced),
    );
  }
}
