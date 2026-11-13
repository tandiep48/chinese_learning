/// Profile module — style values for the statistics screen.
///
/// Mirrors `profile-page.css` / `profile-stats.css` with the brand palette
/// (`BrandColors`). Widgets never define `Color`/`TextStyle` inline (plan rule 4).
library;

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class ProfileStyles {
  ProfileStyles._();

  static const EdgeInsets pagePadding = EdgeInsets.all(16);
  static const SizedBox gap8 = SizedBox(height: 8);
  static const SizedBox gap12 = SizedBox(height: 12);
  static const SizedBox gap16 = SizedBox(height: 16);
  static const SizedBox gap24 = SizedBox(height: 24);

  static final BoxDecoration cardDecoration = BoxDecoration(
    color: BrandColors.card,
    border: Border.all(color: BrandColors.neutralBorder),
    borderRadius: BorderRadius.circular(16),
  );
  static const EdgeInsets cardPadding = EdgeInsets.all(16);

  // ── Header ────────────────────────────────────────────────────────────────
  static const double avatarSize = 112;
  static const BoxDecoration avatarDecoration = BoxDecoration(
    color: BrandColors.navTeal,
    shape: BoxShape.circle,
  );
  static const TextStyle avatarInitial = TextStyle(
    fontSize: 43,
    fontWeight: FontWeight.w800,
    color: Colors.white,
  );
  static const TextStyle usernameStyle = TextStyle(
    fontSize: 25.6,
    fontWeight: FontWeight.w800,
    color: BrandColors.studyText,
  );
  static const TextStyle emailStyle = TextStyle(
    fontSize: 16,
    color: BrandColors.studyMuted,
  );
  static const double badgeHeight = 150;

  /// `.profile-section`: sage @4% card, `1px` sage @8% border, `8px` radius, `20px` padding.
  static final BoxDecoration sectionDecoration = BoxDecoration(
    color: const Color(0x0A576856),
    border: Border.all(color: const Color(0x14576856)),
    borderRadius: BorderRadius.circular(8),
  );
  static const EdgeInsets sectionPadding = EdgeInsets.all(20);

  // ── Section heading ─────────────────────────────────────────────────────
  static const TextStyle sectionHeading = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w800,
    color: BrandColors.studyText,
  );

  // ── Headline figures ──────────────────────────────────────────────────────
  static const TextStyle statLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
    color: BrandColors.mutedText,
  );
  static const TextStyle statValue = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: BrandColors.navTeal,
  );

  // ── Charts ────────────────────────────────────────────────────────────────
  static const double chartHeight = 160;
  static const Color barColor = BrandColors.primary;
  static const TextStyle chartValueStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: BrandColors.bodyText,
  );
  static const TextStyle chartLabelStyle = TextStyle(
    fontSize: 12,
    color: BrandColors.mutedText,
  );
  static const TextStyle chartTitleStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: BrandColors.darkText,
  );
  static const TextStyle noDataStyle = TextStyle(
    fontSize: 13,
    color: BrandColors.mutedText,
  );

  // ── Sub-stat cards ──────────────────────────────────────────────────────
  static final BoxDecoration subStatDecoration = BoxDecoration(
    color: BrandColors.secondarySurface,
    borderRadius: BorderRadius.circular(12),
  );
  static const EdgeInsets subStatPadding = EdgeInsets.all(12);
  static const TextStyle subStatLabel = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.4,
    color: BrandColors.mutedText,
  );
  static const TextStyle subStatValue = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w800,
    color: BrandColors.darkText,
  );
  static const TextStyle subStatTime = TextStyle(
    fontSize: 12,
    color: BrandColors.mutedText,
  );

  // ── Learned-vocab list ────────────────────────────────────────────────────
  static const TextStyle vocabHanzi = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: BrandColors.darkText,
  );
  static const TextStyle vocabPinyin = TextStyle(
    fontSize: 14,
    color: BrandColors.navTeal,
  );
  static const TextStyle vocabMeaning = TextStyle(
    fontSize: 14,
    color: BrandColors.studyMuted,
  );
  static final BoxDecoration vocabLevelBadge = BoxDecoration(
    color: BrandColors.studyTealLight,
    borderRadius: BorderRadius.circular(999),
  );
  static const EdgeInsets vocabLevelPadding = EdgeInsets.symmetric(
    horizontal: 8,
    vertical: 2,
  );
  static const TextStyle vocabLevelText = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: BrandColors.navTeal,
  );
}
