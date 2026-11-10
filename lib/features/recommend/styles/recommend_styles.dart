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
  static const SizedBox gap4 = SizedBox(height: 4);
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

  // ── Card ──────────────────────────────────────────────────────────────────
  static final BoxDecoration cardDecoration = BoxDecoration(
    color: BrandColors.card,
    border: Border.all(color: BrandColors.neutralBorder),
    borderRadius: BorderRadius.circular(14),
  );
  static const EdgeInsets cardPadding = EdgeInsets.all(14);

  static final BoxDecoration hskBadge = BoxDecoration(
    color: BrandColors.navTeal,
    borderRadius: BorderRadius.circular(999),
  );
  static const EdgeInsets badgePadding = EdgeInsets.symmetric(
    horizontal: 8,
    vertical: 2,
  );
  static const TextStyle hskBadgeText = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w800,
    color: Colors.white,
  );
  static const TextStyle cardTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w800,
    color: BrandColors.darkText,
  );

  static BoxDecoration metaBadge(Color bg) =>
      BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999));
  static const Color skillBg = BrandColors.studyTealLight;
  static const Color practiceBg = BrandColors.secondarySurface;
  static const Color examBg = BrandColors.dashboardBorder;
  static const Color statusBg = BrandColors.secondarySurface;
  static const TextStyle metaText = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: BrandColors.bodyText,
  );

  static const TextStyle progressLabel = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: BrandColors.studyText,
  );
  static const TextStyle focusLine = TextStyle(
    fontSize: 13,
    color: BrandColors.navTeal,
  );

  static final ButtonStyle startButton = FilledButton.styleFrom(
    backgroundColor: BrandColors.navTeal,
    foregroundColor: Colors.white,
    minimumSize: const Size(0, 44),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
  );
}
