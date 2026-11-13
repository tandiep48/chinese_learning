/// Practice module — style values for the runner and question-type widgets.
///
/// Mirrors `practice-shell.css` / `practice-tokens.css` with the brand palette
/// (`BrandColors`). State-dependent looks (selected / correct / wrong) are
/// helper methods so the widgets stay free of inline `Color`/`BoxDecoration`
/// (plan rule 4).
library;

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class PracticeStyles {
  PracticeStyles._();

  // ── Layout ────────────────────────────────────────────────────────────────
  static const EdgeInsets screenPadding = EdgeInsets.all(16);
  static const EdgeInsets cardPadding = EdgeInsets.all(16);
  static const SizedBox gap8 = SizedBox(height: 8);
  static const SizedBox gap12 = SizedBox(height: 12);
  static const SizedBox gap16 = SizedBox(height: 16);
  static const SizedBox wGap8 = SizedBox(width: 8);

  static final BoxDecoration cardDecoration = BoxDecoration(
    color: BrandColors.card,
    border: Border.all(color: BrandColors.neutralBorder),
    borderRadius: BorderRadius.circular(16),
  );

  /// `.p-question-block`: mint (`#cbe2d4`), `1px #afcfbd`, `14px` radius; the
  /// checked result only recolours the border.
  static BoxDecoration questionBlockDecoration({bool? correct}) {
    final border = correct == null
        ? BrandColors.mintBorder
        : (correct ? BrandColors.success : BrandColors.danger);
    return BoxDecoration(
      color: BrandColors.background,
      border: Border.all(color: border),
      borderRadius: BorderRadius.circular(14),
    );
  }

  static const EdgeInsets blockPadding = EdgeInsets.all(18);

  // ── Text ──────────────────────────────────────────────────────────────────
  static const TextStyle paragraphStyle = TextStyle(
    fontSize: 20,
    height: 1.5,
    color: BrandColors.studyText,
  );
  static const TextStyle questionTextStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: BrandColors.studyText,
  );
  static const TextStyle groupHeaderStyle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: BrandColors.bodyText,
  );
  static const TextStyle qnumStyle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: BrandColors.mutedText,
  );
  static const TextStyle instructionStyle = TextStyle(
    fontSize: 14,
    color: BrandColors.mutedText,
  );
  static const TextStyle reorderLabelStyle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: BrandColors.mutedText,
  );

  // ── Skill tag ───────────────────────────────────────────────────────────
  static BoxDecoration skillTagDecoration(bool listening) => BoxDecoration(
    color: listening
        ? BrandColors.studyTealLight
        : BrandColors.secondarySurface,
    borderRadius: BorderRadius.circular(999),
  );
  static const EdgeInsets skillTagPadding = EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 6,
  );
  static const TextStyle skillTagStyle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: BrandColors.navTeal,
  );

  // ── Topbar ────────────────────────────────────────────────────────────────
  static const double progressHeight = 8;
  static const Color progressTrack = Color(0xFFF1F1F1);
  static const TextStyle counterStyle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: BrandColors.mutedText,
  );
  static const TextStyle scoreBadgeStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: BrandColors.navTeal,
  );

  // ── Nav buttons ─────────────────────────────────────────────────────────
  static final ButtonStyle checkButtonStyle = FilledButton.styleFrom(
    backgroundColor: BrandColors.navTeal,
    foregroundColor: Colors.white,
    minimumSize: const Size(0, 48),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
  );
  static final ButtonStyle finishButtonStyle = FilledButton.styleFrom(
    backgroundColor: BrandColors.primary,
    foregroundColor: Colors.white,
    minimumSize: const Size(0, 48),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
  );
  static final ButtonStyle navButtonStyle = OutlinedButton.styleFrom(
    foregroundColor: BrandColors.bodyText,
    side: const BorderSide(color: BrandColors.neutralBorder),
    minimumSize: const Size(0, 48),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
  );

  // ── MC / option buttons ───────────────────────────────────────────────────
  static const EdgeInsets optionPadding = EdgeInsets.symmetric(
    horizontal: 14,
    vertical: 12,
  );
  static const SizedBox optionGap = SizedBox(height: 10);

  /// `.mc-option`: white, `1.5px` sage @10% border, `10px` radius; selected is
  /// `#bddbc9` / `#93bda7`; checked correct / wrong tint green / red.
  static BoxDecoration optionDecoration({
    required bool selected,
    required bool checked,
    required bool correct,
    required bool wrong,
  }) {
    Color border = const Color(0x1A576856);
    Color bg = BrandColors.card;
    if (checked && correct) {
      border = BrandColors.success;
      bg = const Color(0x2610B981);
    } else if (checked && wrong) {
      border = BrandColors.danger;
      bg = const Color(0x21EF4444);
    } else if (selected) {
      border = const Color(0xFF93BDA7);
      bg = const Color(0xFFBDDBC9);
    }
    return BoxDecoration(
      color: bg,
      border: Border.all(color: border, width: 1.5),
      borderRadius: BorderRadius.circular(10),
    );
  }

  static const TextStyle optionKeyStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w800,
    color: BrandColors.navTeal,
  );
  static const TextStyle optionTextStyle = TextStyle(
    fontSize: 16,
    color: BrandColors.studyText,
  );
  static const SizedBox optionKeyGap = SizedBox(width: 10);

  // ── True / False ─────────────────────────────────────────────────────────
  /// `.tf-btn`: white, `2px` sage @12% border, `12px` radius, `700` `16px`.
  static ButtonStyle tfButtonStyle({
    required bool selected,
    required bool checked,
    required bool correct,
    required bool wrong,
  }) {
    Color bg = BrandColors.card;
    Color border = const Color(0x1F576856);
    if (checked && correct) {
      bg = const Color(0x3310B981);
      border = BrandColors.success;
    } else if (checked && wrong) {
      bg = const Color(0x33EF4444);
      border = BrandColors.danger;
    } else if (selected) {
      bg = const Color(0xFFBDDBC9);
      border = const Color(0xFF93BDA7);
    }
    return FilledButton.styleFrom(
      backgroundColor: bg,
      foregroundColor: const Color(0xFF111111),
      minimumSize: const Size(0, 56),
      side: BorderSide(color: border, width: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
    );
  }

  // ── Reorder chips ─────────────────────────────────────────────────────────
  static const EdgeInsets chipPadding = EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 8,
  );
  static BoxDecoration chipDecoration({
    required bool inAnswer,
    required bool checked,
    required bool correct,
  }) {
    Color border = BrandColors.neutralBorder;
    Color bg = inAnswer ? BrandColors.studyTealLight : BrandColors.card;
    if (checked) {
      border = correct ? BrandColors.success : BrandColors.danger;
      bg = correct ? const Color(0x1410B981) : BrandColors.dangerSurface;
    }
    return BoxDecoration(
      color: bg,
      border: Border.all(color: border),
      borderRadius: BorderRadius.circular(10),
    );
  }

  static final BoxDecoration chipTrayDecoration = BoxDecoration(
    color: BrandColors.secondarySurface,
    borderRadius: BorderRadius.circular(12),
  );
  static const EdgeInsets chipTrayPadding = EdgeInsets.all(10);
  static const TextStyle chipKeyStyle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w800,
    color: BrandColors.navTeal,
  );
  static const TextStyle chipTextStyle = TextStyle(
    fontSize: 16,
    color: BrandColors.studyText,
  );

  // ── Blanks ────────────────────────────────────────────────────────────────
  static TextStyle blankStyle({required bool filled, required bool active}) =>
      TextStyle(
        fontSize: 20,
        height: 1.5,
        fontWeight: FontWeight.w700,
        color: filled ? BrandColors.navTeal : BrandColors.mutedText,
        backgroundColor: active ? BrandColors.studyTealLight : null,
        decoration: TextDecoration.underline,
        decorationColor: active
            ? BrandColors.navTeal
            : BrandColors.neutralBorder,
      );

  // ── Key buttons (t5 grouped) ────────────────────────────────────────────
  static ButtonStyle keyButtonStyle({
    required bool selected,
    required bool usedElsewhere,
    required bool checked,
    required bool correct,
    required bool wrong,
  }) {
    Color bg = BrandColors.secondarySurface;
    Color fg = BrandColors.bodyText;
    if (checked && correct) {
      bg = BrandColors.success;
      fg = Colors.white;
    } else if (checked && wrong) {
      bg = BrandColors.danger;
      fg = Colors.white;
    } else if (selected) {
      bg = BrandColors.navTeal;
      fg = Colors.white;
    } else if (usedElsewhere) {
      bg = BrandColors.toggleInactiveBg;
      fg = BrandColors.mutedText;
    }
    return FilledButton.styleFrom(
      backgroundColor: bg,
      foregroundColor: fg,
      minimumSize: const Size(44, 44),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
    );
  }

  // ── Images ────────────────────────────────────────────────────────────────
  static BoxDecoration imageTileDecoration({
    required bool selected,
    required bool checked,
    required bool correct,
    required bool wrong,
  }) {
    Color border = BrandColors.neutralBorder;
    if (checked && correct) {
      border = BrandColors.success;
    } else if (checked && wrong) {
      border = BrandColors.danger;
    } else if (selected) {
      border = BrandColors.navTeal;
    }
    return BoxDecoration(
      color: BrandColors.card,
      border: Border.all(color: border, width: selected || checked ? 2 : 1),
      borderRadius: BorderRadius.circular(12),
    );
  }

  static const TextStyle imageLabelStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: BrandColors.bodyText,
  );

  // ── Feedback ──────────────────────────────────────────────────────────────
  static TextStyle feedbackStyle(bool correct) => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: correct ? BrandColors.success : BrandColors.dangerText,
  );

  // ── Audio control ─────────────────────────────────────────────────────────
  static final BoxDecoration audioControlDecoration = BoxDecoration(
    color: BrandColors.secondarySurface,
    borderRadius: BorderRadius.circular(12),
  );
  static const EdgeInsets audioControlPadding = EdgeInsets.symmetric(
    horizontal: 8,
    vertical: 6,
  );
  static const TextStyle audioTimeStyle = TextStyle(
    fontSize: 12,
    color: BrandColors.mutedText,
  );

  // ── Result screen ───────────────────────────────────────────────────────
  static const TextStyle resultTitleStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    color: BrandColors.darkText,
  );
  static const TextStyle resultSubStyle = TextStyle(
    fontSize: 15,
    color: BrandColors.mutedText,
  );
  static const TextStyle resultScoreStyle = TextStyle(
    fontSize: 40,
    fontWeight: FontWeight.w800,
    color: BrandColors.navTeal,
  );

  static IconData resultIcon(int tierIndex) {
    switch (tierIndex) {
      case 0:
        return Icons.emoji_events; // trophy
      case 1:
        return Icons.check_circle; // check
      case 2:
        return Icons.show_chart; // chart
      default:
        return Icons.refresh; // retry
    }
  }

  // ── Exam pickers (level grid + lesson list) ────────────────────────────────
  static const TextStyle pageSubtitle = TextStyle(
    fontSize: 14,
    color: BrandColors.mutedText,
  );

  /// `.practice-card`: mint, `1px #afcfbd`, `16px` radius, `28/20` padding.
  static final BoxDecoration levelCardDecoration = BoxDecoration(
    color: BrandColors.background,
    border: Border.all(color: BrandColors.mintBorder),
    borderRadius: BorderRadius.circular(16),
  );
  /// Fixed row height so the card never overflows on narrow phones.
  static const double levelCardHeight = 270;
  static const EdgeInsets levelCardPadding = EdgeInsets.symmetric(
    horizontal: 20,
    vertical: 28,
  );

  /// `.card-icon`: the level number at `2.5rem`.
  static const TextStyle levelIconText = TextStyle(
    fontSize: 40,
    color: BrandColors.studyText,
  );
  static const TextStyle levelLabel = TextStyle(
    fontSize: 17.6,
    fontWeight: FontWeight.w700,
    color: BrandColors.studyText,
  );

  /// `.hsk-badge`: sage pill, white `0.7rem` text.
  static final BoxDecoration levelBadgeDecoration = BoxDecoration(
    color: BrandColors.primary,
    borderRadius: BorderRadius.circular(20),
  );
  static const EdgeInsets levelBadgePadding = EdgeInsets.symmetric(
    horizontal: 8,
    vertical: 3,
  );
  static const TextStyle levelBadgeText = TextStyle(
    fontSize: 11.2,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    color: Colors.white,
  );
  static const TextStyle levelSub = TextStyle(
    fontSize: 12.8,
    color: BrandColors.studyMuted,
  );

  /// `.lesson-card`: mint, `1px #afcfbd`, `12px` radius, `24/16` padding.
  static final BoxDecoration lessonCardDecoration = BoxDecoration(
    color: BrandColors.background,
    border: Border.all(color: BrandColors.mintBorder),
    borderRadius: BorderRadius.circular(12),
  );
  static const EdgeInsets lessonCardPadding = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 24,
  );
  static const TextStyle lessonLabel = TextStyle(
    fontSize: 17.6,
    fontWeight: FontWeight.w700,
    color: BrandColors.studyText,
  );
}
