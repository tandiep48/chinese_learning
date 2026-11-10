/// Milestone module — style values for the step bar and runner chrome (plan
/// rules 2 & 4: style values only, no widgets).
///
/// Ported from the approved lesson-trainer mockup
/// (`mockup/approve design/lesson_trainer_typing/`, documented in the port
/// plan's Slice R5a note): a 6-step connected track with 28×28 numbered badges
/// (sage `#576856` for done/inactive, teal `#007a61` for the active step with a
/// 20% focus ring) and a sticky bottom control bar (exit outline + solid primary).
library;

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class MilestoneStyles {
  const MilestoneStyles._();

  // ── Step bar ──────────────────────────────────────────────────────────────
  static const EdgeInsets barPadding = EdgeInsets.fromLTRB(16, 16, 16, 12);
  static const double badgeSize = 28;
  static const double connectorThickness = 2;
  static const Color connectorColor = Color(0x40576856); // #576856 @ 25%
  static const Color badgeIdle = BrandColors.primary; // sage (done / inactive)
  static const Color badgeActive = BrandColors.navTeal; // teal (current)
  static const Color focusRingColor = Color(0x33007A61); // #007a61 @ 20%
  static const double focusRingWidth = 4;
  static const double badgeIconSize = 16;
  static const SizedBox captionGap = SizedBox(height: 10);

  static const TextStyle badgeLabel = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: BrandColors.mutedText,
  );

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
    side: const BorderSide(color: Color(0x66576856)), // sage @ 40%
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
  );

  static final ButtonStyle continueButtonStyle = FilledButton.styleFrom(
    backgroundColor: BrandColors.primary,
    foregroundColor: BrandColors.card,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
  );

  // ── Step stub ("coming soon") ─────────────────────────────────────────────
  static const EdgeInsets stubPadding = EdgeInsets.symmetric(
    horizontal: 24,
    vertical: 48,
  );
}
