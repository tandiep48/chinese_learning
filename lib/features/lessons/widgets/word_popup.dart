/// Lessons module — the word popup shown when a learner taps a passage word.
///
/// Native modal bottom sheet port of `WordPopup.tsx`: the hanzi, its pinyin,
/// the VN + EN meaning (or a "not found" state), and Listen / Strokes actions.
/// Audio and stroke order are deferred in this slice (buttons present, wired
/// later); the book-lesson save toggle is out of this slice.
library;

import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../data/models/lesson_vocab_row.dart';

Future<void> showWordPopup(
  BuildContext context, {
  required String word,
  LessonVocabRow? entry,
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
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
    final theme = Theme.of(context);
    final entry = this.entry;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(word, style: theme.textTheme.displaySmall),
            ),
            if (entry != null) ...[
              const SizedBox(height: 4),
              Center(
                child: Text(entry.pinyin, style: theme.textTheme.titleLarge),
              ),
              const SizedBox(height: 16),
              Text(entry.meaningVn, style: theme.textTheme.bodyLarge),
              if (entry.meaningEn.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  entry.meaningEn,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ] else ...[
              const SizedBox(height: 16),
              Text(
                l10n.wordNotFound,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                if (entry?.audioKey != null && entry!.audioKey!.isNotEmpty)
                  OutlinedButton.icon(
                    onPressed: () => _comingSoon(context),
                    icon: const Icon(Icons.volume_up),
                    label: Text(l10n.wordListen),
                  ),
                if (entry?.audioKey != null && entry!.audioKey!.isNotEmpty)
                  const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () => _comingSoon(context),
                  icon: const Icon(Icons.draw),
                  label: Text(l10n.wordStroke),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
