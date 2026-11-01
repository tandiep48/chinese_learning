/// Core — the single global style surface (plan rule 3).
///
/// Defines ONLY the color palette (a seeded Material 3 `ColorScheme`) and the
/// common text sizes (the base type scale). Component decorations, per-screen
/// spacing and one-off styles live in each module's `styles/` folder, never
/// here. Seeded from the learner brand palette verified in
/// `yi-chinese-manage/app/styles/{tokens.css,learner-theme.css}` — the sage
/// `--brand-*` set, NOT the `/manage` admin slate/indigo set.
library;

import 'package:flutter/material.dart';

/// Learner brand colors (the only hardcoded hex in the app; everything else
/// reads these through `ColorScheme`/`TextTheme`).
class BrandColors {
  const BrandColors._();

  static const Color primary = Color(0xFF576856); // sage
  static const Color primaryHover = Color(0xFF455544);
  static const Color background = Color(0xFFCBE2D4); // mint page bg
  static const Color card = Color(0xFFFFFFFF);
  static const Color secondarySurface = Color(0xFFF0F4F1);
  static const Color bodyText = Color(0xFF576856);
  static const Color mutedText = Color(0xFF738A72);

  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
}

class AppTheme {
  const AppTheme._();

  /// Common text sizes only — the learner type ramp (px → logical units):
  /// 12 / 14 / 16 (body) / 18 / 20 / 24 / 32 (per plan rule 3). Roboto-first;
  /// the CJK-font runtime swap is deferred in this slice.
  static const TextTheme _textTheme = TextTheme(
    displaySmall: TextStyle(fontSize: 32),
    headlineMedium: TextStyle(fontSize: 24),
    headlineSmall: TextStyle(fontSize: 20),
    titleLarge: TextStyle(fontSize: 18),
    bodyLarge: TextStyle(fontSize: 16),
    bodyMedium: TextStyle(fontSize: 14),
    bodySmall: TextStyle(fontSize: 12),
  );

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: BrandColors.primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: BrandColors.primary,
      surface: BrandColors.card,
      surfaceContainerLowest: BrandColors.card,
      surfaceContainer: BrandColors.secondarySurface,
      onSurface: BrandColors.bodyText,
      error: BrandColors.danger,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: BrandColors.background,
      fontFamily: 'Roboto',
      textTheme: _textTheme,
    );
  }
}
