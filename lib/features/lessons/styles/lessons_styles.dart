/// Lessons module — style values for the browse + study screens + word popup
/// (plan rules 2 & 4: style values only, no widgets).
///
/// Ported from `yi-chinese-manage/components/page/learner/picker/{lesson-picker.css,books.css}`
/// and `components/page/learner/lesson/{lesson-study.css,lesson-summary.css,word-popup.css}`.
library;

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class LessonsStyles {
  const LessonsStyles._();

  // ── Picker & Books (`lesson-picker.css` + `books.css`) ────────────────────

  /// `.picker-wrap` phone padding.
  static const EdgeInsets listPadding = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 24,
  );

  /// `.picker-title`: centered `2rem` (28px on phone), `800` weight, `#111111`.
  static const TextStyle pickerTitleStyle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: BrandColors.darkText,
  );

  /// `.picker-subtitle`: centered `#738a72`.
  static const TextStyle pickerSubtitleStyle = TextStyle(
    fontSize: 15,
    color: BrandColors.mutedText,
  );

  static const SizedBox pickerTitleGap = SizedBox(height: 6);
  static const SizedBox pickerHeaderGap = SizedBox(height: 20);
  static const SizedBox booksGridGap = SizedBox(height: 14);

  /// `.book-card`: white card, `1px solid #e3e3e3`, `10px` radius.
  static final BorderRadius bookCardRadius = BorderRadius.circular(10);

  static final BoxDecoration bookCardDecoration = BoxDecoration(
    color: BrandColors.card,
    border: Border.all(color: BrandColors.bookCardBorder),
    borderRadius: bookCardRadius,
  );

  /// `.book-card-img-wrap`: square cover on the left (`104×104` on phone), `#f2f2f2` bg.
  static const double coverSize = 104;

  static const BoxDecoration coverFallbackDecoration = BoxDecoration(
    color: BrandColors.coverPlaceholderBg,
  );

  /// `.book-card-body`: `12px 14px` padding, `6px` vertical gap.
  static const EdgeInsets bookCardBodyPadding = EdgeInsets.symmetric(
    horizontal: 14,
    vertical: 12,
  );
  static const SizedBox bookCardBodyGap = SizedBox(height: 6);

  /// `.book-card-title`: `700` weight, `#576856`.
  static const TextStyle bookCardTitleStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: BrandColors.bodyText,
  );

  /// `.book-card-count`: `0.85rem` (13.6px), `#738a72`.
  static const TextStyle bookCardCountStyle = TextStyle(
    fontSize: 13.5,
    color: BrandColors.mutedText,
  );

  // ── Book Detail (`.picker-header-section`, `.lesson-card`, `.part-list-item`) ─

  static const SizedBox lessonListGap = SizedBox(height: 14);

  /// `.lesson-card`: white card, `1px solid #e5e7eb`, `14px` radius, subtle sage shadow.
  static final BorderRadius lessonCardRadius = BorderRadius.circular(14);

  static final BoxDecoration lessonCardDecoration = BoxDecoration(
    color: BrandColors.card,
    border: Border.all(color: BrandColors.neutralBorder),
    borderRadius: lessonCardRadius,
    boxShadow: const [
      BoxShadow(color: Color(0x0F576856), blurRadius: 8, offset: Offset(0, 2)),
    ],
  );

  static const EdgeInsets lessonCardPadding = EdgeInsets.all(14);
  static const SizedBox lessonSubGap = SizedBox(height: 4);
  static const SizedBox lessonCountGap = SizedBox(height: 8);

  /// `.lesson-card-title`: `1rem` (16px), `700` weight, `#576856`.
  static const TextStyle lessonCardTitleStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: BrandColors.bodyText,
  );

  /// `.lesson-card-sub`: `0.8rem` (12.8px), `#738a72`.
  static const TextStyle lessonCardSubStyle = TextStyle(
    fontSize: 13,
    color: BrandColors.mutedText,
  );

  /// `.lesson-card-count`: pill badge (`rgba(87,104,86,0.08)`, `#576856`, `20px` radius).
  static final BoxDecoration lessonCountBadgeDecoration = BoxDecoration(
    color: BrandColors.sageSubtleBg,
    borderRadius: BorderRadius.circular(20),
  );

  static const EdgeInsets lessonCountBadgePadding = EdgeInsets.symmetric(
    horizontal: 10,
    vertical: 3,
  );

  static const TextStyle lessonCountBadgeStyle = TextStyle(
    fontSize: 12.8,
    fontWeight: FontWeight.w600,
    color: BrandColors.primary,
  );

  /// `.part-list-item`: `1px solid #d9ded9`, `8px` radius, `14px 16px` padding.
  static final BorderRadius partItemRadius = BorderRadius.circular(8);

  static final BoxDecoration partItemDecoration = BoxDecoration(
    color: BrandColors.card,
    border: Border.all(color: BrandColors.partItemBorder),
    borderRadius: partItemRadius,
    boxShadow: const [
      BoxShadow(color: Color(0x0F576856), blurRadius: 10, offset: Offset(0, 3)),
    ],
  );

  /// `.part-list-title`: `1.05rem` (16.8px), `800` weight, `#111111`.
  static const TextStyle partItemTitleStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w800,
    color: BrandColors.darkText,
  );

  /// `.book-part-done`: `#576856`, `0.85rem` (13.6px), `600` weight.
  static const TextStyle partDoneBadgeStyle = TextStyle(
    fontSize: 13.5,
    fontWeight: FontWeight.w600,
    color: BrandColors.primary,
  );

  static const SizedBox partDoneGap = SizedBox(width: 8);

  // ── Library tabs (`learning-tabs.css`: underline tabs, sage active) ───────
  static const BoxDecoration libraryTabBarDecoration = BoxDecoration(
    color: BrandColors.background,
    border: Border(
      bottom: BorderSide(color: BrandColors.bookCardBorder, width: 2),
    ),
  );

  static const TextStyle libraryTabLabelStyle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
  );

  // ── HSK level picker (`.level-picker-grid` / `.level-picker-card`) ─────────
  static const EdgeInsets levelGridPadding = EdgeInsets.fromLTRB(
    16,
    20,
    16,
    24,
  );
  static final BorderRadius levelCardRadius = BorderRadius.circular(16);

  /// Fallback text shown on a level card when its cover image fails to load.
  static const TextStyle levelLabelStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w800,
    color: BrandColors.darkText,
  );

  // ── HSK picker shared decoration (`.picker-header-section` radius) ─────────
  /// `.picker-wrap` padding (`1.5rem` sides).
  static const EdgeInsets hskListPadding = EdgeInsets.fromLTRB(24, 16, 24, 32);
  static final BorderRadius hskHeaderRadius = BorderRadius.circular(16);

  static BoxDecoration hskHeaderDecoration(Color color) =>
      BoxDecoration(color: color, borderRadius: hskHeaderRadius);

  static const EdgeInsets hskEmptyPadding = EdgeInsets.symmetric(vertical: 32);
  static const TextStyle hskEmptyTextStyle = TextStyle(
    fontSize: 14,
    color: BrandColors.mutedText,
  );

  // ── Picker responsive breakpoints (`lesson-picker.css` @media) ─────────────
  /// Level grid: 3 columns, 2 at ≤700px, 1 at ≤440px.
  static int levelGridColumns(double width) {
    if (width <= 440) return 1;
    if (width <= 700) return 2;
    return 3;
  }

  /// `.picker-header-section` stacks vertically at ≤700px.
  static bool headerStacks(double width) => width <= 700;

  /// `.level-picker-card`: `min-height: 200`, radius 16, padding `34px 24px`.
  static const double levelCardMinHeight = 200;
  static const EdgeInsets levelCardPadding = EdgeInsets.symmetric(
    horizontal: 24,
    vertical: 34,
  );
  static const double levelGridGap = 22;

  /// `.level-icon`: `min(160px, 70%)` square.
  static const double levelIconMax = 160;
  static const double levelIconFraction = 0.7;

  // ── Picker toolbar / header (`.picker-back-button`, `.picker-header-*`) ────
  static const TextStyle pickerBackStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: BrandColors.primary,
  );
  static const SizedBox pickerToolbarGap = SizedBox(height: 24);

  /// `.picker-header-section`: `24px 32px` padding, `20px` gap, `16px` radius.
  static const EdgeInsets pickerHeaderPadding = EdgeInsets.symmetric(
    horizontal: 32,
    vertical: 24,
  );
  static const double pickerHeaderGapSize = 20;
  static const double pickerHeaderImageWidth = 240;
  static const double pickerHeaderImageMaxHeight = 170;
  static const SizedBox pickerHeaderBottomGap = SizedBox(height: 24);

  /// `.picker-header-col2 h2`: `2rem`, `800`; `.subtitle`: `1.05rem`, `#333`.
  static const TextStyle pickerHeaderTitleStyle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: BrandColors.darkText,
  );
  static const TextStyle pickerHeaderSubtitleStyle = TextStyle(
    fontSize: 16.8,
    color: BrandColors.subtitleText,
  );

  /// `.picker-search-input`: `#d7e3c6` border, `10px` radius.
  static InputDecoration pickerSearchDecoration(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: BrandColors.mutedText),
    prefixIcon: const Icon(Icons.search, color: BrandColors.mutedText),
    filled: true,
    fillColor: BrandColors.card,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: BrandColors.dashboardBorder),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: BrandColors.dashboardBorder),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: BrandColors.primary, width: 2),
    ),
  );

  // ── Lesson card with cover (`.lesson-card-img-wrap`, `.lesson-card-body`) ──
  /// Image column: `clamp(96px, 34%, 140px)`.
  static double lessonImageWidth(double cardWidth) =>
      (cardWidth * 0.34).clamp(96.0, 140.0);
  static const EdgeInsets lessonBodyPadding = EdgeInsets.fromLTRB(
    14,
    12,
    14,
    14,
  );
  static const SizedBox lessonBodyGap = SizedBox(height: 6);
  static const TextStyle lessonPreviewStyle = TextStyle(
    fontSize: 13.6,
    color: BrandColors.mutedText,
  );

  // ── Part rows (`.part-list-item`) ──────────────────────────────────────────
  static const EdgeInsets partRowPadding = EdgeInsets.symmetric(
    horizontal: 20,
    vertical: 18,
  );
  static const SizedBox partRowGap = SizedBox(height: 12);
  static const SizedBox partRowInnerGap = SizedBox(height: 10);

  // ── Progress bars (`.picker-progress-*`) ───────────────────────────────────
  static const double progressTrackHeight = 8;
  static const double progressTrackMaxWidth = 260;
  static const Color progressTrackBg = BrandColors.learnerBorder;
  static const TextStyle progressLabelStyle = TextStyle(
    fontSize: 13,
    color: BrandColors.mutedText,
  );
  static const TextStyle progressPctStyle = TextStyle(
    fontSize: 12.5,
    fontWeight: FontWeight.w600,
    color: BrandColors.mutedText,
  );
  static const double progressPctWidth = 60;

  /// `.pct-red/orange/yellow/green` thresholds (≤25 / ≤50 / ≤75 / above).
  static Color progressFill(int pct) {
    if (pct <= 25) return const Color(0xFFDC2626);
    if (pct <= 50) return const Color(0xFFEA580C);
    if (pct <= 75) return const Color(0xFFEAB308);
    return const Color(0xFF16A34A);
  }

  // ── Study reader (`lesson-study.css` + `lesson-summary.css`) ──────────────

  static const EdgeInsets studyPagePadding = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 20,
  );

  /// `.lesson-summary-toolbar`: white card, `8px` radius, `1rem` padding, subtle teal shadow.
  static final BoxDecoration summaryToolbarDecoration = BoxDecoration(
    color: BrandColors.card,
    border: Border.all(color: const Color(0x0F000000)),
    borderRadius: BorderRadius.circular(8),
    boxShadow: const [
      BoxShadow(color: Color(0x0A007A61), blurRadius: 8, offset: Offset(0, 2)),
    ],
  );

  static const EdgeInsets summaryToolbarPadding = EdgeInsets.all(16);
  static const SizedBox summaryToolbarBottomGap = SizedBox(height: 16);
  static const SizedBox toolbarColumnGap = SizedBox(width: 8);
  static const SizedBox toolbarStackGap = SizedBox(height: 8);
  static const SizedBox toolbarButtonIconGap = SizedBox(width: 6);
  static const double toolbarIconSize = 16;

  static ButtonStyle toolbarButtonStyle({required bool active}) {
    return OutlinedButton.styleFrom(
      backgroundColor: active
          ? BrandColors.navTeal
          : BrandColors.toggleInactiveBg,
      foregroundColor: active ? BrandColors.card : BrandColors.studyMuted,
      side: BorderSide(
        color: active ? BrandColors.navTeal : const Color(0x1A000000),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      textStyle: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
    );
  }

  /// `.lesson-preview-line`: mint card (`#cbe2d4`), `24px` radius, `20px` padding.
  static final BoxDecoration previewLineDecoration = BoxDecoration(
    color: BrandColors.background,
    border: Border.all(color: const Color(0x08000000)),
    borderRadius: BorderRadius.circular(24),
    boxShadow: const [
      BoxShadow(color: Color(0x0A007A61), blurRadius: 8, offset: Offset(0, 2)),
    ],
  );

  /// `.lesson-preview-line.playing-highlight`: warm `#ffe9a8` card with a `2px`
  /// `#d99e00` ring while its audio sounds.
  static final BoxDecoration previewLineHighlightDecoration = BoxDecoration(
    color: const Color(0xFFFFE9A8),
    border: Border.all(color: const Color(0xFFD99E00), width: 2),
    borderRadius: BorderRadius.circular(24),
    boxShadow: const [
      BoxShadow(color: Color(0x1A000000), blurRadius: 18, offset: Offset(0, 6)),
    ],
  );

  static const EdgeInsets previewLinePadding = EdgeInsets.all(20);
  static const double lineGap = 16;
  static const SizedBox lineAudioGap = SizedBox(width: 16);
  static const SizedBox lineInnerGap = SizedBox(height: 4);

  /// `.lesson-passage-audio-btn`: `40×40` circle, `#e0efe9` bg, `rgba(0,122,97,0.25)` border.
  static const double audioBtnSize = 40;
  static const double audioIconSize = 18;

  static final BoxDecoration audioBtnDecoration = BoxDecoration(
    color: BrandColors.studyTealLight,
    shape: BoxShape.circle,
    border: Border.all(color: const Color(0x40007A61)),
  );

  /// Speaker label above line.
  static const TextStyle speakerStyle = TextStyle(
    fontSize: 12.5,
    fontWeight: FontWeight.w600,
    color: BrandColors.studyMuted,
  );

  /// `.hanzi-text`: `1.5rem` (24px), `1.5` line-height, `#111111`.
  static const TextStyle hanziPlainStyle = TextStyle(
    fontSize: 24,
    height: 1.5,
    color: BrandColors.darkText,
  );

  /// `.line-token.clickable`: underlined, `#111827`.
  static const TextStyle hanziClickableStyle = TextStyle(
    fontSize: 24,
    height: 1.5,
    color: BrandColors.studyText,
    decoration: TextDecoration.underline,
    decorationColor: BrandColors.studyText,
  );

  /// `.pinyin-text`: `#007a61`, `600` weight.
  static const TextStyle pinyinStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: BrandColors.navTeal,
  );

  /// `.meaning-text`: `#4b5563`.
  static const TextStyle meaningStyle = TextStyle(
    fontSize: 15,
    color: BrandColors.studyMuted,
  );

  /// Spacing between word tokens in a line (`.line-token.clickable { margin-right: 4px }`).
  static const double tokenSpacing = 4;
  static const double tokenRunSpacing = 6;

  // ── Word Popup (`word-popup.css`) ─────────────────────────────────────────

  static const RoundedRectangleBorder wordPopupShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  );

  static const double wordPopupMaxWidth = 480;

  static const EdgeInsets wordPopupPadding = EdgeInsets.fromLTRB(
    24,
    24,
    24,
    32,
  );

  /// `.word-popup-close`: `32×32` circle, `rgba(0,0,0,0.05)` bg, `#4b5563` icon.
  static const double wordPopupCloseSize = 32;
  static const double wordPopupCloseIconSize = 18;

  static const BoxDecoration wordPopupCloseDecoration = BoxDecoration(
    color: Color(0x0D000000),
    shape: BoxShape.circle,
  );

  /// `.word-popup-hanzi`: `2.8rem` (44.8px), `700` weight, `#007a61`, `1.1` line-height.
  static const TextStyle wordPopupHanziStyle = TextStyle(
    fontSize: 44,
    fontWeight: FontWeight.w700,
    height: 1.1,
    color: BrandColors.navTeal,
  );

  /// `.word-popup-pinyin`: `1.05rem` (16.8px), `#4b5563`.
  static const TextStyle wordPopupPinyinStyle = TextStyle(
    fontSize: 16.8,
    color: BrandColors.studyMuted,
  );

  /// `.word-popup-meaning`: `0.95rem` (15.2px), `#111827`.
  static const TextStyle wordPopupMeaningStyle = TextStyle(
    fontSize: 15.2,
    color: BrandColors.studyText,
  );

  /// `.word-popup-meaning-en`: `0.88rem` (14px), `#4b5563`.
  static const TextStyle wordPopupMeaningSecondaryStyle = TextStyle(
    fontSize: 14,
    color: BrandColors.studyMuted,
  );

  /// `.word-popup-not-found`: `0.9rem` (14.4px), italic, `#4b5563`.
  static const TextStyle wordPopupNotFoundStyle = TextStyle(
    fontSize: 14.4,
    fontStyle: FontStyle.italic,
    color: BrandColors.studyMuted,
  );

  static const SizedBox wordPopupHanziGap = SizedBox(height: 6);
  static const SizedBox wordPopupPinyinGap = SizedBox(height: 10);
  static const SizedBox wordPopupMeaningGap = SizedBox(height: 4);
  static const SizedBox wordPopupActionsTopGap = SizedBox(height: 18);
  static const SizedBox wordPopupActionsBetweenGap = SizedBox(width: 10);

  /// `.word-popup-btn`: `#e0efe9` bg, `1px solid #cbe2d4`, `10px` radius, `#007a61` text.
  static final ButtonStyle wordPopupButtonStyle = OutlinedButton.styleFrom(
    backgroundColor: BrandColors.studyTealLight,
    foregroundColor: BrandColors.navTeal,
    side: const BorderSide(color: BrandColors.background),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    textStyle: const TextStyle(fontSize: 14.4, fontWeight: FontWeight.w600),
  );

  /// `.word-popup-btn.active`: teal fill, white label.
  static final ButtonStyle wordPopupButtonActiveStyle = wordPopupButtonStyle
      .copyWith(
        backgroundColor: const WidgetStatePropertyAll(BrandColors.navTeal),
        foregroundColor: const WidgetStatePropertyAll(Colors.white),
        side: const WidgetStatePropertyAll(
          BorderSide(color: BrandColors.navTeal),
        ),
      );

  // ── Passive learners / summaries (milestone steps 1, 2, 5) ────────────────
  static const EdgeInsets learnerListPadding = EdgeInsets.all(16);

  /// Read-only vocab card (`.vocab-card`): white, bordered, rounded.
  static final BoxDecoration vocabCardDecoration = BoxDecoration(
    color: BrandColors.card,
    border: Border.all(color: BrandColors.neutralBorder),
    borderRadius: BorderRadius.circular(12),
  );
  static const EdgeInsets vocabCardPadding = EdgeInsets.all(16);
  static const SizedBox vocabCardGap = SizedBox(height: 12);
  static const SizedBox vocabCardInnerGap = SizedBox(height: 4);

  static const TextStyle vocabHanziStyle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: BrandColors.darkText,
  );

  /// `.ws-card` (phone word summary): mint card, `12px` radius, `12×14` padding.
  static final BoxDecoration wsCardDecoration = BoxDecoration(
    color: BrandColors.background,
    border: Border.all(color: const Color(0x1F007A61)),
    borderRadius: BorderRadius.circular(12),
  );
  static final BoxDecoration wsCardHighlightDecoration = BoxDecoration(
    color: const Color(0xFFFFE9A8),
    border: Border.all(color: const Color(0xFFD99E00), width: 2),
    borderRadius: BorderRadius.circular(12),
    boxShadow: const [
      BoxShadow(color: Color(0x1A000000), blurRadius: 18, offset: Offset(0, 6)),
    ],
  );
  static const EdgeInsets wsCardPadding = EdgeInsets.symmetric(
    horizontal: 14,
    vertical: 12,
  );
  static const EdgeInsets summaryToolbarBottomPadding = EdgeInsets.only(
    bottom: 16,
  );
  static const double wsAudioSize = 44;
  static const TextStyle wsNumStyle = TextStyle(
    fontSize: 12.8,
    fontWeight: FontWeight.w700,
    color: BrandColors.studyMuted,
  );
  static const TextStyle wsHanziStyle = TextStyle(
    fontSize: 30.4,
    height: 1.1,
    color: BrandColors.studyText,
  );
  static const TextStyle wsPinyinStyle = TextStyle(
    fontSize: 15.2,
    fontWeight: FontWeight.w600,
    color: BrandColors.navTeal,
  );
  static const TextStyle wsMeaningStyle = TextStyle(
    fontSize: 15.2,
    height: 1.35,
    color: BrandColors.studyMuted,
  );
  static const TextStyle wsSheetHanziStyle = TextStyle(
    fontSize: 48,
    height: 1.1,
    color: BrandColors.studyText,
  );
  static const TextStyle wsSheetPinyinStyle = TextStyle(
    fontSize: 18.4,
    fontWeight: FontWeight.w600,
    color: BrandColors.navTeal,
  );
  static const TextStyle wsSheetMeaningStyle = TextStyle(
    fontSize: 16,
    height: 1.45,
    color: BrandColors.studyText,
  );

  // ── Card learners (`flashcards.css`: `.vl-*`) ─────────────────────────────
  static const double cardMaxWidth = 760;

  /// `.vl-card`: mint (`#cbe2d4`), `1px #afcfbd`, `24px` radius; `40/32` padding,
  /// `28/18` at ≤640px.
  static final BoxDecoration vlCardDecoration = BoxDecoration(
    color: BrandColors.background,
    border: Border.all(color: BrandColors.mintBorder),
    borderRadius: BorderRadius.circular(24),
  );
  static EdgeInsets vlCardPadding(double width) => width <= 640
      ? const EdgeInsets.symmetric(horizontal: 18, vertical: 28)
      : const EdgeInsets.symmetric(horizontal: 32, vertical: 40);

  /// `.vl-hanzi`: `80px` (`64px` at ≤640), `700`, `#111`.
  static TextStyle vlHanziStyle(double width) => TextStyle(
    fontSize: width <= 640 ? 64 : 80,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: BrandColors.darkText,
  );
  static const Color vlWrongChar = Color(0xFFEF4444);

  /// `.vl-pinyin`: `1.3rem`, `600`, teal; reserves `1.8rem` while hidden.
  static const TextStyle vlPinyinStyle = TextStyle(
    fontSize: 20.8,
    fontWeight: FontWeight.w600,
    color: BrandColors.navTeal,
  );
  static const double vlPinyinMinHeight = 28.8;

  /// `.vl-meaning`: `1.05rem`, `#2b2b2b`; reserves `1.5rem` while hidden.
  static const TextStyle vlMeaningStyle = TextStyle(
    fontSize: 16.8,
    color: Color(0xFF2B2B2B),
  );
  static const double vlMeaningMinHeight = 24;

  /// `.vl-counter`: `0.82rem`, muted.
  static const TextStyle vlCounterStyle = TextStyle(
    fontSize: 13.1,
    color: BrandColors.studyMuted,
  );

  /// `.vl-progress-bar`: `4px`, teal @15% track, teal fill.
  static const double vlProgressHeight = 4;
  static const Color vlProgressTrack = Color(0x26007A61);

  /// `.vl-input`: centred, `1.2rem`, `2px` teal @15% border, `8px` radius.
  static const TextStyle vlInputStyle = TextStyle(
    fontSize: 19.2,
    height: 1.4,
    color: BrandColors.studyText,
  );
  static InputDecoration vlInputDecoration(String hint, {required bool success}) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(
        color: success ? BrandColors.navTeal : const Color(0x26007A61),
        width: 2,
      ),
    );
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: success ? const Color(0xFFEAFAF3) : Colors.white,
      contentPadding: const EdgeInsets.all(12),
      border: border,
      enabledBorder: border,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: BrandColors.navTeal, width: 2),
      ),
    );
  }

  static const Color vlInputSuccessText = BrandColors.navTealHover;

  /// `.card-shortcut-item`: white, `1px` black @8%, `10px` radius, `40px` min height.
  static final BoxDecoration shortcutItemDecoration = BoxDecoration(
    color: Colors.white,
    border: Border.all(color: const Color(0x14000000)),
    borderRadius: BorderRadius.circular(10),
  );
  static const TextStyle shortcutLabelStyle = TextStyle(
    fontSize: 12.8,
    color: Color(0xFF6B7280),
  );
  static final BoxDecoration shortcutKeyDecoration = BoxDecoration(
    color: const Color(0xFFF8FAFC),
    border: const Border(
      top: BorderSide(color: Color(0x2E000000)),
      left: BorderSide(color: Color(0x2E000000)),
      right: BorderSide(color: Color(0x2E000000)),
      bottom: BorderSide(color: Color(0x2E000000), width: 2),
    ),
    borderRadius: BorderRadius.circular(6),
  );
  static const TextStyle shortcutKeyStyle = TextStyle(
    fontSize: 12.8,
    fontWeight: FontWeight.w700,
    color: Color(0xFF374151),
  );

  // ── Stroke-order panel (word popup) ───────────────────────────────────────
  /// Sage stroke color (`#576856`), matching `StrokeOrder.tsx`.
  static const Color strokeColor = BrandColors.primary;
  static const double strokeCanvasSize = 240;
  static const EdgeInsets strokeAreaPadding = EdgeInsets.only(top: 16);
  static const SizedBox strokeTabGap = SizedBox(width: 8);
  static const SizedBox strokeControlsTopGap = SizedBox(height: 12);
  static const SizedBox strokeControlsGap = SizedBox(width: 8);

  static final BoxDecoration strokeCanvasDecoration = BoxDecoration(
    color: BrandColors.card,
    border: Border.all(color: BrandColors.neutralBorder),
    borderRadius: BorderRadius.circular(12),
  );

  /// Per-character tab chip in the stroke panel (active = filled sage).
  static ButtonStyle strokeTabStyle(bool active) => OutlinedButton.styleFrom(
    backgroundColor: active
        ? BrandColors.primary
        : BrandColors.secondarySurface,
    foregroundColor: active ? BrandColors.card : BrandColors.bodyText,
    side: BorderSide(
      color: active ? BrandColors.primary : BrandColors.learnerBorder,
    ),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    minimumSize: const Size(0, 40),
    textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
  );

  // ── Grammar panel (`grammar-panel.css`) ───────────────────────────────────
  static const EdgeInsets grammarPagePadding = EdgeInsets.all(16);

  /// `.grammar-section`: `2px` sage @12% rule under every section but the last.
  static const BoxDecoration grammarSectionRule = BoxDecoration(
    border: Border(bottom: BorderSide(color: Color(0x1F576856), width: 2)),
  );

  /// `.grammar-title`: `1.5rem`, teal, centred, `1px` sage @10% underline.
  static const BoxDecoration grammarTitleRule = BoxDecoration(
    border: Border(bottom: BorderSide(color: Color(0x1A576856))),
  );
  static const TextStyle grammarTitleStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: BrandColors.navTeal,
  );
  static const TextStyle grammarDescStyle = TextStyle(
    fontSize: 16,
    height: 1.6,
    color: BrandColors.studyText,
  );

  /// `.ex-cn` / `.ex-vn` (examples): `1.15rem` / `0.95rem`.
  static const TextStyle grammarExampleCn = TextStyle(
    fontSize: 18.4,
    color: BrandColors.studyText,
  );
  static const TextStyle grammarExampleVn = TextStyle(
    fontSize: 15.2,
    color: Color(0xFF2B2B2B),
  );

  /// `.grammar-dialogue`: pale sage (`#eef4ec`) with a `#7fa07c` left bar.
  static const Color grammarDialogueFill = Color(0xFFEEF4EC);
  static const Color grammarDialogueBar = Color(0xFF7FA07C);
  static const TextStyle grammarDialogueCn = TextStyle(
    fontSize: 17.6,
    fontWeight: FontWeight.w600,
    height: 1.5,
    color: BrandColors.studyText,
  );

  /// `.grammar-table-ref`: green-tinted reference note.
  static final BoxDecoration grammarTableRef = BoxDecoration(
    color: const Color(0x1A10B981),
    border: Border.all(color: const Color(0xFF10B981)),
    borderRadius: BorderRadius.circular(6),
  );
  static const TextStyle grammarTableRefText = TextStyle(
    fontSize: 14.4,
    color: Color(0xFF10B981),
  );

  /// `.grammar-table-container`: white, `1px #d9ded9`, `8px` radius.
  static final BoxDecoration grammarTableBox = BoxDecoration(
    color: Colors.white,
    border: Border.all(color: BrandColors.partItemBorder),
    borderRadius: BorderRadius.circular(8),
  );
  static const TextStyle grammarTableHeader = TextStyle(
    fontSize: 15.2,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );
  static const TextStyle grammarTableCell = TextStyle(
    fontSize: 15.2,
    color: BrandColors.studyText,
  );

  // ── Generic vertical gaps ─────────────────────────────────────────────────
  static const SizedBox gap8 = SizedBox(height: 8);
  static const SizedBox gap16 = SizedBox(height: 16);

  // ── Translation drill (`translation-panel.css`) ───────────────────────────
  static const EdgeInsets translationPagePadding = EdgeInsets.all(16);
  static const TextStyle translationCounter = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: BrandColors.studyMuted,
  );
  static const double translationProgressHeight = 6;
  static const Color translationProgressTrack = Color(0x14000000);

  /// `.translation-card`: mint, `1px` teal @12%, `16px` radius, min `220px`.
  static final BoxDecoration translationCardDecoration = BoxDecoration(
    color: BrandColors.background,
    border: Border.all(color: const Color(0x1F007A61)),
    borderRadius: BorderRadius.circular(16),
    boxShadow: const [
      BoxShadow(color: Color(0x0A007A61), blurRadius: 8, offset: Offset(0, 2)),
    ],
  );
  static const double translationCardMinHeight = 220;
  static EdgeInsets translationCardPadding(double width) => width <= 600
      ? const EdgeInsets.symmetric(horizontal: 16, vertical: 24)
      : const EdgeInsets.symmetric(horizontal: 24, vertical: 32);
  static const TextStyle translationMeaning = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: BrandColors.studyText,
  );

  /// `.translation-input`: `20px` centred, `10px` radius; matched = green ring.
  static InputDecoration translationInputDecoration(
    String hint,
    bool matched,
  ) => InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(
        color: matched ? const Color(0xFF16A34A) : const Color(0x26000000),
        width: matched ? 2 : 1,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(
        color: matched ? const Color(0xFF16A34A) : BrandColors.navTeal,
        width: 2,
      ),
    ),
  );
  static const TextStyle translationInputText = TextStyle(
    fontSize: 20,
    color: BrandColors.darkText,
  );

  /// `.translation-answer`: `26px`, green, `700`.
  static const TextStyle translationAnswer = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: Color(0xFF16A34A),
  );

  /// `.translation-reveal-btn`: teal fill, white text, `8px` radius.
  static final ButtonStyle translationRevealButton = FilledButton.styleFrom(
    backgroundColor: BrandColors.navTeal,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    textStyle: const TextStyle(fontSize: 15),
  );
  static final ButtonStyle translationNavButton = OutlinedButton.styleFrom(
    foregroundColor: BrandColors.studyMuted,
    backgroundColor: BrandColors.toggleInactiveBg,
    side: const BorderSide(color: Color(0x1A000000)),
    minimumSize: const Size(0, 44),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
  );
  static final ButtonStyle translationPrimaryNav = FilledButton.styleFrom(
    backgroundColor: BrandColors.navTeal,
    foregroundColor: Colors.white,
    minimumSize: const Size(0, 44),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
  );

  // ── Pinyin guide ──────────────────────────────────────────────────────────
  static const EdgeInsets pinyinPagePadding = EdgeInsets.all(16);
  static const TextStyle pinyinHeading = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w800,
    color: BrandColors.darkText,
  );
  static const double pinyinCellHeight = 46;
  static const Color pinyinGridLine = BrandColors.neutralBorder;
  static const BoxDecoration pinyinHeaderCell = BoxDecoration(
    color: BrandColors.studyTealLight,
  );
  static const TextStyle pinyinHeaderText = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w800,
    color: BrandColors.navTeal,
  );
  static const BoxDecoration pinyinClickableCell = BoxDecoration(
    color: BrandColors.card,
  );
  static const BoxDecoration pinyinEmptyCell = BoxDecoration(
    color: BrandColors.secondarySurface,
  );
  static const TextStyle pinyinCellText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: BrandColors.darkText,
  );

  /// Basic / Advanced toggle chip.
  static ButtonStyle pinyinToggle(bool active) => TextButton.styleFrom(
    backgroundColor: active
        ? BrandColors.navTeal
        : BrandColors.secondarySurface,
    foregroundColor: active ? Colors.white : BrandColors.bodyText,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
    textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
  );
}
