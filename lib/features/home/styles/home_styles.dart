/// Home module — style values for the home screen (plan rules 2 & 4: no
/// widgets, no inline styles in the UI files).
///
/// Ported from `yi-chinese-manage/components/page/learner/home/home-shell.css`
/// and `components/page/learner/picker/recent-lesson-panel.css`.
library;

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class HomeStyles {
  const HomeStyles._();

  /// `.learner-home` phone padding and vertical gap (`16px`).
  static const EdgeInsets pagePadding = EdgeInsets.all(16);
  static const SizedBox sectionGap = SizedBox(height: 16);

  /// Greeting text style.
  static const TextStyle greetingStyle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w800,
    color: BrandColors.bodyText,
  );

  /// `.learner-home-aside` inner padding (`20px`) and gap (`12px`).
  static const EdgeInsets asidePadding = EdgeInsets.all(20);
  static const SizedBox asideGap = SizedBox(height: 12);

  /// `.learner-home-aside-kicker`: `0.8rem` (12.8px), uppercase, bold, muted.
  static const TextStyle kickerStyle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.8,
    color: BrandColors.mutedText,
  );

  /// `.learning-recent-panel`: mint banner (`#cbe2d4`, border `#afcfbd`, `8px` radius, `18px` padding).
  static final BoxDecoration recentPanelDecoration = BoxDecoration(
    color: BrandColors.background,
    border: Border.all(color: BrandColors.mintBorder),
    borderRadius: BorderRadius.circular(8),
  );

  static const EdgeInsets recentPanelPadding = EdgeInsets.all(18);
  static const SizedBox recentTitleGap = SizedBox(height: 6);
  static const SizedBox recentButtonGap = SizedBox(height: 16);

  /// `.learning-recent-panel h2`: `1.25rem` (20px), `800` weight, `#111111`.
  static const TextStyle recentTitleStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w800,
    color: BrandColors.darkText,
  );

  /// `.learning-recent-panel .subtitle`: `#333333`.
  static const TextStyle recentSubtitleStyle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: BrandColors.subtitleText,
  );

  /// `.learning-continue-btn`: full-width on phone (`≤700px`), sage fill, `2px` darker border, `8px` radius.
  static final ButtonStyle continueButtonStyle = FilledButton.styleFrom(
    backgroundColor: BrandColors.primary,
    foregroundColor: BrandColors.card,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
      side: const BorderSide(color: BrandColors.primaryHover, width: 2),
    ),
    textStyle: const TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w800,
    ),
  );

  /// `.learner-home-aside-empty` & `.learner-home-note-link`.
  static const TextStyle emptyBodyStyle = TextStyle(
    fontSize: 15,
    color: BrandColors.mutedText,
  );

  static const TextStyle noteLinkStyle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: BrandColors.primary,
    decoration: TextDecoration.underline,
  );

  /// Books entry card styles.
  static final BorderRadius cardBorderRadius = BorderRadius.circular(16);
  static const SizedBox booksIconGap = SizedBox(width: 14);
  static const SizedBox booksSubtitleGap = SizedBox(height: 4);
  static const double booksIconSize = 28;

  static const TextStyle booksTitleStyle = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w700,
    color: BrandColors.bodyText,
  );

  static const TextStyle booksSubtitleStyle = TextStyle(
    fontSize: 14,
    color: BrandColors.mutedText,
  );
}
