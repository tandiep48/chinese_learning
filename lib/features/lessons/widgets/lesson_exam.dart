/// Lessons module — the whole-lesson "Exam" entry.
///
/// Ported from the part picker's Exam flow (`ExamEngineChooser` →
/// `TrainTypePicker` → lesson-wide trainer): choose the Vocab or Lesson trainer,
/// pick its skills, then drill every graded part of the lesson in one session.
/// The vocab trainer keeps the Numbers part (it has vocab); the lesson trainer
/// drops it (not a graded passage); the pinyin guide is never trained.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/loading_view.dart';
import '../../lesson_trainer/screens/lesson_trainer_page.dart';
import '../../vocab/widgets/train_type_picker.dart';
import '../../vocab_trainer/data/trainer_word.dart';
import '../../vocab_trainer/data/vocab_trainer_repository.dart';
import '../../vocab_trainer/screens/vocab_trainer_page.dart';

const Set<String> _pinyinIds = {'H1_1_1', 'H1_1_2'};
const String _numberId = 'H1_5_99';

/// The Exam engine chooser: Vocab Trainer or Lesson Trainer (null if dismissed).
Future<TrainerEngine?> showExamEngineChooser(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  return showModalBottomSheet<TrainerEngine>(
    context: context,
    backgroundColor: BrandColors.card,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.pickerExam, style: Theme.of(ctx).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(l10n.examChooserSubtitle),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(
                Icons.fitness_center,
                color: BrandColors.navTeal,
              ),
              title: Text(l10n.pickerVocabTrainer),
              tileColor: BrandColors.studyTealLight,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              onTap: () => Navigator.of(ctx).pop(TrainerEngine.vocab),
            ),
            const SizedBox(height: 10),
            ListTile(
              leading: const Icon(
                Icons.school_outlined,
                color: BrandColors.navTeal,
              ),
              title: Text(l10n.pickerLessonTrainer),
              tileColor: BrandColors.studyTealLight,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              onTap: () => Navigator.of(ctx).pop(TrainerEngine.lesson),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Chooser → skill picker → trainer for the lesson's [partIds].
Future<void> startLessonExam(BuildContext context, List<String> partIds) async {
  final l10n = AppLocalizations.of(context);
  final engine = await showExamEngineChooser(context);
  if (engine == null || !context.mounted) return;

  final skills = await showTrainTypePicker(context, l10n, engine: engine);
  if (skills == null || !context.mounted) return;

  final ids = [
    for (final id in partIds)
      if (!_pinyinIds.contains(id) &&
          (engine == TrainerEngine.vocab || id != _numberId))
        id,
  ];
  if (ids.isEmpty) return;

  final navigator = Navigator.of(context);
  navigator.push(
    MaterialPageRoute<void>(
      builder: (_) => LessonWideTrainerScreen(
        engine: engine,
        passageIds: ids,
        types: skills,
      ),
    ),
  );
}

/// Full-screen host that runs a lesson-wide trainer and pops when it ends.
class LessonWideTrainerScreen extends ConsumerStatefulWidget {
  const LessonWideTrainerScreen({
    super.key,
    required this.engine,
    required this.passageIds,
    required this.types,
  });

  final TrainerEngine engine;
  final List<String> passageIds;
  final List<String> types;

  @override
  ConsumerState<LessonWideTrainerScreen> createState() =>
      _LessonWideTrainerScreenState();
}

class _LessonWideTrainerScreenState
    extends ConsumerState<LessonWideTrainerScreen> {
  List<TrainerWord>? _words;

  @override
  void initState() {
    super.initState();
    if (widget.engine == TrainerEngine.vocab) {
      ref
          .read(vocabTrainerRepositoryProvider)
          .resolveWordsFor(widget.passageIds)
          .then((rows) {
            if (mounted) setState(() => _words = rows);
          });
    }
  }

  void _close() {
    if (Navigator.of(context).canPop()) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isVocab = widget.engine == TrainerEngine.vocab;

    Widget body;
    if (!isVocab) {
      body = LessonTrainerPage(
        passageIds: widget.passageIds,
        types: widget.types,
        onExit: _close,
        onFinished: _close,
      );
    } else if (_words == null) {
      body = const LoadingView();
    } else {
      body = VocabTrainerPage(
        words: _words,
        activityTypes: widget.types,
        onExit: _close,
        onFinished: _close,
      );
    }

    return Scaffold(
      backgroundColor: BrandColors.card,
      appBar: AppBar(
        backgroundColor: BrandColors.background,
        title: Text(
          isVocab ? l10n.pickerVocabTrainer : l10n.pickerLessonTrainer,
        ),
      ),
      body: SafeArea(child: body),
    );
  }
}
