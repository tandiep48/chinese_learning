/// Milestone module — style values for the step bar and runner chrome (plan
/// rules 2 & 4: style values only, no widgets).
///
/// Ported from the web's `components/page/learner/milestone/milestone.css`
/// (`.milestone-bar`, `.milestone-segment*`, `.milestone-connector`,
/// `.milestone-navbar`, `.milestone-nav-btn`). The web CSS is the source of truth
/// for the bar; the lesson-trainer mockup only governs the trainer's own chrome.
library;

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class MilestoneStyles {
  const MilestoneStyles._();

  // ── Step bar (`.milestone-bar`) ───────────────────────────────────────────
  static const EdgeInsets barPadding = EdgeInsets.fromLTRB(16, 16, 16, 12);
  static const SizedBox captionGap = SizedBox(height: 8);

  /// `.milestone-segment`: `34×34`, `2px` border (sage @30%), white fill.
  static const double badgeSize = 34;
  static const double badgeBorderWidth = 2;
  static const Color badgeBorderIdle = Color(0x4D576856); // #576856 @ 30%
  static const Color badgeFillIdle = BrandColors.card;
  static const Color badgeNumberIdle = BrandColors.mutedText;

  /// `.is-done`: sage fill + border, white number.
  static const Color badgeDone = BrandColors.primary;

  /// `.is-current`: teal fill + border, white number, `scale(1.12)`.
  static const Color badgeCurrent = BrandColors.navTeal;
  static const double badgeCurrentScale = 1.12;

  /// `.milestone-segment-num`: `0.9rem`, `700`.
  static const TextStyle badgeLabel = TextStyle(
    fontSize: 14.4,
    fontWeight: FontWeight.w700,
    height: 1,
  );

  /// `.milestone-connector`: `2px`, sage @22%, `margin: 0 8px`, `min-width: 12px`.
  static const double connectorThickness = 2;
  static const double connectorMinWidth = 12;
  static const EdgeInsets connectorMargin = EdgeInsets.symmetric(horizontal: 8);
  static const Color connectorIdle = Color(0x38576856); // #576856 @ 22%
  static const Color connectorDone = BrandColors.primary;

  /// `.milestone-step-title`: `0.95rem`, `600`, muted.
  static const TextStyle caption = TextStyle(
    fontSize: 15.2,
    fontWeight: FontWeight.w600,
    color: BrandColors.mutedText,
  );

  // ── Sticky nav bar (`.milestone-navbar`) ──────────────────────────────────
  static const EdgeInsets navBarPadding = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 12,
  );
  static const SizedBox navBarGap = SizedBox(width: 12);

  /// White bar, top border sage @15%.
  static const BoxDecoration navBarDecoration = BoxDecoration(
    color: BrandColors.card,
    border: Border(top: BorderSide(color: Color(0x26576856))),
  );

  /// `.milestone-nav-btn`: radius 12, `14px 16px` padding on phones, `600`.
  static final RoundedRectangleBorder _navShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
  );
  static const EdgeInsets _navPadding = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 14,
  );
  static const TextStyle _navText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  /// `.milestone-nav-prev`: white, `1px` sage @30% border, dark text.
  static final ButtonStyle prevButtonStyle = OutlinedButton.styleFrom(
    foregroundColor: BrandColors.bodyText,
    backgroundColor: BrandColors.card,
    side: const BorderSide(color: Color(0x4D576856)),
    shape: _navShape,
    padding: _navPadding,
    textStyle: _navText,
  );

  /// `.milestone-nav-next`: sage fill, white label (hover `#455544`).
  static final ButtonStyle nextButtonStyle = FilledButton.styleFrom(
    backgroundColor: BrandColors.primary,
    foregroundColor: Colors.white,
    shape: _navShape,
    padding: _navPadding,
    textStyle: _navText,
  );

  // ── Step stub ("coming soon") ─────────────────────────────────────────────
  static const EdgeInsets stubPadding = EdgeInsets.symmetric(
    horizontal: 24,
    vertical: 48,
  );
}
