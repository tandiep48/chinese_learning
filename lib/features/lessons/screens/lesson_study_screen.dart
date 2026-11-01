/// Lessons module — the lesson study reader (the Phase 5 proof).
///
/// Renders a passage's lines (`GET /api/lesson/passage/:id`) as hanzi word
/// tokens with toggleable pinyin and translation; tapping a word opens the
/// [showWordPopup] sheet with its vocab entry (`GET /api/lesson/vocab/:id`).
/// Ported from `LessonSummary.tsx`. Per-line audio and stroke order are
/// deferred (buttons present, wired in a later slice).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/loading_view.dart';
import '../data/models/lesson_passage.dart';
import '../data/models/lesson_vocab_row.dart';
import '../providers/lesson_providers.dart';
import '../styles/lessons_styles.dart';
import '../tokens.dart';
import '../widgets/word_popup.dart';

class LessonStudyScreen extends ConsumerStatefulWidget {
  const LessonStudyScreen({super.key, required this.passageId});

  final String passageId;

  @override
  ConsumerState<LessonStudyScreen> createState() => _LessonStudyScreenState();
}

class _LessonStudyScreenState extends ConsumerState<LessonStudyScreen> {
  bool _showPinyin = true;
  bool _showMeaning = true;

  void _audioComingSoon() {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.comingSoon)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final passage = ref.watch(passageDetailProvider(widget.passageId));

    // Vocab loads in parallel; the popup uses whatever is available.
    final vocab = ref.watch(passageVocabProvider(widget.passageId)).asData?.value ?? const [];
    final vocabByWord = <String, LessonVocabRow>{for (final v in vocab) v.cn: v};

    return Scaffold(
      appBar: AppBar(
        title: Text(passage.asData?.value.title ?? widget.passageId),
        actions: [
          IconButton(
            tooltip: _showPinyin ? l10n.studyHidePinyin : l10n.studyShowPinyin,
            isSelected: _showPinyin,
            icon: const Icon(Icons.subtitles_outlined),
            selectedIcon: const Icon(Icons.subtitles),
            onPressed: () => setState(() => _showPinyin = !_showPinyin),
          ),
          IconButton(
            tooltip: _showMeaning ? l10n.studyHideMeaning : l10n.studyShowMeaning,
            isSelected: _showMeaning,
            icon: const Icon(Icons.translate_outlined),
            selectedIcon: const Icon(Icons.translate),
            onPressed: () => setState(() => _showMeaning = !_showMeaning),
          ),
        ],
      ),
      body: SafeArea(
        child: passage.when(
          loading: () => const LoadingView(),
          error: (_, _) => EmptyState(
            icon: Icons.cloud_off,
            title: l10n.studyError,
            action: FilledButton.tonal(
              onPressed: () => ref.invalidate(passageDetailProvider(widget.passageId)),
              child: Text(l10n.commonRetry),
            ),
          ),
          data: (detail) {
            if (detail.lines.isEmpty) {
              return EmptyState(icon: Icons.notes_outlined, title: l10n.studyEmpty);
            }
            return ListView.separated(
              padding: LessonsStyles.listPadding,
              itemCount: detail.lines.length,
              separatorBuilder: (_, _) => const SizedBox(height: LessonsStyles.lineGap),
              itemBuilder: (context, i) => _PassageLineView(
                line: detail.lines[i],
                showPinyin: _showPinyin,
                showMeaning: _showMeaning,
                vocabByWord: vocabByWord,
                onAudio: _audioComingSoon,
              ),
            );
          },
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
  final VoidCallback onAudio;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final meaning = line.translationEn ?? line.translationVi;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (line.audioKey != null && line.audioKey!.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.volume_up_outlined),
            onPressed: onAudio,
          )
        else
          const SizedBox(width: 48),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (line.speaker != null && line.speaker!.isNotEmpty)
                Text(line.speaker!, style: theme.textTheme.bodySmall),
              _HanziLine(line: line, vocabByWord: vocabByWord),
              if (showPinyin && line.pinyin != null && line.pinyin!.isNotEmpty) ...[
                LessonsStyles.lineInnerGap,
                Text(
                  line.pinyin!,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
              if (showMeaning && meaning != null && meaning.isNotEmpty) ...[
                LessonsStyles.lineInnerGap,
                Text(meaning, style: theme.textTheme.bodyMedium),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// The hanzi row: tappable word tokens (punctuation is shown but not tappable).
/// Falls back to the raw content when the line has no tokens.
class _HanziLine extends StatelessWidget {
  const _HanziLine({required this.line, required this.vocabByWord});

  final LessonPassageLine line;
  final Map<String, LessonVocabRow> vocabByWord;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hanziStyle = theme.textTheme.headlineSmall;

    if (line.tokens.isEmpty) {
      return Text(line.content ?? '', style: hanziStyle);
    }

    return Wrap(
      spacing: LessonsStyles.tokenSpacing,
      runSpacing: LessonsStyles.tokenRunSpacing,
      children: [
        for (final token in line.tokens)
          if (isPunctToken(token))
            Text(token, style: hanziStyle)
          else
            InkWell(
              onTap: () => showWordPopup(
                context,
                word: token,
                entry: vocabByWord[token],
              ),
              child: Text(
                token,
                style: hanziStyle?.copyWith(color: theme.colorScheme.primary),
              ),
            ),
      ],
    );
  }
}
