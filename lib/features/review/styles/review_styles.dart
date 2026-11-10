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

  // ── Reveal toggle ─────────────────────────────────────────────────────────
  static ButtonStyle revealStyle(bool active) => OutlinedButton.styleFrom(
    backgroundColor: active ? BrandColors.studyTealLight : BrandColors.card,
    foregroundColor: BrandColors.navTeal,
    side: BorderSide(
      color: active ? BrandColors.navTeal : BrandColors.neutralBorder,
    ),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
  );

  // ── Word card ─────────────────────────────────────────────────────────────
  static final BoxDecoration cardDecoration = BoxDecoration(
    color: BrandColors.card,
    border: Border.all(color: BrandColors.neutralBorder),
    borderRadius: BorderRadius.circular(12),
  );
  static const EdgeInsets cardPadding = EdgeInsets.all(14);
  static const TextStyle hanzi = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: BrandColors.darkText,
  );
  static const TextStyle pinyin = TextStyle(
    fontSize: 14,
    color: BrandColors.navTeal,
  );
  static const TextStyle meaning = TextStyle(
    fontSize: 14,
    color: BrandColors.studyMuted,
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
