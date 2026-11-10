/// Milestone module — the six-step runner for one lesson part.
///
/// This is an orchestration screen (like the router/shell): it composes each of
/// the six steps under the [MilestoneBar] — step 1 [WordSummaryView], step 2
/// [FlashcardStudyView], step 3 [VocabTrainerPage], step 4 [LessonStudyView]
/// (the reader), step 5 [LessonCardStudyView], step 6 [LessonTrainerPage].
/// Ported from `MilestoneRunner.tsx`. Gating is soft — any segment is tappable;
/// Continue advances, Exit leaves the part. Mounted at `/lesson/:passageId`;
/// `?step=` deep-links a step.
///
/// All six steps are live. Passive-step completion is recorded via
/// `POST /api/lesson/milestone`; cross-part advance (rolling to the next part)
/// is still deferred (port plan — single-part first).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../lesson_trainer/screens/lesson_trainer_page.dart';
import '../../lessons/providers/lesson_providers.dart';
import '../../lessons/widgets/flashcard_study_view.dart';
import '../../lessons/widgets/lesson_card_study_view.dart';
import '../../lessons/widgets/lesson_study_view.dart';
import '../../lessons/widgets/word_summary_view.dart';
import '../../vocab_trainer/screens/vocab_trainer_page.dart';
import '../data/milestone.dart';
import '../data/milestone_repository.dart';
import '../providers/milestone_providers.dart';
import '../styles/milestone_styles.dart';
import '../widgets/milestone_bar.dart';
import '../widgets/milestone_step_stub.dart';

/// Passive steps complete on Continue (1 summary, 2 flashcards, 4 reader,
/// 5 lesson cards); steps 3 & 6 are the graded trainers.
const Set<int> _passiveSteps = {1, 2, 4, 5};
const int _vocabSummaryStep = 1;
const int _vocabLearnerStep = 2;
const int _vocabTrainerStep = 3;
const int _readerStep = 4;
const int _lessonLearnerStep = 5;
const int _lessonTrainerStep = 6;

class MilestoneScreen extends ConsumerStatefulWidget {
  const MilestoneScreen({super.key, required this.passageId, this.initialStep});

  final String passageId;
  final int? initialStep;

  @override
  ConsumerState<MilestoneScreen> createState() => _MilestoneScreenState();
}

class _MilestoneScreenState extends ConsumerState<MilestoneScreen> {
  /// Null until the learner taps/continues; before that the view follows the
  /// milestone's resume step (or the `?step=` deep link).
  int? _viewedStep;

  void _markPassive(int step) {
    ref
        .read(milestoneRepositoryProvider)
        .markStep(widget.passageId, step)
        .then((_) {
          if (mounted) ref.invalidate(milestoneProvider(widget.passageId));
        })
        .catchError((_) {
          /* soft-fail: the viewed step still advances */
        });
  }

  void _onContinue(int step, int total) {
    if (_passiveSteps.contains(step)) _markPassive(step);
    if (step >= total) {
      // Part finished. The real part-complete + cross-part advance land in N6.
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/');
      }
      return;
    }
    setState(() => _viewedStep = step + 1);
  }

  void _onQuit() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/');
    }
  }

  void _onTrainerFinished() {
    // The lesson trainer (step 6) already saved the part score; refresh the
    // progress markers and leave the part (step 6 is the last step — cross-part
    // advance lands later).
    ref.invalidate(milestoneProvider(widget.passageId));
    _onQuit();
  }

  void _onVocabFinished() {
    // The vocab trainer (step 3) recorded its batch; refresh the markers and move
    // on to the next step (the reader).
    ref.invalidate(milestoneProvider(widget.passageId));
    setState(() => _viewedStep = _vocabTrainerStep + 1);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final milestone = ref
        .watch(milestoneProvider(widget.passageId))
        .asData
        ?.value;
    final passageTitle = ref
        .watch(passageDetailProvider(widget.passageId))
        .asData
        ?.value
        .title;

    final total = milestone?.totalSteps ?? milestoneTotalSteps;
    final raw =
        _viewedStep ?? widget.initialStep ?? milestone?.currentStep ?? 1;
    final step = raw.clamp(1, total).toInt();

    bool isCompleted(int n) => milestone?.isStepCompleted(n) ?? false;

    return Scaffold(
      backgroundColor: BrandColors.card,
      appBar: AppBar(
        title: Text(passageTitle ?? widget.passageId),
        actions: [
          IconButton(
            icon: const Icon(Icons.translate),
            tooltip: l10n.translationTitle,
            onPressed: () => context.push('/translation/${widget.passageId}'),
          ),
          IconButton(
            icon: const Icon(Icons.menu_book_outlined),
            tooltip: l10n.grammarTitle,
            onPressed: () => context.push('/grammar/${widget.passageId}'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            MilestoneBar(
              step: step,
              totalSteps: total,
              isCompleted: isCompleted,
              onSelect: (n) => setState(() => _viewedStep = n),
            ),
            Expanded(
              child: switch (step) {
                _vocabSummaryStep => WordSummaryView(
                  passageId: widget.passageId,
                ),
                _vocabLearnerStep => FlashcardStudyView(
                  passageId: widget.passageId,
                ),
                _readerStep => LessonStudyView(passageId: widget.passageId),
                _lessonLearnerStep => LessonCardStudyView(
                  passageId: widget.passageId,
                ),
                _vocabTrainerStep => VocabTrainerPage(
                  passageId: widget.passageId,
                  onExit: _onQuit,
                  onFinished: _onVocabFinished,
                ),
                _lessonTrainerStep => LessonTrainerPage(
                  passageId: widget.passageId,
                  onExit: _onQuit,
                  onFinished: _onTrainerFinished,
                ),
                _ => MilestoneStepStub(step: step),
              },
            ),
            // The trainers (steps 3 & 6) own their own bottom bar; other steps use
            // the generic Continue / Exit bar.
            if (step != _vocabTrainerStep && step != _lessonTrainerStep)
              _BottomBar(
                continueLabel: l10n.milestoneContinue,
                exitLabel: l10n.milestoneQuit,
                onContinue: () => _onContinue(step, total),
                onExit: _onQuit,
              ),
          ],
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.continueLabel,
    required this.exitLabel,
    required this.onContinue,
    required this.onExit,
  });

  final String continueLabel;
  final String exitLabel;
  final VoidCallback onContinue;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: MilestoneStyles.bottomBarDecoration,
      child: Padding(
        padding: MilestoneStyles.bottomBarPadding,
        child: Row(
          children: [
            OutlinedButton.icon(
              style: MilestoneStyles.exitButtonStyle,
              onPressed: onExit,
              icon: const Icon(Icons.logout, size: 18),
              label: Text(exitLabel),
            ),
            MilestoneStyles.bottomBarGap,
            Expanded(
              child: FilledButton(
                style: MilestoneStyles.continueButtonStyle,
                onPressed: onContinue,
                child: Text(continueLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
