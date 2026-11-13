/// Profile module — style values for the practice-review panel.
///
/// Mirrors `review-panel.css` (sage palette) with `BrandColors`.
library;

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class ReviewStyles {
  ReviewStyles._();

  static const SizedBox gap6 = SizedBox(height: 6);
  static const SizedBox gap12 = SizedBox(height: 12);
  static const SizedBox gap14 = SizedBox(height: 14);
  static const SizedBox gap18 = SizedBox(height: 18);

  static const EdgeInsets stateBoxPadding = EdgeInsets.symmetric(
    vertical: 48,
    horizontal: 20,
  );

  static const TextStyle stateTitle = TextStyle(
    fontSize: 19,
    fontWeight: FontWeight.w700,
    color: BrandColors.darkText,
  );
  static const TextStyle stateSub = TextStyle(
    fontSize: 14.4,
    color: BrandColors.mutedText,
  );
  static const TextStyle filterLabel = TextStyle(
    fontSize: 12.8,
    fontWeight: FontWeight.w600,
    color: BrandColors.mutedText,
  );

  // ── Session card ──────────────────────────────────────────────────────────
  static final BoxDecoration sessionCard = BoxDecoration(
    color: BrandColors.card,
    border: Border.all(color: BrandColors.secondaryHover),
    borderRadius: BorderRadius.circular(14),
  );
  static const EdgeInsets sessionCardPadding = EdgeInsets.symmetric(
    horizontal: 20,
    vertical: 18,
  );
  static const TextStyle sessionTitle = TextStyle(
    fontSize: 16.8,
    fontWeight: FontWeight.w700,
    color: BrandColors.darkText,
  );
  static const TextStyle sessionMeta = TextStyle(
    fontSize: 13.6,
    color: BrandColors.mutedText,
  );

  // ── Question card ─────────────────────────────────────────────────────────
  static BoxDecoration questionCard(bool correct) => BoxDecoration(
    color: BrandColors.card,
    border: Border(
      left: BorderSide(
        color: correct ? BrandColors.success : BrandColors.danger,
        width: 4,
      ),
      top: const BorderSide(color: BrandColors.secondaryHover),
      right: const BorderSide(color: BrandColors.secondaryHover),
      bottom: const BorderSide(color: BrandColors.secondaryHover),
    ),
    borderRadius: BorderRadius.circular(14),
  );
  static const EdgeInsets questionCardPadding = EdgeInsets.all(20);
  static const TextStyle questionNumber = TextStyle(
    fontWeight: FontWeight.w700,
    color: BrandColors.darkText,
  );
  static const TextStyle badgeText = TextStyle(
    fontSize: 12.8,
    fontWeight: FontWeight.w700,
  );
  static BoxDecoration badge(bool correct) => BoxDecoration(
    color: (correct ? BrandColors.success : BrandColors.danger).withValues(
      alpha: 0.15,
    ),
    borderRadius: BorderRadius.circular(999),
  );
  static const EdgeInsets badgePadding = EdgeInsets.symmetric(
    horizontal: 10,
    vertical: 3,
  );

  static final BoxDecoration contentBox = BoxDecoration(
    color: BrandColors.background,
    borderRadius: BorderRadius.circular(10),
  );
  static const EdgeInsets contentPadding = EdgeInsets.symmetric(
    horizontal: 14,
    vertical: 12,
  );
  static const TextStyle contentText = TextStyle(
    height: 1.7,
    color: BrandColors.darkText,
  );
  static const TextStyle promptText = TextStyle(
    fontSize: 16.8,
    fontWeight: FontWeight.w600,
    color: BrandColors.darkText,
  );
  static const TextStyle missingText = TextStyle(
    fontStyle: FontStyle.italic,
    color: BrandColors.mutedText,
  );

  // ── Options ───────────────────────────────────────────────────────────────
  static BoxDecoration option({required bool correct, required bool user}) {
    final Color border;
    Color? fill;
    if (correct) {
      border = BrandColors.success;
      fill = BrandColors.success.withValues(alpha: 0.1);
    } else if (user) {
      border = BrandColors.danger;
      fill = BrandColors.danger.withValues(alpha: 0.1);
    } else {
      border = BrandColors.secondaryHover;
    }
    return BoxDecoration(
      color: fill ?? BrandColors.card,
      border: Border.all(color: border),
      borderRadius: BorderRadius.circular(10),
    );
  }

  static const EdgeInsets optionPadding = EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 10,
  );
  static const TextStyle optionKey = TextStyle(
    fontWeight: FontWeight.w700,
    color: BrandColors.bodyText,
  );
  static const TextStyle answerLabel = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: BrandColors.mutedText,
  );
  static const TextStyle answerOk = TextStyle(color: BrandColors.success);
  static const TextStyle answerBad = TextStyle(color: BrandColors.danger);
}
