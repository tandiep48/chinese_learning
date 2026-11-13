/// Core — the single global style surface (plan rule 3).
///
/// Defines ONLY the color palette (a seeded Material 3 `ColorScheme`) and the
/// common text sizes (the base type scale). Component decorations, per-screen
/// spacing and one-off styles live in each module's `styles/` folder, never
/// here. Seeded from the learner brand palette verified in
/// `yi-chinese-manage/app/styles/{tokens.css,learner-theme.css}` and
/// `components/page/learner/lesson/lesson-study.css` — the sage/teal learner
/// set, NOT the `/manage` admin slate/indigo set.
library;

import 'package:flutter/material.dart';

/// Learner brand colors (the only hardcoded hex in the app; everything else
/// reads these through `BrandColors`, `ColorScheme`, or `TextTheme`).
class BrandColors {
  const BrandColors._();

  // Core learner palette (sage/mint) — tokens.css & learner-theme.css
  static const Color primary = Color(
    0xFF576856,
  ); // --brand-primary / --learner-primary
  static const Color primaryHover = Color(0xFF455544); // --brand-primary-hover
  static const Color background = Color(
    0xFFCBE2D4,
  ); // --brand-bg / --learner-bg (mint)
  static const Color card = Color(
    0xFFFFFFFF,
  ); // --brand-card-bg / --learner-card
  static const Color secondarySurface = Color(0xFFF0F4F1); // --brand-secondary
  static const Color secondaryHover = Color(
    0xFFE0E8E1,
  ); // --brand-secondary-hover
  static const Color bodyText = Color(0xFF576856); // --brand-text-main
  static const Color mutedText = Color(0xFF738A72); // --brand-text-muted
  static const Color learnerBorder = Color(
    0x1F576856,
  ); // rgba(87, 104, 86, 0.12)
  static const Color sageSubtleBg = Color(
    0x14576856,
  ); // rgba(87, 104, 86, 0.08)

  // Teal nav / study / dashboard variant — learner-theme.css & lesson-study.css
  static const Color navTeal = Color(
    0xFF007A61,
  ); // --learner-nav / --ls-primary
  static const Color navTealHover = Color(0xFF00634F); // --ls-primary-hover
  static const Color studyTealLight = Color(0xFFE0EFE9); // --ls-primary-light
  static const Color dashboardBg = Color(0xFFEEF6DF); // --brand-dashboard-bg
  static const Color dashboardBorder = Color(
    0xFFD7E3C6,
  ); // --brand-dashboard-border
  static const Color mintBorder = Color(
    0xFFAFCFBD,
  ); // recent-lesson-panel border

  // Neutral / surface borders & text from picker / study CSS
  static const Color darkText = Color(
    0xFF111111,
  ); // picker / dashboard heading text
  static const Color subtitleText = Color(0xFF333333);
  static const Color studyText = Color(0xFF111827); // --ls-text
  static const Color studyMuted = Color(0xFF4B5563); // --ls-muted
  static const Color neutralBorder = Color(0xFFE5E7EB);
  static const Color bookCardBorder = Color(0xFFE3E3E3);
  static const Color partItemBorder = Color(0xFFD9DED9);
  static const Color coverPlaceholderBg = Color(0xFFF2F2F2);
  static const Color toggleInactiveBg = Color(0xFFF1F1F1);

  // Status colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
  static const Color dangerText = Color(0xFFDC2626);
  static const Color dangerSurface = Color(0xFFFEF2F2);
  static const Color dangerBorder = Color(0xFFFECACA);
}

class AppTheme {
  const AppTheme._();

  /// Common text sizes only — the learner type ramp (px → logical units):
  /// 12 / 14 / 16 (body) / 18 / 20 / 24 / 32 / 40 / 48 (per plan rule 3).
  /// Roboto-first; the CJK-font runtime swap is deferred in this slice.
  static const TextTheme _textTheme = TextTheme(
    displayLarge: TextStyle(fontSize: 48),
    displayMedium: TextStyle(fontSize: 40),
    displaySmall: TextStyle(fontSize: 32),
    headlineMedium: TextStyle(fontSize: 24),
    headlineSmall: TextStyle(fontSize: 20),
    titleLarge: TextStyle(fontSize: 18),
    bodyLarge: TextStyle(fontSize: 16),
    bodyMedium: TextStyle(fontSize: 14),
    bodySmall: TextStyle(fontSize: 12),
  );

  static ThemeData get light {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: BrandColors.primary,
          brightness: Brightness.light,
        ).copyWith(
          primary: BrandColors.primary,
          secondary: BrandColors.navTeal,
          surface: BrandColors.card,
          surfaceContainerLowest: BrandColors.card,
          surfaceContainer: BrandColors.secondarySurface,
          onSurface: BrandColors.bodyText,
          onSurfaceVariant: BrandColors.mutedText,
          error: BrandColors.danger,
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: BrandColors.card,
      fontFamily: 'Roboto',
      textTheme: _textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: BrandColors.navTeal,
        foregroundColor: BrandColors.card,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: BrandColors.card,
        ),
      ),
    );
  }
}
