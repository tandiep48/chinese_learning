/// Milestone module — one end-of-lesson "master" trainer.
///
/// Ported from `MasterTrainerStage.tsx`: the Vocab trainer over every word in the
/// lesson, or the Lesson trainer over every part (master mode), embedded in the
/// lesson flow between the last part and Grammar. The trainer's Check / Next is
/// hosted in a milestone-style nav bar whose left button skips the stage; on the
/// recap the trainer's Continue ends it. Both call [onDone].
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/loading_view.dart';
import '../../../shared/widgets/trainer_action_scope.dart';
import '../../lesson_trainer/screens/lesson_trainer_page.dart';
import '../../vocab_trainer/data/trainer_word.dart';
import '../../vocab_trainer/data/vocab_trainer_repository.dart';
import '../../vocab_trainer/screens/vocab_trainer_page.dart';
import '../styles/milestone_styles.dart';

enum MasterEngine { vocab, lesson }

class MasterTrainerStage extends ConsumerStatefulWidget {
  const MasterTrainerStage({
    super.key,
    required this.engine,
    required this.passageIds,
    required this.onDone,
  });

  final MasterEngine engine;

  /// The lesson's part ids to drill, already filtered for this engine.
  final List<String> passageIds;

  /// Continue the flow: the next master confirm, or Grammar after the last one.
  final VoidCallback onDone;

  @override
  ConsumerState<MasterTrainerStage> createState() => _MasterTrainerStageState();
}

class _MasterTrainerStageState extends ConsumerState<MasterTrainerStage> {
  final TrainerActionController _action = TrainerActionController();
  List<TrainerWord>? _words;

  @override
  void initState() {
    super.initState();
    if (widget.engine == MasterEngine.vocab) {
      ref
          .read(vocabTrainerRepositoryProvider)
          .resolveWordsFor(widget.passageIds)
          .then((rows) {
            if (mounted) setState(() => _words = rows);
          });
    }
  }

  @override
  void dispose() {
    _action.dispose();
    super.dispose();
  }

  Widget _trainer(AppLocalizations l10n) {
    if (widget.engine == MasterEngine.lesson) {
      return LessonTrainerPage(
        passageIds: widget.passageIds,
        onExit: widget.onDone,
        onFinished: widget.onDone,
      );
    }
    final words = _words;
    if (words == null) return const LoadingView();
    if (words.isEmpty) {
      return Center(child: Text(l10n.vocabNoVocabFound));
    }
    return VocabTrainerPage(
      words: words,
      onExit: widget.onDone,
      onFinished: widget.onDone,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final title = widget.engine == MasterEngine.vocab
        ? l10n.masterVocabTitle
        : l10n.masterLessonTitle;

    return TrainerActionScope(
      controller: _action,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: BrandColors.darkText,
              ),
            ),
          ),
          Expanded(child: _trainer(l10n)),
          ListenableBuilder(
            listenable: _action,
            builder: (context, _) {
              final action = _action.action;
              return DecoratedBox(
                decoration: MilestoneStyles.navBarDecoration,
                child: Padding(
                  padding: MilestoneStyles.navBarPadding,
                  child: Row(
                    children: [
                      OutlinedButton.icon(
                        style: MilestoneStyles.prevButtonStyle,
                        onPressed: widget.onDone,
                        icon: const Icon(Icons.fast_forward, size: 18),
                        label: Text(l10n.masterSkip),
                      ),
                      if (action != null) ...[
                        MilestoneStyles.navBarGap,
                        Expanded(
                          child: FilledButton(
                            style: MilestoneStyles.nextButtonStyle,
                            onPressed: action.enabled
                                ? () => _action.onPressed?.call()
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
          ),
        ],
      ),
    );
  }
}
