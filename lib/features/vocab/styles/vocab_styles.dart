/// Vocab module — style tokens for the selection page (plan rules 2 & 4).
library;

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class VocabStyles {
  const VocabStyles._();

  static const EdgeInsets pagePadding = EdgeInsets.all(16);
  static const SizedBox gap8 = SizedBox(height: 8);
  static const SizedBox gap12 = SizedBox(height: 12);
  static const SizedBox gap16 = SizedBox(height: 16);

  static const TextStyle subtitle = TextStyle(
    fontSize: 14,
    color: BrandColors.mutedText,
  );
  static const TextStyle label = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: BrandColors.bodyText,
  );

  /// A word row card (`.vocab-card` / table row).
  static final BoxDecoration rowCard = BoxDecoration(
    color: BrandColors.card,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: BrandColors.learnerBorder),
  );
  static const EdgeInsets rowPadding = EdgeInsets.all(14);

  static const TextStyle hanzi = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: BrandColors.bodyText,
  );
  static const TextStyle pinyin = TextStyle(
    fontSize: 14,
    color: BrandColors.navTeal,
    fontWeight: FontWeight.w600,
  );
  static const TextStyle meaning = TextStyle(
    fontSize: 14,
    color: BrandColors.bodyText,
  );
  static const TextStyle levelBadge = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: BrandColors.mutedText,
  );

  /// Mode chip (selected / unselected).
  static ButtonStyle modeChip(bool selected) => TextButton.styleFrom(
    backgroundColor: selected
        ? BrandColors.primary
        : BrandColors.secondarySurface,
    foregroundColor: selected ? BrandColors.card : BrandColors.bodyText,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
  );

  static final ButtonStyle primaryButton = FilledButton.styleFrom(
    backgroundColor: BrandColors.navTeal,
    foregroundColor: BrandColors.card,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
  );
  static final ButtonStyle secondaryButton = OutlinedButton.styleFrom(
    foregroundColor: BrandColors.navTeal,
    side: const BorderSide(color: BrandColors.navTeal),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
  );

  static InputDecoration input(String? hint, {Widget? icon}) => InputDecoration(
    hintText: hint,
    prefixIcon: icon,
    filled: true,
    fillColor: BrandColors.card,
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: BrandColors.neutralBorder),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: BrandColors.navTeal, width: 1.5),
    ),
  );
}
