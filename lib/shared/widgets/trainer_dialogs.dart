/// Shared — the trainers' quit-confirm dialog and end-of-round success popup.
///
/// Ported from `TrainerShell.tsx` (quit modal, `trainer-quit-modal.css`) and
/// `SuccessPopup.tsx` (`success_popup.js` / `overlays.css`). The popup auto-closes
/// after 3s or on tap; the perfect-score confetti burst is not ported.
library;

import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';

class _DialogStyles {
  const _DialogStyles._();

  static const Color overlay = Color(0x611E3124); // rgba(30,49,36,.38)
  static const Color cardBorder = Color(0xFFAFCFBD);
  static const Color statValueMuted = Color(0xFF4B594F);
  static const Color correct = Color(0xFF4ADE80);
  static const Color perfectIconBg = BrandColors.background;
  static const Color missedIconBg = Color(0xFFFFF6D8);
  static const Color missedIcon = Color(0xFFD97706);
  static const Color danger = Color(0xFFDC2626);

  static final RoundedRectangleBorder cardShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
    side: const BorderSide(color: cardBorder),
  );

  static const TextStyle title = TextStyle(
    fontSize: 25.6,
    fontWeight: FontWeight.w800,
    color: BrandColors.darkText,
  );

  static const TextStyle statValue = TextStyle(
    fontSize: 28.8,
    fontWeight: FontWeight.w800,
    color: BrandColors.darkText,
    height: 1,
  );

  static const TextStyle statLabel = TextStyle(
    fontSize: 11.5,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.7,
    color: statValueMuted,
  );
}

/// Asks "Quit session?"; resolves true only on "Yes, Quit".
Future<bool> confirmQuitTrainer(BuildContext context) async {
  final l10n = AppLocalizations.of(context);
  final result = await showDialog<bool>(
    context: context,
    barrierColor: _DialogStyles.overlay,
    builder: (ctx) => AlertDialog(
      backgroundColor: BrandColors.card,
      shape: _DialogStyles.cardShape,
      icon: const Icon(
        Icons.warning_amber_rounded,
        color: _DialogStyles.missedIcon,
        size: 36,
      ),
      title: Text(l10n.trainerQuitTitle, textAlign: TextAlign.center),
      content: Text(l10n.trainerQuitBody, textAlign: TextAlign.center),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text(l10n.trainerCancel),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: _DialogStyles.danger,
            foregroundColor: Colors.white,
          ),
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text(l10n.trainerYesQuit),
        ),
      ],
    ),
  );
  return result ?? false;
}

/// Celebration card shown when a round ends; resolves once dismissed.
Future<void> showTrainerSuccessPopup(
  BuildContext context, {
  required int total,
  required int correct,
}) {
  return showDialog<void>(
    context: context,
    barrierColor: _DialogStyles.overlay,
    builder: (_) => _SuccessPopup(total: total, correct: correct),
  );
}

class _SuccessPopup extends StatefulWidget {
  const _SuccessPopup({required this.total, required this.correct});

  final int total;
  final int correct;

  @override
  State<_SuccessPopup> createState() => _SuccessPopupState();
}

class _SuccessPopupState extends State<_SuccessPopup> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 3), _close);
  }

  void _close() {
    if (mounted && Navigator.of(context).canPop()) Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final total = widget.total;
    final correct = widget.correct;
    final perfect = total > 0 && correct == total;
    final accuracy = total > 0 ? (correct / total * 100).round() : 0;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _close,
      child: Center(
        child: Material(
          color: BrandColors.card,
          shape: _DialogStyles.cardShape,
          child: Container(
            width: 400,
            constraints: BoxConstraints(
              maxWidth: MediaQuery.sizeOf(context).width - 40,
            ),
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: perfect
                        ? _DialogStyles.perfectIconBg
                        : _DialogStyles.missedIconBg,
                  ),
                  child: Icon(
                    perfect ? Icons.emoji_events : Icons.check_circle,
                    size: 44,
                    color: perfect
                        ? BrandColors.navTeal
                        : _DialogStyles.missedIcon,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  perfect
                      ? l10n.successPerfectTitle
                      : l10n.successCompleteTitle,
                  textAlign: TextAlign.center,
                  style: _DialogStyles.title,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _Stat(
                      value: '$total',
                      label: l10n.successStatTasks,
                      color: BrandColors.darkText,
                    ),
                    const SizedBox(width: 10),
                    _Stat(
                      value: '$correct',
                      label: l10n.successStatCorrect,
                      color: _DialogStyles.correct,
                    ),
                    const SizedBox(width: 10),
                    _Stat(
                      value: '$accuracy%',
                      label: l10n.successStatAccuracy,
                      color: BrandColors.navTeal,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label, required this.color});

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
        decoration: BoxDecoration(
          color: BrandColors.background,
          border: Border.all(color: _DialogStyles.cardBorder),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(value, style: _DialogStyles.statValue.copyWith(color: color)),
            const SizedBox(height: 4),
            Text(
              label.toUpperCase(),
              textAlign: TextAlign.center,
              style: _DialogStyles.statLabel,
            ),
          ],
        ),
      ),
    );
  }
}
