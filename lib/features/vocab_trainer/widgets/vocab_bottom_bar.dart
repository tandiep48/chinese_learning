/// Vocab trainer — the sticky bottom control bar (Exit + primary action).
library;

import 'package:flutter/material.dart';

import '../styles/vocab_trainer_styles.dart';

class VocabBottomBar extends StatelessWidget {
  const VocabBottomBar({
    super.key,
    required this.exitLabel,
    required this.onExit,
    required this.primaryLabel,
    required this.onPrimary,
  });

  final String exitLabel;
  final VoidCallback onExit;
  final String primaryLabel;

  /// Null disables the primary button.
  final VoidCallback? onPrimary;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: VocabTrainerStyles.bottomBarDecoration,
      child: Padding(
        padding: VocabTrainerStyles.bottomBarPadding,
        child: Row(
          children: [
            OutlinedButton.icon(
              style: VocabTrainerStyles.exitButtonStyle,
              onPressed: onExit,
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
