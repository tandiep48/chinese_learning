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

  /// `.competition-panel`: mint (`#cbe2d4`), `1px #afcfbd`, `8px` radius, `22px` padding.
  static final BoxDecoration panel = BoxDecoration(
    color: BrandColors.background,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: BrandColors.mintBorder),
    boxShadow: const [
      BoxShadow(color: Color(0x0A000000), blurRadius: 24, offset: Offset(0, 8)),
    ],
  );
  static const EdgeInsets panelPadding = EdgeInsets.all(22);

  static const TextStyle h1 = TextStyle(
    fontSize: 28.8,
    fontWeight: FontWeight.w800,
    color: BrandColors.bodyText,
  );
  static const TextStyle h2 = TextStyle(
    fontSize: 19.2,
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

  /// `.competition-room-bar`: mint, `1px #afcfbd`, `8px` radius, `16px` padding.
  static final BoxDecoration roomBar = BoxDecoration(
    color: BrandColors.background,
    border: Border.all(color: BrandColors.mintBorder),
    borderRadius: BorderRadius.circular(8),
  );
  static const EdgeInsets roomBarPadding = EdgeInsets.all(16);
  static const TextStyle roomCode = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w800,
    color: BrandColors.bodyText,
    letterSpacing: 1.5,
  );

  /// The live-score pill in the section bar (`.score-pill`).
  static final BoxDecoration scorePill = BoxDecoration(
    color: BrandColors.primary,
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

  /// `.ranking-row` / `.member-row` / `.chat-message`: white, `1px #afcfbd`,
  /// `8px` radius, `10×12` padding.
  static final BoxDecoration rankingRow = BoxDecoration(
    color: BrandColors.card,
    border: Border.all(color: BrandColors.mintBorder),
    borderRadius: BorderRadius.circular(8),
  );
  static const EdgeInsets rankingRowPadding = EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 10,
  );
  static const TextStyle rankBadge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w800,
    color: BrandColors.primary,
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
    fontSize: 13.6,
    color: BrandColors.mutedText,
  );

  /// A chat message (`.chat-message`).
  static const TextStyle chatAuthor = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: BrandColors.bodyText,
  );
  static const TextStyle chatText = TextStyle(
    fontSize: 14,
    color: BrandColors.bodyText,
  );

  /// Inline error line (`.competition-error`).
  static const TextStyle errorText = TextStyle(
    fontSize: 14,
    color: Color(0xFFA12626),
  );
  static final BoxDecoration errorBox = BoxDecoration(
    color: const Color(0xFFFFF1F1),
    border: Border.all(color: const Color(0xFFE9BCBC)),
    borderRadius: BorderRadius.circular(6),
  );
  static const EdgeInsets errorPadding = EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 10,
  );

  /// An open-room browse card (`.member-row` look: white, mint border).
  static final BoxDecoration openRoomCard = BoxDecoration(
    color: BrandColors.card,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: BrandColors.mintBorder),
  );
  static const EdgeInsets openRoomPadding = EdgeInsets.all(12);

  /// `.btn.primary`: sage (`#576856`) fill, white label, `8px` radius.
  static final ButtonStyle primaryButton = FilledButton.styleFrom(
    backgroundColor: BrandColors.primary,
    foregroundColor: BrandColors.card,
    minimumSize: const Size(0, 52),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
  );

  /// `.btn`: pale sage (`#f0f4f1`) fill, sage label.
  static final ButtonStyle secondaryButton = FilledButton.styleFrom(
    backgroundColor: BrandColors.secondarySurface,
    foregroundColor: BrandColors.bodyText,
    minimumSize: const Size(0, 52),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
  );

  static InputDecoration inputDecoration(String? hint) => InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: BrandColors.card,
    isDense: true,
    contentPadding: const EdgeInsets.all(12),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0x2E576856)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: BrandColors.primary, width: 1.5),
    ),
  );

  /// MultiSelect chip styling.
  static const TextStyle chipLabel = TextStyle(
    fontSize: 13,
    color: BrandColors.bodyText,
  );
}
