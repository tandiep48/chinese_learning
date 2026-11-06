/// Shared styles — cross-module style constants used by 2+ modules and by
/// `shared/widgets/` (plan rules 2 & 4: style values only, no widgets).
///
/// Ported from `yi-chinese-manage/app/styles/{tokens.css,learner-theme.css}`
/// and `components/page/learner/home/home-shell.css`.
library;

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class SharedStyles {
  const SharedStyles._();

  // ── Empty / loading states ────────────────────────────────────────────────
  static const EdgeInsets emptyPadding = EdgeInsets.symmetric(
    vertical: 32,
    horizontal: 16,
  );
  static const double emptyIconSize = 44;
  static const SizedBox emptyTitleGap = SizedBox(height: 12);
  static const SizedBox emptyMessageGap = SizedBox(height: 8);
  static const SizedBox emptyActionGap = SizedBox(height: 16);

  static const TextStyle emptyTitleStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: BrandColors.bodyText,
  );

  static const TextStyle emptyMessageStyle = TextStyle(
    fontSize: 14,
    color: BrandColors.mutedText,
  );

  // ── Skeleton box (`.learner-home-skeleton-bar`) ───────────────────────────
  static BoxDecoration skeletonDecoration(double radius) => BoxDecoration(
        color: BrandColors.sageSubtleBg,
        borderRadius: BorderRadius.circular(radius),
      );

  // ── Shared learner card (`.learner-home-aside` / `.learner-home-note`) ───
  static final BoxDecoration learnerCardDecoration = BoxDecoration(
    color: BrandColors.card,
    border: Border.all(color: BrandColors.learnerBorder),
    borderRadius: BorderRadius.circular(16),
  );
}

