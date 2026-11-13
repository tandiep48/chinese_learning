/// Review module — style values for the saved-word review tab.
///
/// Mirrors `vocab-review.css` with the brand palette. Widgets hold no inline
/// `Color`/`TextStyle` (plan rule 4).
library;

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class ReviewStyles {
  ReviewStyles._();

  static const EdgeInsets pagePadding = EdgeInsets.all(16);
  static const SizedBox gap8 = SizedBox(height: 8);
  static const SizedBox gap12 = SizedBox(height: 12);
  static const SizedBox gap16 = SizedBox(height: 16);

  static const TextStyle heading = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w800,
    color: BrandColors.darkText,
  );
  static const TextStyle subtitle = TextStyle(
    fontSize: 14,
    color: BrandColors.mutedText,
  );

  /// The count pill next to the heading.
  static final BoxDecoration countPill = BoxDecoration(
    color: BrandColors.studyTealLight,
    borderRadius: BorderRadius.circular(999),
  );
  static const EdgeInsets countPillPadding = EdgeInsets.symmetric(
    horizontal: 10,
    vertical: 2,
  );
  static const TextStyle countPillText = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w800,
    color: BrandColors.navTeal,
  );

  // ── Tabs ──────────────────────────────────────────────────────────────────
  static ButtonStyle tabStyle(bool active) => TextButton.styleFrom(
    backgroundColor: active
        ? BrandColors.navTeal
        : BrandColors.secondarySurface,
    foregroundColor: active ? Colors.white : BrandColors.bodyText,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
  );

  // ── Study controls (`.vcl-study-btn`) ──────────────────────────────────────
  /// Pill buttons: teal-filled while the column is shown, outlined and muted when
  /// toggled off.
  static ButtonStyle revealStyle(bool active) => OutlinedButton.styleFrom(
    backgroundColor: active ? BrandColors.navTeal : Colors.transparent,
    foregroundColor: active ? Colors.white : const Color(0xFF2B2B2B),
    side: BorderSide(
      color: active ? BrandColors.navTeal : BrandColors.partItemBorder,
    ),
    minimumSize: const Size(0, 40),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    textStyle: const TextStyle(fontSize: 14.4, fontWeight: FontWeight.w600),
  );

  // ── Word card (`.vcl-card`) ───────────────────────────────────────────────
  /// White, `1px #d9ded9`, `12px` radius, `12×14` padding.
  static final BoxDecoration cardDecoration = BoxDecoration(
    color: BrandColors.card,
    border: Border.all(color: BrandColors.partItemBorder),
    borderRadius: BorderRadius.circular(12),
  );
  static const EdgeInsets cardPadding = EdgeInsets.symmetric(
    horizontal: 14,
    vertical: 12,
  );

  /// `.vcl-card-hanzi`: `1.9rem`, line-height `1.1`.
  static const TextStyle hanzi = TextStyle(
    fontSize: 30.4,
    height: 1.1,
    color: Color(0xFF111111),
  );

  /// `.vcl-card-pinyin`: teal, `0.95rem`, `600`.
  static const TextStyle pinyin = TextStyle(
    fontSize: 15.2,
    fontWeight: FontWeight.w600,
    color: BrandColors.navTeal,
  );

  /// `.vcl-card-meaning`: `0.95rem`, `1.35` line-height, two-line preview.
  static const TextStyle meaning = TextStyle(
    fontSize: 15.2,
    height: 1.35,
    color: Color(0xFF2B2B2B),
  );
  static final BoxDecoration levelBadge = BoxDecoration(
    color: BrandColors.secondarySurface,
    borderRadius: BorderRadius.circular(999),
  );
  static const EdgeInsets levelPadding = EdgeInsets.symmetric(
    horizontal: 8,
    vertical: 2,
  );
  static const TextStyle levelText = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: BrandColors.mutedText,
  );

  static const TextStyle stateMessage = TextStyle(
    fontSize: 14,
    color: BrandColors.mutedText,
  );

  // ── Pager ─────────────────────────────────────────────────────────────────
  static ButtonStyle pageStyle(bool active) => OutlinedButton.styleFrom(
    backgroundColor: active ? BrandColors.navTeal : BrandColors.card,
    foregroundColor: active ? Colors.white : BrandColors.bodyText,
    disabledBackgroundColor: active ? BrandColors.navTeal : BrandColors.card,
    disabledForegroundColor: active
        ? Colors.white
        : BrandColors.mutedText.withValues(alpha: 0.5),
    side: const BorderSide(color: BrandColors.neutralBorder),
    minimumSize: const Size(40, 40),
    padding: EdgeInsets.zero,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  );
  static const TextStyle pageInfo = TextStyle(
    fontSize: 12,
    color: BrandColors.mutedText,
  );
}
