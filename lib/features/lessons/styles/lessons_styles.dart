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

  static const EdgeInsets bookHeaderPadding = EdgeInsets.only(bottom: 20);
  static const double bookHeaderCoverHeight = 140;
  static const SizedBox bookHeaderGap = SizedBox(height: 12);

  static const TextStyle bookHeaderTitleStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    color: BrandColors.darkText,
  );

  static const TextStyle bookHeaderSubtitleStyle = TextStyle(
    fontSize: 15,
    color: BrandColors.subtitleText,
  );

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
  static const EdgeInsets partListPadding = EdgeInsets.fromLTRB(14, 0, 14, 14);
  static const SizedBox partItemGap = SizedBox(height: 10);
  static final BorderRadius partItemRadius = BorderRadius.circular(8);

  static final BoxDecoration partItemDecoration = BoxDecoration(
    color: BrandColors.card,
    border: Border.all(color: BrandColors.partItemBorder),
    borderRadius: partItemRadius,
    boxShadow: const [
      BoxShadow(color: Color(0x0F576856), blurRadius: 10, offset: Offset(0, 3)),
    ],
  );

  static const EdgeInsets partItemInnerPadding = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 14,
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
  static const double levelGridSpacing = 14;
  static const double levelCardAspectRatio = 1.15;
  static final BorderRadius levelCardRadius = BorderRadius.circular(16);
  static const EdgeInsets levelCardImagePadding = EdgeInsets.all(18);

  /// Fallback text shown on a level card when its cover image fails to load.
  static const TextStyle levelLabelStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w800,
    color: BrandColors.darkText,
  );

  // ── HSK lesson picker header (`.picker-header-section`) ────────────────────
  static const EdgeInsets hskListPadding = EdgeInsets.fromLTRB(16, 16, 16, 24);
  static const EdgeInsets hskHeaderPadding = EdgeInsets.all(16);
  static final BorderRadius hskHeaderRadius = BorderRadius.circular(16);
  static const double hskHeaderImageSize = 72;
  static const SizedBox hskHeaderGap = SizedBox(width: 14);
  static const SizedBox hskHeaderTitleGap = SizedBox(height: 4);
  static const SizedBox hskHeaderBottomGap = SizedBox(height: 16);

  static BoxDecoration hskHeaderDecoration(Color color) =>
      BoxDecoration(color: color, borderRadius: hskHeaderRadius);

  static const TextStyle hskHeaderTitleStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w800,
    color: BrandColors.darkText,
  );

  static const TextStyle hskHeaderSubtitleStyle = TextStyle(
    fontSize: 14,
    color: BrandColors.subtitleText,
  );

  /// `.picker-header-image` graduation-cap fallback tile.
  static const double hskHeaderFallbackIconSize = 36;

  // ── HSK lesson search (`.picker-search-row`) ──────────────────────────────
  static const SizedBox hskSearchGap = SizedBox(height: 16);

  static InputDecoration hskSearchDecoration(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: BrandColors.mutedText),
    prefixIcon: const Icon(Icons.search, color: BrandColors.mutedText),
    filled: true,
    fillColor: BrandColors.card,
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: BrandColors.neutralBorder),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: BrandColors.neutralBorder),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: BrandColors.navTeal),
    ),
  );

  static const EdgeInsets hskEmptyPadding = EdgeInsets.symmetric(vertical: 32);
  static const TextStyle hskEmptyTextStyle = TextStyle(
    fontSize: 14,
    color: BrandColors.mutedText,
  );

  // ── Study reader (`lesson-study.css` + `lesson-summary.css`) ──────────────

  static const EdgeInsets studyPagePadding = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 20,
  );

  /// `.lesson-summary-toolbar`: white card, `8px` radius, `12px` padding, subtle teal shadow.
  static final BoxDecoration summaryToolbarDecoration = BoxDecoration(
    color: BrandColors.card,
    border: Border.all(color: const Color(0x0F000000)),
    borderRadius: BorderRadius.circular(8),
    boxShadow: const [
      BoxShadow(color: Color(0x0A007A61), blurRadius: 8, offset: Offset(0, 2)),
    ],
  );

  static const EdgeInsets summaryToolbarPadding = EdgeInsets.all(12);
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

  /// Flash card (step 2) + lesson-line card (step 5): a tall tappable card.
  static final BoxDecoration flashCardDecoration = BoxDecoration(
    color: BrandColors.card,
    border: Border.all(color: BrandColors.mintBorder),
    borderRadius: BorderRadius.circular(20),
    boxShadow: const [
      BoxShadow(color: Color(0x0F576856), blurRadius: 10, offset: Offset(0, 3)),
    ],
  );
  static const EdgeInsets flashCardPadding = EdgeInsets.all(24);
  static const double flashCardMinHeight = 220;

  static const TextStyle flashCardHanziStyle = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: BrandColors.darkText,
  );
  static const TextStyle flashCardPinyinStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: BrandColors.navTeal,
  );
  static const TextStyle flashCardMeaningStyle = TextStyle(
    fontSize: 18,
    color: BrandColors.studyMuted,
  );
  static const TextStyle flashCardHintStyle = TextStyle(
    fontSize: 13,
    color: BrandColors.mutedText,
  );
  static const SizedBox flashCardGap = SizedBox(height: 12);

  /// Card-viewer navigation (Prev / counter / Next).
  static const SizedBox cardNavGap = SizedBox(height: 16);
  static const TextStyle cardCounterStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: BrandColors.mutedText,
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

  // ── Grammar panel (lesson-wide grammar) ───────────────────────────────────
  static const EdgeInsets grammarPagePadding = EdgeInsets.all(16);
  static final BoxDecoration grammarSectionDecoration = BoxDecoration(
    color: BrandColors.card,
    border: Border.all(color: BrandColors.neutralBorder),
    borderRadius: BorderRadius.circular(12),
  );
  static const EdgeInsets grammarSectionPadding = EdgeInsets.all(16);
  static const SizedBox grammarSectionGap = SizedBox(height: 16);
  static const SizedBox grammarRowGap = SizedBox(height: 8);

  static const TextStyle grammarTitleStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w800,
    color: BrandColors.navTeal,
  );
  static const TextStyle grammarDescStyle = TextStyle(
    fontSize: 15,
    height: 1.5,
    color: BrandColors.studyText,
  );
  static const TextStyle grammarExampleCn = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: BrandColors.darkText,
  );
  static const TextStyle grammarExampleVn = TextStyle(
    fontSize: 14,
    color: BrandColors.studyMuted,
  );
  static final BoxDecoration grammarExampleDecoration = BoxDecoration(
    color: BrandColors.secondarySurface,
    borderRadius: BorderRadius.circular(8),
  );
  static const EdgeInsets grammarExamplePadding = EdgeInsets.all(10);

  static const TextStyle grammarTableHeader = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: BrandColors.bodyText,
  );
  static const TextStyle grammarTableCell = TextStyle(
    fontSize: 14,
    color: BrandColors.studyText,
  );
  static final BorderSide grammarTableBorder = BorderSide(
    color: BrandColors.neutralBorder,
  );

  // ── Translation drill ─────────────────────────────────────────────────────
  static const EdgeInsets translationPagePadding = EdgeInsets.all(16);
  static const TextStyle translationCounter = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: BrandColors.mutedText,
  );
  static const double translationProgressHeight = 6;
  static const Color translationProgressTrack = Color(0xFFF1F1F1);
  static final BoxDecoration translationCardDecoration = BoxDecoration(
    color: BrandColors.card,
    border: Border.all(color: BrandColors.mintBorder),
    borderRadius: BorderRadius.circular(16),
  );
  static const EdgeInsets translationCardPadding = EdgeInsets.all(20);
  static const TextStyle translationMeaning = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: BrandColors.studyText,
  );
  static InputDecoration translationInputDecoration(
    String hint,
    bool matched,
  ) => InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: matched ? const Color(0x1410B981) : BrandColors.card,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: matched ? BrandColors.success : BrandColors.neutralBorder,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: matched ? BrandColors.success : BrandColors.navTeal,
        width: 2,
      ),
    ),
  );
  static const TextStyle translationInputText = TextStyle(
    fontSize: 20,
    color: BrandColors.darkText,
  );
  static const TextStyle translationAnswer = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: BrandColors.navTeal,
  );
  static final ButtonStyle translationNavButton = OutlinedButton.styleFrom(
    foregroundColor: BrandColors.bodyText,
    side: const BorderSide(color: BrandColors.neutralBorder),
    minimumSize: const Size(0, 44),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
  );
  static final ButtonStyle translationPrimaryNav = FilledButton.styleFrom(
    backgroundColor: BrandColors.navTeal,
    foregroundColor: Colors.white,
    minimumSize: const Size(0, 44),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
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
