/// Lessons module — the word popup shown when a learner taps a passage word.
///
/// Web-matched modal bottom sheet port of `WordPopup.tsx` + `word-popup.css`:
/// left-aligned teal hanzi (`2.8rem`), muted pinyin, primary VN meaning +
/// secondary EN meaning (or italic "not found" state), top-right circular close
/// button, and full-width tinted teal Listen / Stroke buttons. Listen plays the
/// word's GCS audio clip; stroke order is still deferred.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/audio/audio_player.dart';
import '../../../core/media/gcs.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../data/lesson_repository.dart';
import '../data/models/lesson_vocab_row.dart';
import '../styles/lessons_styles.dart';
import 'stroke_order_view.dart';

Future<void> showWordPopup(
  BuildContext context, {
  required String word,
  LessonVocabRow? entry,
  String? savePassageId,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: BrandColors.card,
    shape: LessonsStyles.wordPopupShape,
    isScrollControlled: true,
    constraints: const BoxConstraints(
      maxWidth: LessonsStyles.wordPopupMaxWidth,
    ),
    builder: (context) =>
        _WordPopupSheet(word: word, entry: entry, savePassageId: savePassageId),
  );
}

class _WordPopupSheet extends ConsumerStatefulWidget {
  const _WordPopupSheet({required this.word, this.entry, this.savePassageId});

  final String word;
  final LessonVocabRow? entry;

  /// Book-lesson passage whose personal list backs "Add to list"; null (HSK
  /// passages) hides the button, as on the web.
  final String? savePassageId;

  @override
  ConsumerState<_WordPopupSheet> createState() => _WordPopupSheetState();
}

class _WordPopupSheetState extends ConsumerState<_WordPopupSheet> {
  bool _strokeOpen = false;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    final id = widget.savePassageId;
    if (id == null) return;
    ref
        .read(lessonRepositoryProvider)
        .getSavedWords(id)
        .then((words) {
          if (mounted) setState(() => _saved = words.contains(widget.word));
        })
        .catchError((_) {});
  }

  /// Optimistic toggle; reverts when the request fails.
  Future<void> _toggleSaved() async {
    final id = widget.savePassageId;
    if (id == null) return;
    final repo = ref.read(lessonRepositoryProvider);
    final wasSaved = _saved;
    setState(() => _saved = !wasSaved);
    try {
      if (wasSaved) {
        await repo.removeSavedWord(id, widget.word);
      } else {
        await repo.addSavedWord(id, widget.word);
      }
    } catch (_) {
      if (mounted) setState(() => _saved = wasSaved);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final word = widget.word;
    final entry = widget.entry;
    final hasAudio = entry?.audioKey != null && entry!.audioKey!.isNotEmpty;

    final hasVn = entry != null && entry.meaningVn.isNotEmpty;
    final hasEn = entry != null && entry.meaningEn.isNotEmpty;
    final primaryMeaning = hasVn
        ? entry.meaningVn
        : (hasEn ? entry.meaningEn : '');
    final secondaryMeaning = (hasVn && hasEn) ? entry.meaningEn : '';

    return SafeArea(
      child: SingleChildScrollView(
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
                    Text(
                      entry.pinyin,
                      style: LessonsStyles.wordPopupPinyinStyle,
                    ),
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
                            onPressed: () {
                              final key = widget.entry?.audioKey;
                              if (key != null && key.isNotEmpty) {
                                ref
                                    .read(audioPlayerProvider)
                                    .playUrl(vocabAudioUrl(key));
                              }
                            },
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
                          onPressed: () =>
                              setState(() => _strokeOpen = !_strokeOpen),
                          icon: Icon(
                            _strokeOpen
                                ? Icons.keyboard_arrow_up
                                : Icons.edit_outlined,
                            size: LessonsStyles.toolbarIconSize,
                          ),
                          label: Text(l10n.wordStroke),
                        ),
                      ),
                      if (widget.savePassageId != null) ...[
                        LessonsStyles.wordPopupActionsBetweenGap,
                        Expanded(
                          child: OutlinedButton.icon(
                            style: _saved
                                ? LessonsStyles.wordPopupButtonActiveStyle
                                : LessonsStyles.wordPopupButtonStyle,
                            onPressed: _toggleSaved,
                            icon: Icon(
                              _saved ? Icons.check : Icons.add,
                              size: LessonsStyles.toolbarIconSize,
                            ),
                            label: Text(
                              _saved ? l10n.wordAdded : l10n.wordAddToList,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (_strokeOpen) StrokeOrderView(word: word),
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
      ),
    );
  }
}
