/// Milestone module — the lesson flow body: the six-step runner for each part,
/// then the lesson's Grammar and Translation, then the next lesson.
///
/// Scaffold-free so it mounts both as the `/lesson/:passageId` screen and inside
/// the home dashboard's Lesson tab (`LessonFlow.tsx`). An orchestration widget
/// composing each step under the [MilestoneBar] — step 1 [WordSummaryView], 2
/// [FlashcardStudyView], 3 [VocabTrainerPage], 4 [LessonStudyView] (the reader),
/// 5 [LessonCardStudyView], 6 [LessonTrainerPage]. Gating is soft. Finishing a
/// part's last step rolls on to the next part; after the last part the flow shows
/// Grammar, then Translation, whose Next (after a confirm) opens the next lesson's
/// first part, all from one Previous / Next bar. [onPartChange] reports the active
/// part so a host can retitle itself.
///
/// After the last part the flow also offers the Master Vocab and Master Lesson
/// trainers (each skippable) before Grammar.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/trainer_action_scope.dart';
import '../../../shared/widgets/trainer_dialogs.dart';
import '../../home/providers/home_provider.dart';
import '../../lesson_trainer/screens/lesson_trainer_page.dart';
import '../../lessons/data/lesson_flow_logic.dart';
import '../../lessons/data/lesson_repository.dart';
import '../../lessons/providers/lesson_providers.dart';
import '../../lessons/widgets/flashcard_study_view.dart';
import '../../lessons/widgets/lesson_card_study_view.dart';
import '../../lessons/widgets/lesson_phase_bodies.dart';
import '../../lessons/widgets/lesson_study_view.dart';
import '../../lessons/widgets/word_summary_view.dart';
import '../../vocab_trainer/screens/vocab_trainer_page.dart';
import '../data/milestone.dart';
import '../data/milestone_repository.dart';
import '../providers/milestone_providers.dart';
import '../styles/milestone_styles.dart';
import '../../../core/theme/app_theme.dart';
import '../../lessons/widgets/lesson_sidebar.dart';
import 'master_trainer_stage.dart';
import 'milestone_bar.dart';
import 'milestone_step_stub.dart';

/// Passive steps complete on Continue (1 summary, 2 flashcards, 4 reader,
/// 5 lesson cards); steps 3 & 6 are the graded trainers.
const Set<int> _passiveSteps = {1, 2, 4, 5};
const int _vocabSummaryStep = 1;
const int _vocabLearnerStep = 2;
const int _vocabTrainerStep = 3;
const int _readerStep = 4;
const int _lessonLearnerStep = 5;
const int _lessonTrainerStep = 6;

/// The flow's phases (`StudyDomain` on the web): the milestone, then Grammar,
/// then Translation.
enum _Phase { lesson, masterVocab, masterLesson, grammar, translation }

/// Not graded parts: the pinyin guide has no vocab or tasks, and the Numbers part
/// has vocab but no graded passage (same filtering as the part picker).
const Set<String> _pinyinIds = {'H1_1_1', 'H1_1_2'};
const String _numberId = 'H1_5_99';

class LessonFlowView extends ConsumerStatefulWidget {
  const LessonFlowView({
    super.key,
    required this.passageId,
    this.initialStep,
    this.onPartChange,
    this.onRunningChange,
  });

  final String passageId;

  /// Seeds the milestone step of the opened part only (`?step=`).
  final int? initialStep;

  /// Called with the part now showing, whenever the flow moves to another one.
  final ValueChanged<String>? onPartChange;

  /// True while a graded trainer step (3 or 6) runs, so a host can arm its
  /// mid-session guard. Reported after the frame, never during a build.
  final ValueChanged<bool>? onRunningChange;

  @override
  ConsumerState<LessonFlowView> createState() => _LessonFlowViewState();
}

class _LessonFlowViewState extends ConsumerState<LessonFlowView> {
  /// The part being run; advances in place as the flow rolls on.
  late String _passageId = widget.passageId;
  _Phase _phase = _Phase.lesson;

  /// Null until the learner taps/continues; before that the view follows the
  /// milestone's resume step (or the `?step=` deep link).
  int? _viewedStep;

  /// Set once the flow runs out of lessons, so Translation's Next reads as done.
  bool _atLastLesson = false;
  bool _nextPending = false;

  /// Receives the on-screen trainer's Check / Next so it lives in the nav bar.
  final TrainerActionController _trainerAction = TrainerActionController();

  bool _reportedRunning = false;

  void _reportRunning(bool running) {
    if (running == _reportedRunning) return;
    _reportedRunning = running;
    final cb = widget.onRunningChange;
    if (cb == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) => cb(running));
  }

  @override
  void dispose() {
    _reportRunning(false);
    _trainerAction.dispose();
    super.dispose();
  }

  void _markPassive(int step) {
    final id = _passageId;
    ref
        .read(milestoneRepositoryProvider)
        .markStep(id, step)
        .then((_) {
          if (mounted) ref.invalidate(milestoneProvider(id));
        })
        .catchError((_) {
          /* soft-fail: the viewed step still advances */
        });
  }

  void _onContinue(int step, int total) {
    if (_passiveSteps.contains(step)) _markPassive(step);
    if (step >= total) {
      _onPartComplete();
      return;
    }
    setState(() => _viewedStep = step + 1);
  }

  /// Opens [id] as the active part, at its own resume step.
  void _openPart(String id) {
    setState(() {
      _passageId = id;
      _phase = _Phase.lesson;
      _viewedStep = null;
      _atLastLesson = false;
    });
    widget.onPartChange?.call(id);
  }

  /// The part's last step is done: roll to the next part of the lesson, or —
  /// after the last one — on to Grammar.
  Future<void> _onPartComplete() async {
    final id = _passageId;
    ref.invalidate(milestoneProvider(id));
    var parts = const <String>[];
    try {
      parts = await ref.read(lessonPartIdsProvider(id).future);
    } catch (_) {
      /* no part list: fall through to Grammar */
    }
    if (!mounted || id != _passageId) return;
    final idx = parts.indexOf(id);
    if (idx >= 0 && idx + 1 < parts.length) {
      _openPart(parts[idx + 1]);
    } else if (parts.isEmpty) {
      setState(() => _phase = _Phase.grammar);
    } else {
      _offerMaster(MasterEngine.vocab, parts);
    }
  }

  /// End-of-lesson master trainers: confirm → Master Vocab, confirm → Master
  /// Lesson (each skippable), then Grammar.
  Future<void> _offerMaster(MasterEngine engine, List<String> parts) async {
    final l10n = AppLocalizations.of(context);
    final isVocab = engine == MasterEngine.vocab;
    final start = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          isVocab
              ? l10n.masterVocabConfirmTitle
              : l10n.masterLessonConfirmTitle,
        ),
        content: Text(
          isVocab ? l10n.masterVocabConfirmBody : l10n.masterLessonConfirmBody,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.masterSkip),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.masterStart),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (start == true) {
      setState(
        () => _phase = isVocab ? _Phase.masterVocab : _Phase.masterLesson,
      );
    } else {
      _afterMaster(engine, parts);
    }
  }

  /// A master trainer ended (finished or skipped): offer the next, or Grammar.
  void _afterMaster(MasterEngine engine, List<String> parts) {
    if (engine == MasterEngine.vocab) {
      _offerMaster(MasterEngine.lesson, parts);
    } else {
      setState(() => _phase = _Phase.grammar);
    }
  }

  Future<void> _confirmNextLesson() async {
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.flowNextLessonTitle),
        content: Text(l10n.flowNextLessonBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.flowNotYet),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.flowNextLesson),
          ),
        ],
      ),
    );
    if (ok == true) await _goToNextLesson();
  }

  Future<void> _goToNextLesson() async {
    final from = _passageId;
    setState(() => _nextPending = true);
    String? next;
    try {
      final lessons = await ref.read(
        hskLessonsProvider(hskLevelKeyFromPassageId(from)).future,
      );
      next = nextLessonFirstPassageId(from, lessons);
    } catch (_) {
      /* soft-fail: treated as the last lesson */
    }
    if (!mounted) return;
    setState(() => _nextPending = false);
    if (next == null) {
      setState(() => _atLastLesson = true);
      return;
    }
    // Rolling on makes it the learner's current lesson (best-effort persist).
    ref.read(lessonRepositoryProvider).saveRecentLearning(next);
    ref.invalidate(currentLessonProvider);
    _openPart(next);
  }

  void _onVocabFinished() {
    // The vocab trainer (step 3) recorded its batch; refresh the markers and move
    // on to the next step (the reader).
    ref.invalidate(milestoneProvider(_passageId));
    setState(() => _viewedStep = _vocabTrainerStep + 1);
  }

  @override
  void didUpdateWidget(LessonFlowView old) {
    super.didUpdateWidget(old);
    // The host swapped the opened part (e.g. the current lesson changed): restart.
    if (old.passageId != widget.passageId && widget.passageId != _passageId) {
      _passageId = widget.passageId;
      _phase = _Phase.lesson;
      _viewedStep = null;
      _atLastLesson = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final milestone = ref.watch(milestoneProvider(_passageId)).asData?.value;

    final total = milestone?.totalSteps ?? milestoneTotalSteps;
    final seeded = _passageId == widget.passageId ? widget.initialStep : null;
    final raw = _viewedStep ?? seeded ?? milestone?.currentStep ?? 1;
    final step = raw.clamp(1, total).toInt();

    bool isCompleted(int n) => milestone?.isStepCompleted(n) ?? false;

    _reportRunning(
      _phase == _Phase.masterVocab ||
          _phase == _Phase.masterLesson ||
          (_phase == _Phase.lesson &&
              (step == _vocabTrainerStep || step == _lessonTrainerStep)),
    );

    final parts =
        ref.watch(lessonPartIdsProvider(_passageId)).asData?.value ??
        const <String>[];

    final content = switch (_phase) {
      _Phase.masterVocab => MasterTrainerStage(
        key: ValueKey('master-vocab-$_passageId'),
        engine: MasterEngine.vocab,
        passageIds: [
          for (final id in parts)
            if (!_pinyinIds.contains(id)) id,
        ],
        onDone: () => _afterMaster(MasterEngine.vocab, parts),
      ),
      _Phase.masterLesson => MasterTrainerStage(
        key: ValueKey('master-lesson-$_passageId'),
        engine: MasterEngine.lesson,
        passageIds: [
          for (final id in parts)
            if (!_pinyinIds.contains(id) && id != _numberId) id,
        ],
        onDone: () => _afterMaster(MasterEngine.lesson, parts),
      ),
      _Phase.grammar => _phaseView(
        body: GrammarBody(passageId: _passageId),
        nav: _NavBar(
          previousLabel: l10n.milestonePrevious,
          nextLabel: l10n.milestoneNext,
          onPrevious: () => setState(() {
            _phase = _Phase.lesson;
            _viewedStep = null;
          }),
          onNext: () => setState(() => _phase = _Phase.translation),
        ),
      ),
      _Phase.translation => _phaseView(
        body: TranslationBody(passageId: _passageId),
        nav: _NavBar(
          previousLabel: l10n.milestonePrevious,
          nextLabel: _atLastLesson
              ? l10n.flowLessonComplete
              : l10n.flowNextLesson,
          onPrevious: () => setState(() => _phase = _Phase.grammar),
          onNext: (_atLastLesson || _nextPending) ? null : _confirmNextLesson,
        ),
      ),
      _Phase.lesson => _lessonView(l10n, step, total, isCompleted),
    };

    // The study sidebar's phone form: a floating button opening a bottom sheet.
    return Stack(
      children: [
        content,
        Positioned(
          right: 12,
          bottom: 84,
          child: FloatingActionButton.small(
            heroTag: null,
            tooltip: l10n.sidebarOpen,
            backgroundColor: BrandColors.navTeal,
            foregroundColor: Colors.white,
            onPressed: () => _openSidebar(parts),
            child: const Icon(Icons.menu),
          ),
        ),
      ],
    );
  }

  void _openSidebar(List<String> parts) {
    showLessonSidebar(
      context,
      passageId: _passageId,
      domain: switch (_phase) {
        _Phase.grammar => SidebarDomain.grammar,
        _Phase.translation => SidebarDomain.translation,
        _ => SidebarDomain.lesson,
      },
      onSelectPart: _openPart,
      onSelectDomain: (d) => setState(() {
        switch (d) {
          case SidebarDomain.lesson:
            _phase = _Phase.lesson;
            _viewedStep = null;
          case SidebarDomain.grammar:
            _phase = _Phase.grammar;
          case SidebarDomain.translation:
            _phase = _Phase.translation;
        }
      }),
      onStartMaster: (choice) => _offerMaster(
        choice == TrainerEngineChoice.vocab
            ? MasterEngine.vocab
            : MasterEngine.lesson,
        parts,
      ),
    );
  }

  Widget _phaseView({required Widget body, required Widget nav}) {
    return Column(
      key: ValueKey('$_passageId-$_phase'),
      children: [
        // `.lesson-study-breadcrumb`: "HSK2 · Lesson 3".
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '${isBookPassageId(_passageId) ? _passageId.split('_').first : hskLevelKeyFromPassageId(_passageId)}'
              ' · ${AppLocalizations.of(context).lessonLabel(lessonOfPassageId(_passageId))}',
              style: const TextStyle(
                fontSize: 16.8,
                fontWeight: FontWeight.w700,
                color: BrandColors.studyText,
              ),
            ),
          ),
        ),
        Expanded(child: body),
        nav,
      ],
    );
  }

  Widget _lessonView(
    AppLocalizations l10n,
    int step,
    int total,
    bool Function(int) isCompleted,
  ) {
    final id = _passageId;
    // Quitting a trainer steps back (the web's `goToStep(step - 1)`).
    void quit() => setState(() => _viewedStep = step - 1);
    return TrainerActionScope(
      controller: _trainerAction,
      child: Column(
        // Remount per part so trainer / reader state never leaks across parts.
        key: ValueKey(id),
        children: [
          MilestoneBar(
            step: step,
            totalSteps: total,
            isCompleted: isCompleted,
            onSelect: (n) => setState(() => _viewedStep = n),
          ),
          Expanded(
            child: switch (step) {
              _vocabSummaryStep => WordSummaryView(passageId: id),
              _vocabLearnerStep => FlashcardStudyView(passageId: id),
              _readerStep => LessonStudyView(passageId: id),
              _lessonLearnerStep => LessonCardStudyView(passageId: id),
              _vocabTrainerStep => VocabTrainerPage(
                passageId: id,
                onExit: quit,
                onFinished: _onVocabFinished,
              ),
              _lessonTrainerStep => LessonTrainerPage(
                passageId: id,
                onExit: quit,
                onFinished: _onPartComplete,
              ),
              _ => MilestoneStepStub(step: step),
            },
          ),
          // Passive steps use the web's Previous / Next pair; the trainer steps
          // host Quit · Previous · Check/Next in the same bar.
          if (step == _vocabTrainerStep || step == _lessonTrainerStep)
            _TrainerNavBar(
              controller: _trainerAction,
              onPrevious: quit,
              onQuit: quit,
            )
          else
            _NavBar(
              previousLabel: l10n.milestonePrevious,
              nextLabel: l10n.milestoneNext,
              onPrevious: step > 1
                  ? () => setState(() => _viewedStep = step - 1)
                  : null,
              onNext: () => _onContinue(step, total),
            ),
        ],
      ),
    );
  }
}

class _NavBar extends StatelessWidget {
  const _NavBar({
    required this.previousLabel,
    required this.nextLabel,
    required this.onPrevious,
    required this.onNext,
  });

  final String previousLabel;
  final String nextLabel;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: MilestoneStyles.navBarDecoration,
      child: Padding(
        padding: MilestoneStyles.navBarPadding,
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                style: MilestoneStyles.prevButtonStyle,
                onPressed: onPrevious,
                icon: const Icon(Icons.arrow_back, size: 18),
                label: Text(previousLabel),
              ),
            ),
            MilestoneStyles.navBarGap,
            Expanded(
              child: FilledButton(
                style: MilestoneStyles.nextButtonStyle,
                onPressed: onNext,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(nextLabel, overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.arrow_forward, size: 18),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// `.milestone-navbar` on the trainer steps: Quit · Previous · the trainer's action.
class _TrainerNavBar extends StatelessWidget {
  const _TrainerNavBar({
    required this.controller,
    required this.onPrevious,
    required this.onQuit,
  });

  final TrainerActionController controller;
  final VoidCallback onPrevious;
  final VoidCallback onQuit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final action = controller.action;
        return DecoratedBox(
          decoration: MilestoneStyles.navBarDecoration,
          child: Padding(
            padding: MilestoneStyles.navBarPadding,
            child: Row(
              children: [
                OutlinedButton.icon(
                  style: MilestoneStyles.prevButtonStyle,
                  onPressed: () async {
                    if (action?.confirmQuit == false ||
                        await confirmQuitTrainer(context)) {
                      onQuit();
                    }
                  },
                  icon: const Icon(Icons.logout, size: 18),
                  label: Text(l10n.milestoneQuit),
                ),
                MilestoneStyles.navBarGap,
                IconButton.outlined(
                  tooltip: l10n.milestonePrevious,
                  onPressed: onPrevious,
                  icon: const Icon(Icons.arrow_back, size: 18),
                ),
                if (action != null) ...[
                  MilestoneStyles.navBarGap,
                  Expanded(
                    child: FilledButton(
                      style: MilestoneStyles.nextButtonStyle,
                      onPressed: action.enabled
                          ? () => controller.onPressed?.call()
                          : null,
                      child: Text(action.label),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
