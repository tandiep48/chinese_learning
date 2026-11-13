/// Vocab trainer — style values (plan rules 2 & 4: style values only).
///
/// Ported from the batch vocab trainer (`vocab-trainer.css`) and aligned with
/// the approved lesson-trainer palette: a teal task-progress bar, a mint activity
/// card, sage/green/red typing rows, a two-column match board, the sticky sage
/// bottom bar and the recap.
library;

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class VocabTrainerStyles {
  const VocabTrainerStyles._();

  // ── Progress ──────────────────────────────────────────────────────────────
  static const EdgeInsets progressPadding = EdgeInsets.fromLTRB(16, 12, 16, 8);
  static const double progressHeight = 6;
  static const Color progressTrack = Color(0xFFF3F4F6);
  static const SizedBox progressCounterGap = SizedBox(height: 6);
  static const TextStyle counterStyle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: BrandColors.mutedText,
  );

  // ── Activity card ─────────────────────────────────────────────────────────
  static const EdgeInsets contentPadding = EdgeInsets.all(16);
  static final BoxDecoration cardDecoration = BoxDecoration(
    color: BrandColors.background,
    border: Border.all(color: BrandColors.mintBorder),
    borderRadius: BorderRadius.circular(20),
  );
  static const EdgeInsets cardPadding = EdgeInsets.all(18);
  static const SizedBox instructionGap = SizedBox(height: 16);
  static const TextStyle instructionStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: BrandColors.darkText,
  );

  // ── Typing rows ───────────────────────────────────────────────────────────
  static const SizedBox rowGap = SizedBox(height: 12);
  static const SizedBox promptInputGap = SizedBox(height: 8);
  static const TextStyle promptStyle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: BrandColors.darkText,
  );
  static const TextStyle inputStyle = TextStyle(
    fontSize: 24,
    color: BrandColors.darkText,
  );

  static InputDecoration inputDecoration() => InputDecoration(
    filled: true,
    fillColor: BrandColors.card,
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFFE2DCD5)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFFE2DCD5)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: BrandColors.navTeal, width: 2),
    ),
  );

  static const TextStyle resultOkStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: BrandColors.success,
  );
  static const TextStyle resultBadStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: BrandColors.dangerText,
  );
  static const SizedBox resultGap = SizedBox(height: 6);

  // ── Match board ───────────────────────────────────────────────────────────
  static const SizedBox matchColumnGap = SizedBox(width: 12);
  static const SizedBox matchItemGap = SizedBox(height: 10);
  static const EdgeInsets matchItemPadding = EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 14,
  );
  static final BorderRadius matchItemRadius = BorderRadius.circular(12);

  static BoxDecoration matchItemDecoration({
    required bool solved,
    required bool selected,
    required bool wrong,
  }) {
    Color bg = BrandColors.card;
    Color border = BrandColors.neutralBorder;
    if (solved) {
      bg = const Color(0x1A10B981);
      border = BrandColors.success;
    } else if (wrong) {
      bg = BrandColors.dangerSurface;
      border = BrandColors.danger;
    } else if (selected) {
      bg = BrandColors.studyTealLight;
      border = BrandColors.navTeal;
    }
    return BoxDecoration(
      color: bg,
      border: Border.all(color: border, width: 1.5),
      borderRadius: matchItemRadius,
    );
  }

  static const TextStyle matchLeftStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: BrandColors.darkText,
  );
  static const TextStyle matchRightStyle = TextStyle(
    fontSize: 15,
    color: BrandColors.darkText,
  );

  // ── Sticky bottom bar ─────────────────────────────────────────────────────
  static const EdgeInsets bottomBarPadding = EdgeInsets.fromLTRB(
    16,
    10,
    16,
    10,
  );
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
  static const TextStyle recapWord = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: BrandColors.darkText,
  );
  static const TextStyle recapMeaning = TextStyle(
    fontSize: 14,
    color: BrandColors.mutedText,
  );
}
