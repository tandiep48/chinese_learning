/// Shell module styles — navigation drawer + app-shell chrome (plan rules 2 & 4:
/// style values only, no widgets).
///
/// Ported from `yi-chinese-manage/components/layout/LearnerSidebar.tsx`: the teal
/// nav surface (`--learner-nav`), white rows, and the active-row highlight
/// (`bg-white/20`) / hover (`bg-white/15`) from its `rowCls` helper.
library;

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class ShellStyles {
  const ShellStyles._();

  // ── Surfaces (white-on-teal, matching the web rail) ───────────────────────
  static const Color navBg = BrandColors.navTeal; // --learner-nav
  static const Color rowText = Colors.white;
  static const Color rowDisabled = Color(0x80FFFFFF); // white/50
  static const Color rowActiveBg = Color(0x33FFFFFF); // bg-white/20
  static const Color rowHoverBg = Color(0x26FFFFFF); // hover:bg-white/15
  static const Color divider = Color(0x26FFFFFF); // border-white/15
  static const Color avatarBg = Color(0x40FFFFFF); // bg-white/25

  // ── Spacing / metrics ─────────────────────────────────────────────────────
  static const double drawerWidth =
      288; // w-72, between the web's w-64 and comfortable touch
  static const EdgeInsets listPadding = EdgeInsets.symmetric(
    horizontal: 8,
    vertical: 8,
  );
  static const EdgeInsets headerPadding = EdgeInsets.fromLTRB(16, 24, 16, 16);
  static const EdgeInsets rowPadding = EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 12,
  );
  static const EdgeInsets sectionPadding = EdgeInsets.symmetric(
    horizontal: 8,
    vertical: 8,
  );
  static const double rowRadius = 12; // rounded-xl
  static const double rowGap = 12; // gap-3
  static const double iconSize = 20;
  static const double avatarSize = 40;
  static const SizedBox headerAvatarGap = SizedBox(width: 12);

  // ── Text ──────────────────────────────────────────────────────────────────
  static const TextStyle rowLabel = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700, // font-bold
    color: rowText,
  );
  static const TextStyle rowLabelDisabled = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: rowDisabled,
  );
  static const TextStyle username = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: rowText,
  );
  static const TextStyle avatarInitial = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: rowText,
  );
}
