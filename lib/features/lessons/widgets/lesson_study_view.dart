/// Lessons module — the lesson study reader body (milestone step 4).
///
/// Body-only (no Scaffold/app bar) so it mounts as step 4 inside the milestone
/// runner. Renders a passage's lines (`GET /api/lesson/passage/:id`) in the web's
/// `.lesson-summary-toolbar` + `.lesson-preview-line` cards (`LessonSummary.tsx`):
/// clickable underlined hanzi tokens with toggleable pinyin and translation
/// (`translation_vi` first on VI, EN fallback); tapping a word opens
/// [showWordPopup] with its vocab entry (`GET /api/lesson/vocab/:id`). Per-line
/// audio plays the line's GCS clip (Auto Play streams every line in order);
/// stroke order is still deferred.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/audio/audio_player.dart';
import '../../../core/media/gcs.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/loading_view.dart';
import '../data/models/lesson_passage.dart';
import '../data/models/lesson_vocab_row.dart';
import '../providers/lesson_providers.dart';
import '../styles/lessons_styles.dart';
import '../tokens.dart';
import 'word_popup.dart';

class LessonStudyView extends ConsumerStatefulWidget {
  const LessonStudyView({super.key, required this.passageId});

  final String passageId;

  @override
  ConsumerState<LessonStudyView> createState() => _LessonStudyViewState();
}

class _LessonStudyViewState extends ConsumerState<LessonStudyView> {
  bool _showPinyin = true;
  bool _showMeaning = true;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final passage = ref.watch(passageDetailProvider(widget.passageId));

    // Vocab loads in parallel; the popup uses whatever is available.
    final vocab =
        ref.watch(passageVocabProvider(widget.passageId)).asData?.value ??
        const [];
    final vocabByWord = <String, LessonVocabRow>{
      for (final v in vocab) v.cn: v,
    };

    return passage.when(
      loading: () => const LoadingView(),
      error: (_, _) => EmptyState(
        icon: Icons.cloud_off,
        title: l10n.studyError,
        action: FilledButton.tonal(
          onPressed: () =>
              ref.invalidate(passageDetailProvider(widget.passageId)),
          child: Text(l10n.commonRetry),
        ),
      ),
      data: (detail) {
        if (detail.lines.isEmpty) {
          return EmptyState(icon: Icons.notes_outlined, title: l10n.studyEmpty);
        }
        final player = ref.read(audioPlayerProvider);
        final folder = lessonAudioFolder(
          hskLevel: detail.hskLevel,
          bookCode: detail.bookCode,
        );
        final autoPlayUrls = [
          for (final line in detail.lines)
            if (line.audioKey != null && line.audioKey!.isNotEmpty)
              lessonAudioUrl(folder, line.audioKey!),
        ];
        return ListView.separated(
          padding: LessonsStyles.studyPagePadding,
          itemCount: detail.lines.length + 1,
          separatorBuilder: (_, index) => index == 0
              ? LessonsStyles.summaryToolbarBottomGap
              : const SizedBox(height: LessonsStyles.lineGap),
          itemBuilder: (context, i) {
            if (i == 0) {
              return _LessonSummaryToolbar(
                showPinyin: _showPinyin,
                showMeaning: _showMeaning,
                onAutoPlay: () => player.playAll(autoPlayUrls),
                onTogglePinyin: () =>
                    setState(() => _showPinyin = !_showPinyin),
                onToggleMeaning: () =>
                    setState(() => _showMeaning = !_showMeaning),
              );
            }
            final line = detail.lines[i - 1];
            final audioKey = line.audioKey;
            return _PassageLineView(
              line: line,
              showPinyin: _showPinyin,
              showMeaning: _showMeaning,
              vocabByWord: vocabByWord,
              onAudio: (audioKey != null && audioKey.isNotEmpty)
                  ? () => player.playUrl(lessonAudioUrl(folder, audioKey))
                  : null,
            );
          },
        );
      },
    );
  }
}

/// Phone-responsive `.lesson-summary-toolbar`: a primary Auto Play button beside
/// stacked Pinyin / Meaning toggles.
class _LessonSummaryToolbar extends StatelessWidget {
  const _LessonSummaryToolbar({
    required this.showPinyin,
    required this.showMeaning,
    required this.onAutoPlay,
    required this.onTogglePinyin,
    required this.onToggleMeaning,
  });

  final bool showPinyin;
  final bool showMeaning;
  final VoidCallback onAutoPlay;
  final VoidCallback onTogglePinyin;
  final VoidCallback onToggleMeaning;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: LessonsStyles.summaryToolbarPadding,
      decoration: LessonsStyles.summaryToolbarDecoration,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: OutlinedButton(
                style: LessonsStyles.toolbarButtonStyle(active: true),
                onPressed: onAutoPlay,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.play_arrow,
                      size: LessonsStyles.toolbarIconSize,
                    ),
                    LessonsStyles.toolbarButtonIconGap,
                    Flexible(
                      child: Text(
                        l10n.studyAutoPlay,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            LessonsStyles.toolbarColumnGap,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  OutlinedButton(
                    style: LessonsStyles.toolbarButtonStyle(active: showPinyin),
                    onPressed: onTogglePinyin,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          showPinyin
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: LessonsStyles.toolbarIconSize,
                        ),
                        LessonsStyles.toolbarButtonIconGap,
                        Flexible(
                          child: Text(
                            showPinyin
                                ? l10n.studyHidePinyin
                                : l10n.studyShowPinyin,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  LessonsStyles.toolbarStackGap,
                  OutlinedButton(
                    style: LessonsStyles.toolbarButtonStyle(
                      active: showMeaning,
                    ),
                    onPressed: onToggleMeaning,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          showMeaning
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: LessonsStyles.toolbarIconSize,
                        ),
                        LessonsStyles.toolbarButtonIconGap,
                        Flexible(
                          child: Text(
                            showMeaning
                                ? l10n.studyHideMeaning
                                : l10n.studyShowMeaning,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PassageLineView extends StatelessWidget {
  const _PassageLineView({
    required this.line,
    required this.showPinyin,
    required this.showMeaning,
    required this.vocabByWord,
    required this.onAudio,
  });

  final LessonPassageLine line;
  final bool showPinyin;
  final bool showMeaning;
  final Map<String, LessonVocabRow> vocabByWord;
  final VoidCallback? onAudio;

  String? _resolveMeaning(BuildContext context) {
    final isVi = Localizations.localeOf(context).languageCode == 'vi';
    final vi = (line.translationVi != null && line.translationVi!.isNotEmpty)
        ? line.translationVi
        : null;
    final en = (line.translationEn != null && line.translationEn!.isNotEmpty)
        ? line.translationEn
        : null;
    return isVi ? (vi ?? en) : (en ?? vi);
  }

  @override
  Widget build(BuildContext context) {
    final meaning = _resolveMeaning(context);
    final hasAudio = line.audioKey != null && line.audioKey!.isNotEmpty;

    return Container(
      padding: LessonsStyles.previewLinePadding,
      decoration: LessonsStyles.previewLineDecoration,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (hasAudio)
            InkWell(
              customBorder: const CircleBorder(),
              onTap: onAudio,
              child: Container(
                width: LessonsStyles.audioBtnSize,
                height: LessonsStyles.audioBtnSize,
                decoration: LessonsStyles.audioBtnDecoration,
                alignment: Alignment.center,
                child: const Icon(
                  Icons.volume_up,
                  size: LessonsStyles.audioIconSize,
                  color: BrandColors.navTeal,
                ),
              ),
            )
          else
            const SizedBox(
              width: LessonsStyles.audioBtnSize,
              height: LessonsStyles.audioBtnSize,
            ),
          LessonsStyles.lineAudioGap,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (line.speaker != null && line.speaker!.isNotEmpty) ...[
                  Text(line.speaker!, style: LessonsStyles.speakerStyle),
                  LessonsStyles.lineInnerGap,
                ],
                _HanziLine(line: line, vocabByWord: vocabByWord),
                if (showPinyin &&
                    line.pinyin != null &&
                    line.pinyin!.isNotEmpty) ...[
                  LessonsStyles.lineInnerGap,
                  Text(line.pinyin!, style: LessonsStyles.pinyinStyle),
                ],
                if (showMeaning && meaning != null && meaning.isNotEmpty) ...[
                  LessonsStyles.lineInnerGap,
                  Text(meaning, style: LessonsStyles.meaningStyle),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The hanzi row: clickable underlined word tokens; punctuation renders inline
/// without underline. Falls back to raw content when the line has no tokens.
class _HanziLine extends StatelessWidget {
  const _HanziLine({required this.line, required this.vocabByWord});

  final LessonPassageLine line;
  final Map<String, LessonVocabRow> vocabByWord;

  @override
  Widget build(BuildContext context) {
    if (line.tokens.isEmpty) {
      return Text(line.content ?? '', style: LessonsStyles.hanziPlainStyle);
    }

    return Wrap(
      spacing: LessonsStyles.tokenSpacing,
      runSpacing: LessonsStyles.tokenRunSpacing,
      children: [
        for (final token in line.tokens)
          if (isPunctToken(token))
            Text(token, style: LessonsStyles.hanziPlainStyle)
          else
            InkWell(
              borderRadius: BorderRadius.circular(4),
              onTap: () => showWordPopup(
                context,
                word: token,
                entry: vocabByWord[token],
              ),
              child: Text(token, style: LessonsStyles.hanziClickableStyle),
            ),
      ],
    );
  }
}
