/// Lesson trainer — the sticky bottom control bar (Exit + primary action).
///
/// Ported from the approved mockup's sticky bar: an outlined sage Exit button
/// and a flex-1 solid sage primary (Check / Next / Continue). A null [onPrimary]
/// renders the primary disabled.
library;

import 'package:flutter/material.dart';

import '../../../shared/widgets/trainer_action_scope.dart';
import '../../../shared/widgets/trainer_dialogs.dart';
import '../styles/lesson_trainer_styles.dart';

class TrainerBottomBar extends StatelessWidget {
  const TrainerBottomBar({
    super.key,
    required this.exitLabel,
    required this.onExit,
    required this.primaryLabel,
    required this.onPrimary,
    this.confirmQuit = true,
  });

  final String exitLabel;
  final VoidCallback onExit;
  final String primaryLabel;

  /// Null disables the primary button.
  final VoidCallback? onPrimary;

  /// Ask "Quit session?" before exiting (off on the recap, where nothing is lost).
  final bool confirmQuit;

  @override
  Widget build(BuildContext context) {
    return TrainerBarSlot(
      label: primaryLabel,
      onPressed: onPrimary,
      confirmQuit: confirmQuit,
      standalone: _bar(context),
    );
  }

  Widget _bar(BuildContext context) {
    return DecoratedBox(
      decoration: LessonTrainerStyles.bottomBarDecoration,
      child: Padding(
        padding: LessonTrainerStyles.bottomBarPadding,
        child: Row(
          children: [
            OutlinedButton.icon(
              style: LessonTrainerStyles.exitButtonStyle,
              onPressed: () async {
                if (!confirmQuit || await confirmQuitTrainer(context)) onExit();
              },
              icon: const Icon(Icons.logout, size: 18),
              label: Text(exitLabel),
            ),
            LessonTrainerStyles.bottomBarGap,
            Expanded(
              child: FilledButton(
                style: LessonTrainerStyles.primaryButtonStyle,
                onPressed: onPrimary,
                child: Text(primaryLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
