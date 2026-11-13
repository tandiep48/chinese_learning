/// Settings module — style values for the settings screen (plan rules 2 & 4:
/// style values only, no widgets).
///
/// Ported from the web settings modal's "panel" look
/// (`HanziSettingsControl` / `LanguageSwitcher`): stacked labeled fields with a
/// white select bordered in the learner border color, teal on focus.
library;

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class SettingsStyles {
  const SettingsStyles._();

  static const EdgeInsets pagePadding = EdgeInsets.all(16);
  static const SizedBox fieldGap = SizedBox(height: 20);
  static const SizedBox labelGap = SizedBox(height: 8);
  static const SizedBox noteGap = SizedBox(height: 8);

  /// Field label (`.panel` `<span>`): `14px`, semibold, body text.
  static const TextStyle labelStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: BrandColors.bodyText,
  );

  /// Helper note under the hanzi fields.
  static const TextStyle noteStyle = TextStyle(
    fontSize: 13,
    color: BrandColors.mutedText,
  );

  /// `PANEL_SELECT_CLS`: white field, learner border, `10px` radius, teal focus.
  static InputDecoration fieldDecoration() => InputDecoration(
    filled: true,
    fillColor: BrandColors.card,
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: BrandColors.learnerBorder),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: BrandColors.learnerBorder),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: BrandColors.navTeal),
    ),
  );

  static const TextStyle valueStyle = TextStyle(
    fontSize: 14,
    color: BrandColors.bodyText,
  );
}
