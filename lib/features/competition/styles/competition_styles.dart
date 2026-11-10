/// Competition — style tokens for the Learn Together screens (plan rules 2 & 4:
/// style values only, kept out of the widgets).
///
/// Mirrors the sage-token chrome of `competition-shell.css` /
/// `competition-trainer.css`: white panels on the mint background, teal accents,
/// and the room/score/ranking bits the five screens share.
library;

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class CompetitionStyles {
  const CompetitionStyles._();

  static const EdgeInsets pagePadding = EdgeInsets.all(16);
  static const SizedBox gap8 = SizedBox(height: 8);
  static const SizedBox gap12 = SizedBox(height: 12);
  static const SizedBox gap16 = SizedBox(height: 16);
  static const SizedBox gap24 = SizedBox(height: 24);
  static const SizedBox wgap8 = SizedBox(width: 8);
  static const SizedBox wgap12 = SizedBox(width: 12);

  /// A white content panel (`.competition-panel`).
  static final BoxDecoration panel = BoxDecoration(
    color: BrandColors.card,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: BrandColors.learnerBorder),
    boxShadow: const [
      BoxShadow(color: Color(0x0F000000), blurRadius: 24, offset: Offset(0, 6)),
    ],
  );
  static const EdgeInsets panelPadding = EdgeInsets.all(20);

  static const TextStyle h1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    color: BrandColors.bodyText,
  );
  static const TextStyle h2 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: BrandColors.bodyText,
  );
  static const TextStyle subtitle = TextStyle(
    fontSize: 14,
    color: BrandColors.mutedText,
  );
  static const TextStyle label = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: BrandColors.bodyText,
  );
  static const TextStyle body = TextStyle(
    fontSize: 14,
    color: BrandColors.bodyText,
  );
  static const TextStyle muted = TextStyle(
    fontSize: 13,
    color: BrandColors.mutedText,
  );

  /// The room-code bar (`.competition-room-bar`).
  static final BoxDecoration roomBar = BoxDecoration(
    color: BrandColors.studyTealLight,
    borderRadius: BorderRadius.circular(12),
  );
  static const EdgeInsets roomBarPadding = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 12,
  );
  static const TextStyle roomCode = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w800,
    color: BrandColors.navTeal,
    letterSpacing: 1.5,
  );

  /// The live-score pill in the section bar (`.score-pill`).
  static final BoxDecoration scorePill = BoxDecoration(
    color: BrandColors.navTeal,
    borderRadius: BorderRadius.circular(999),
  );
  static const EdgeInsets scorePillPadding = EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 6,
  );
  static const TextStyle scorePillText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: BrandColors.card,
  );

  /// One ranking/scoreboard row (`.ranking-row`).
  static final BoxDecoration rankingRow = BoxDecoration(
    color: BrandColors.secondarySurface,
    borderRadius: BorderRadius.circular(10),
  );
  static const EdgeInsets rankingRowPadding = EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 10,
  );
  static const TextStyle rankBadge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w800,
    color: BrandColors.navTeal,
  );
  static const TextStyle rankName = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: BrandColors.bodyText,
  );
  static const TextStyle rankPoints = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: BrandColors.mutedText,
  );

  /// A member row in the lobby (`.member-row`).
  static const TextStyle memberName = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: BrandColors.bodyText,
  );
  static const TextStyle memberRole = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: BrandColors.navTeal,
  );

  /// A chat message (`.chat-message`).
  static const TextStyle chatAuthor = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: BrandColors.navTeal,
  );
  static const TextStyle chatText = TextStyle(
    fontSize: 14,
    color: BrandColors.bodyText,
  );

  /// Inline error line (`.competition-error`).
  static const TextStyle errorText = TextStyle(
    fontSize: 13,
    color: BrandColors.dangerText,
  );

  /// An open-room browse card (`.open-room-card`).
  static final BoxDecoration openRoomCard = BoxDecoration(
    color: BrandColors.secondarySurface,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: BrandColors.learnerBorder),
  );
  static const EdgeInsets openRoomPadding = EdgeInsets.all(12);

  /// Primary / secondary buttons reused across the screens.
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

  static InputDecoration inputDecoration(String? hint) => InputDecoration(
    hintText: hint,
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

  /// MultiSelect chip styling.
  static const TextStyle chipLabel = TextStyle(
    fontSize: 13,
    color: BrandColors.bodyText,
  );
}
