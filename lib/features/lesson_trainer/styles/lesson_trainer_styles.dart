/// Lesson trainer — style values (plan rules 2 & 4: style values only).
///
/// Ported from the approved mockup `mockup/approve design/lesson_trainer_typing/`
/// and `.stitch/designs/lesson-trainer-*-mobile.html`: a thin teal task-progress
/// bar, a mint outer task card with a centered instruction, the typing inner
/// prompt card (white, error-tinted on a wrong answer), sage/teal MC options, the
/// sticky sage bottom bar, and the recap.
library;

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class LessonTrainerStyles {
  const LessonTrainerStyles._();

  // ── Task progress ─────────────────────────────────────────────────────────
  static const EdgeInsets progressPadding = EdgeInsets.fromLTRB(16, 12, 16, 8);
  static const double progressHeight = 6;
  static const Color progressTrack = Color(0xFFF3F4F6);
  static const Color progressFill = BrandColors.navTeal;
  static const SizedBox progressCounterGap = SizedBox(height: 6);
  static const TextStyle counterStyle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: BrandColors.mutedText,
  );

  // ── Outer task card (mint) ────────────────────────────────────────────────
  static const EdgeInsets contentPadding = EdgeInsets.all(16);
  static final BoxDecoration taskCardDecoration = BoxDecoration(
    color: BrandColors.background,
    border: Border.all(color: BrandColors.mintBorder),
    borderRadius: BorderRadius.circular(20),
  );
  static const EdgeInsets taskCardPadding = EdgeInsets.all(18);

  static const SizedBox instructionGap = SizedBox(height: 16);
  static const SizedBox instructionIconGap = SizedBox(width: 8);
  static const double instructionIconSize = 18;
  static const TextStyle instructionStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: BrandColors.darkText,
  );

  /// The meaning task's prompt sentence.
  static const TextStyle promptSentenceStyle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 1.4,
    color: BrandColors.darkText,
  );

  // ── Multiple-choice options ───────────────────────────────────────────────
  static const SizedBox optionGap = SizedBox(height: 10);
  static const EdgeInsets optionPadding = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 14,
  );
  static final BorderRadius optionRadius = BorderRadius.circular(12);

  static BoxDecoration optionDecoration({
    required bool answered,
    required bool isCorrectOption,
    required bool isSelected,
  }) {
    Color bg = BrandColors.card;
    Color border = BrandColors.neutralBorder;
    if (answered && isCorrectOption) {
      bg = const Color(0x1A10B981); // success @ 10%
      border = BrandColors.success;
    } else if (answered && isSelected) {
      bg = BrandColors.dangerSurface;
      border = BrandColors.danger;
    }
    return BoxDecoration(
      color: bg,
      border: Border.all(color: border, width: 1.5),
      borderRadius: optionRadius,
    );
  }

  static const TextStyle optionTextStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: BrandColors.darkText,
  );
  static const SizedBox optionKeyGap = SizedBox(width: 12);
  static const TextStyle optionKeyStyle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: BrandColors.mutedText,
  );

  // ── Typing inner prompt / feedback card ───────────────────────────────────
  static const EdgeInsets promptCardPadding = EdgeInsets.all(16);
  static final BorderRadius promptCardRadius = BorderRadius.circular(14);

  static BoxDecoration promptCardDecoration({required bool error}) {
    return BoxDecoration(
      color: error ? BrandColors.dangerSurface : BrandColors.card,
      border: Border.all(
        color: error ? BrandColors.danger : BrandColors.neutralBorder,
      ),
      borderRadius: promptCardRadius,
    );
  }

  static const SizedBox promptInputGap = SizedBox(height: 14);
  static const SizedBox feedbackGap = SizedBox(height: 12);

  static InputDecoration typingInputDecoration(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: BrandColors.mutedText, fontSize: 16),
        filled: true,
        fillColor: BrandColors.card,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2DCD5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2DCD5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: BrandColors.navTeal, width: 2),
        ),
      );

  static const TextStyle typingInputStyle = TextStyle(
    fontSize: 18,
    color: BrandColors.darkText,
  );

  static const TextStyle correctionStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: BrandColors.dangerText,
  );

  static const TextStyle pinyinRevealStyle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: BrandColors.navTeal,
  );

  // ── Reorder chips ─────────────────────────────────────────────────────────
  static const SizedBox reorderRowGap = SizedBox(height: 8);
  static const SizedBox reorderSectionGap = SizedBox(height: 18);
  static const double chipSpacing = 8;
  static const EdgeInsets chipPadding = EdgeInsets.symmetric(
    horizontal: 14,
    vertical: 10,
  );
  static final BoxDecoration chipDecoration = BoxDecoration(
    color: BrandColors.card,
    border: Border.all(color: BrandColors.partItemBorder),
    borderRadius: BorderRadius.circular(10),
  );
  static const TextStyle chipTextStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: BrandColors.darkText,
  );
  static const TextStyle reorderLabelStyle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: BrandColors.mutedText,
  );
  static final BoxDecoration reorderTargetDecoration = BoxDecoration(
    color: BrandColors.card,
    border: Border.all(color: BrandColors.neutralBorder),
    borderRadius: BorderRadius.circular(12),
  );
  static const EdgeInsets reorderTargetPadding = EdgeInsets.all(12);
  static const double reorderTargetMinHeight = 56;

  // ── Sticky bottom control bar ─────────────────────────────────────────────
  static const EdgeInsets bottomBarPadding = EdgeInsets.fromLTRB(16, 10, 16, 10);
  static const SizedBox bottomBarGap = SizedBox(width: 12);
  static const BoxDecoration bottomBarDecoration = BoxDecoration(
    color: BrandColors.card,
    border: Border(top: BorderSide(color: BrandColors.neutralBorder)),
    boxShadow: [
      BoxShadow(color: Color(0x0F000000), blurRadius: 8, offset: Offset(0, -2)),
    ],
  );

  static final ButtonStyle exitButtonStyle = OutlinedButton.styleFrom(
    foregroundColor: BrandColors.primary,
    side: const BorderSide(color: Color(0x66576856)),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
  );

  static final ButtonStyle primaryButtonStyle = FilledButton.styleFrom(
    backgroundColor: BrandColors.primary,
    foregroundColor: BrandColors.card,
    disabledBackgroundColor: BrandColors.secondaryHover,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
  );

  // ── Recap ─────────────────────────────────────────────────────────────────
  static const EdgeInsets recapPadding = EdgeInsets.all(20);
  static const double recapIconSize = 56;
  static const SizedBox recapGap = SizedBox(height: 12);
  static const SizedBox recapSmallGap = SizedBox(height: 6);
  static const TextStyle recapHeading = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    color: BrandColors.darkText,
  );
  static const TextStyle recapBody = TextStyle(
    fontSize: 15,
    color: BrandColors.mutedText,
  );
  static const TextStyle recapScore = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: BrandColors.primary,
  );
  static const TextStyle recapSectionTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: BrandColors.darkText,
  );
  static final BoxDecoration recapRowDecoration = BoxDecoration(
    color: BrandColors.card,
    border: Border.all(color: BrandColors.neutralBorder),
    borderRadius: BorderRadius.circular(10),
  );
  static const EdgeInsets recapRowPadding = EdgeInsets.all(12);
  static const SizedBox recapRowGap = SizedBox(height: 10);
  static const TextStyle recapYourAnswer = TextStyle(
    fontSize: 14,
    color: BrandColors.dangerText,
  );
  static const TextStyle recapCorrectAnswer = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: BrandColors.primary,
  );
  static const TextStyle recapQuestion = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: BrandColors.darkText,
  );
}
