/// Lessons module — the word popup shown when a learner taps a passage word.
///
/// Web-matched modal bottom sheet port of `WordPopup.tsx` + `word-popup.css`:
/// left-aligned teal hanzi (`2.8rem`), muted pinyin, primary VN meaning +
/// secondary EN meaning (or italic "not found" state), top-right circular close
/// button, and full-width tinted teal Listen / Stroke buttons.
library;

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../data/models/lesson_vocab_row.dart';
import '../styles/lessons_styles.dart';

Future<void> showWordPopup(
  BuildContext context, {
  required String word,
  LessonVocabRow? entry,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: BrandColors.card,
    shape: LessonsStyles.wordPopupShape,
    constraints: const BoxConstraints(
      maxWidth: LessonsStyles.wordPopupMaxWidth,
    ),
    builder: (context) => _WordPopupSheet(word: word, entry: entry),
  );
}

class _WordPopupSheet extends StatelessWidget {
  const _WordPopupSheet({required this.word, this.entry});

  final String word;
  final LessonVocabRow? entry;

  void _comingSoon(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.comingSoon)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final entry = this.entry;
    final hasAudio = entry?.audioKey != null && entry!.audioKey!.isNotEmpty;

    final hasVn = entry != null && entry.meaningVn.isNotEmpty;
    final hasEn = entry != null && entry.meaningEn.isNotEmpty;
    final primaryMeaning = hasVn ? entry.meaningVn : (hasEn ? entry.meaningEn : '');
    final secondaryMeaning = (hasVn && hasEn) ? entry.meaningEn : '';

    return SafeArea(
      child: Padding(
        padding: LessonsStyles.wordPopupPadding,
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(word, style: LessonsStyles.wordPopupHanziStyle),
                LessonsStyles.wordPopupHanziGap,
                if (entry != null && entry.pinyin.isNotEmpty) ...[
                  Text(entry.pinyin, style: LessonsStyles.wordPopupPinyinStyle),
                  LessonsStyles.wordPopupPinyinGap,
                ],
                if (entry == null)
                  Text(
                    l10n.wordNotFound,
                    style: LessonsStyles.wordPopupNotFoundStyle,
                  )
                else ...[
                  if (primaryMeaning.isNotEmpty)
                    Text(
                      primaryMeaning,
                      style: LessonsStyles.wordPopupMeaningStyle,
                    ),
                  if (secondaryMeaning.isNotEmpty) ...[
                    LessonsStyles.wordPopupMeaningGap,
                    Text(
                      secondaryMeaning,
                      style: LessonsStyles.wordPopupMeaningSecondaryStyle,
                    ),
                  ],
                ],
                LessonsStyles.wordPopupActionsTopGap,
                Row(
                  children: [
                    if (hasAudio) ...[
                      Expanded(
                        child: OutlinedButton.icon(
                          style: LessonsStyles.wordPopupButtonStyle,
                          onPressed: () => _comingSoon(context),
                          icon: const Icon(
                            Icons.volume_up,
                            size: LessonsStyles.toolbarIconSize,
                          ),
                          label: Text(l10n.wordListen),
                        ),
                      ),
                      LessonsStyles.wordPopupActionsBetweenGap,
                    ],
                    Expanded(
                      child: OutlinedButton.icon(
                        style: LessonsStyles.wordPopupButtonStyle,
                        onPressed: () => _comingSoon(context),
                        icon: const Icon(
                          Icons.edit_outlined,
                          size: LessonsStyles.toolbarIconSize,
                        ),
                        label: Text(l10n.wordStroke),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Positioned(
              top: 0,
              right: 0,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: LessonsStyles.wordPopupCloseSize,
                  height: LessonsStyles.wordPopupCloseSize,
                  decoration: LessonsStyles.wordPopupCloseDecoration,
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.close,
                    size: LessonsStyles.wordPopupCloseIconSize,
                    color: BrandColors.studyMuted,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
