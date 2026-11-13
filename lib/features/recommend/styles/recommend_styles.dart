/// Recommend module — style values for the recommendations tab.
///
/// Mirrors `recommend-card.css` / `recommend-page.css` with the brand palette.
/// Widgets hold no inline `Color`/`TextStyle` (plan rule 4).
library;

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class RecommendStyles {
  RecommendStyles._();

  static const EdgeInsets pagePadding = EdgeInsets.all(16);
  static const SizedBox gap8 = SizedBox(height: 8);
  static const SizedBox gap12 = SizedBox(height: 12);

  static const TextStyle resultsCount = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: BrandColors.mutedText,
  );

  // ── State box ─────────────────────────────────────────────────────────────
  static const TextStyle stateTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w800,
    color: BrandColors.darkText,
  );
  static const TextStyle stateSub = TextStyle(
    fontSize: 14,
    color: BrandColors.mutedText,
  );

  // ── Card (`recommend-card.css`) ────────────────────────────────────────────
  /// `.rec-card`: mint (`#cbe2d4`), `1px #afcfbd`, `18px` radius, `22/24` padding;
  /// selected: sage border + soft ring.
  static BoxDecoration cardDecoration({required bool selected}) => BoxDecoration(
    color: BrandColors.background,
    border: Border.all(
      color: selected ? BrandColors.primary : BrandColors.mintBorder,
      width: selected ? 1.5 : 1,
    ),
    borderRadius: BorderRadius.circular(18),
    boxShadow: selected
        ? const [
            BoxShadow(color: Color(0x2E576856), spreadRadius: 2, blurRadius: 0),
          ]
        : null,
  );
  static const EdgeInsets cardPadding = EdgeInsets.symmetric(
    horizontal: 24,
    vertical: 22,
  );
  static const SizedBox cardGap = SizedBox(height: 14);

  /// `.hsk-badge` per level: tinted pill (bg @20%, light text).
  static const Map<int, (Color, Color)> hskColors = {
    1: (Color(0x3310B981), Color(0xFF34D399)),
    2: (Color(0x333B82F6), Color(0xFF60A5FA)),
    3: (Color(0x33F59E0B), Color(0xFFFBBF24)),
    4: (Color(0x33EF4444), Color(0xFFF87171)),
    5: (Color(0x338B5CF6), Color(0xFFA78BFA)),
    6: (Color(0x33EC4899), Color(0xFFF472B6)),
  };
  static const EdgeInsets badgePadding = EdgeInsets.symmetric(
    horizontal: 10,
    vertical: 4,
  );
  static const TextStyle hskBadgeText = TextStyle(
    fontSize: 11.5,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
  );
  static const TextStyle cardTitle = TextStyle(
    fontSize: 18.4,
    fontWeight: FontWeight.w700,
    color: BrandColors.studyText,
  );

  static const TextStyle skillText = TextStyle(
    fontSize: 12.8,
    color: BrandColors.mutedText,
  );
  static const TextStyle statusText = TextStyle(
    fontSize: 13.1,
    color: BrandColors.mutedText,
  );

  /// `.category-badge`: practice (sage @12%) / exam (green @12%).
  static BoxDecoration categoryBadge({required bool exam}) => BoxDecoration(
    color: exam ? const Color(0x1F10B981) : const Color(0x1F576856),
    borderRadius: BorderRadius.circular(20),
  );
  static const EdgeInsets categoryPadding = EdgeInsets.symmetric(
    horizontal: 9,
    vertical: 3,
  );
  static TextStyle categoryText({required bool exam}) => TextStyle(
    fontSize: 11.5,
    fontWeight: FontWeight.w700,
    color: exam ? BrandColors.success : BrandColors.primary,
  );

  /// `.rec-progress-label`: small sage-tinted chip.
  static final BoxDecoration progressChip = BoxDecoration(
    color: const Color(0x0A576856),
    borderRadius: BorderRadius.circular(6),
  );
  static const EdgeInsets progressChipPadding = EdgeInsets.symmetric(
    horizontal: 10,
    vertical: 4,
  );

  // ── Filters / pager / multi-select bar ────────────────────────────────────
  static const TextStyle filterLabel = TextStyle(
    fontSize: 12.8,
    fontWeight: FontWeight.w600,
    color: BrandColors.mutedText,
  );
  static const TextStyle focusText = TextStyle(
    fontSize: 13.8,
    height: 1.35,
    color: Color(0xFF057A55),
  );
  static const Color selectBarBg = Color(0xF21E1F2E); // rgba(30,31,46,.95)
  static const TextStyle selectBarText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
  static final ButtonStyle pageButton = OutlinedButton.styleFrom(
    minimumSize: const Size(36, 36),
    padding: const EdgeInsets.symmetric(horizontal: 10),
    foregroundColor: BrandColors.bodyText,
    backgroundColor: const Color(0x0D576856),
    side: const BorderSide(color: Color(0x24576856)),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    textStyle: const TextStyle(fontSize: 14.4, fontWeight: FontWeight.w600),
  );
  static final ButtonStyle pageButtonActive = FilledButton.styleFrom(
    minimumSize: const Size(36, 36),
    padding: const EdgeInsets.symmetric(horizontal: 10),
    backgroundColor: BrandColors.primary,
    disabledBackgroundColor: BrandColors.primary,
    disabledForegroundColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    textStyle: const TextStyle(fontSize: 14.4, fontWeight: FontWeight.w600),
  );


  static final ButtonStyle startButton = FilledButton.styleFrom(
    backgroundColor: BrandColors.navTeal,
    foregroundColor: Colors.white,
    minimumSize: const Size(0, 44),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
  );
}
