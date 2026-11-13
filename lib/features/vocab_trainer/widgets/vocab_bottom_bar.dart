/// Vocab trainer — the sticky bottom control bar (Exit + primary action).
library;

import 'package:flutter/material.dart';

import '../../../shared/widgets/trainer_action_scope.dart';
import '../../../shared/widgets/trainer_dialogs.dart';
import '../styles/vocab_trainer_styles.dart';

class VocabBottomBar extends StatelessWidget {
  const VocabBottomBar({
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
      decoration: VocabTrainerStyles.bottomBarDecoration,
      child: Padding(
        padding: VocabTrainerStyles.bottomBarPadding,
        child: Row(
          children: [
            OutlinedButton.icon(
              style: VocabTrainerStyles.exitButtonStyle,
              onPressed: () async {
                if (!confirmQuit || await confirmQuitTrainer(context)) onExit();
              },
              icon: const Icon(Icons.logout, size: 18),
              label: Text(exitLabel),
            ),
            VocabTrainerStyles.bottomBarGap,
            Expanded(
              child: FilledButton(
                style: VocabTrainerStyles.primaryButtonStyle,
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
