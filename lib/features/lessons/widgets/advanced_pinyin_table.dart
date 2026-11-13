/// Lessons module — the advanced pinyin chart (initial×final matrix).
///
/// Ported from `pinyin/AdvancedPinyinTable.tsx`: three wide tables; tap a
/// syllable to open its four toned forms, tap a tone to hear it. These syllables
/// have no recordings, so playback is text-to-speech (`ttsProvider`), matching
/// the web's `playTone` (browser `speechSynthesis`). Each table scrolls
/// horizontally on phones.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/audio/tts_service.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/loading_view.dart';
import '../../../l10n/app_localizations.dart';
import '../data/pinyin_data.dart';
import '../providers/lesson_providers.dart';
import '../styles/lessons_styles.dart';

const double _cellW = 48;

class AdvancedPinyinTable extends ConsumerWidget {
  const AdvancedPinyinTable({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final data = ref.watch(advancedPinyinProvider);
    return data.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: LoadingView(),
      ),
      error: (_, _) => EmptyState(
        icon: Icons.cloud_off,
        title: l10n.studyError,
        action: FilledButton.tonal(
          onPressed: () => ref.invalidate(advancedPinyinProvider),
          child: Text(l10n.commonRetry),
        ),
      ),
      data: (matrix) => Column(
        children: [
          for (final table in matrix.tables) ...[
            _table(context, ref, matrix.initials, table),
            LessonsStyles.gap16,
          ],
        ],
      ),
    );
  }

  Widget _table(
    BuildContext context,
    WidgetRef ref,
    List<String> initials,
    List<AdvancedPinyinRow> rows,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: LessonsStyles.pinyinGridLine),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _head(''),
                _head(''),
                for (final ini in initials) _head(ini),
              ],
            ),
            for (final row in rows)
              Row(
                children: [
                  _head(row.finalLabel),
                  for (final cell in row.cells) _cell(context, ref, cell),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _head(String text) => Container(
    width: _cellW,
    height: LessonsStyles.pinyinCellHeight,
    alignment: Alignment.center,
    decoration: LessonsStyles.pinyinHeaderCell.copyWith(
      border: Border.all(color: LessonsStyles.pinyinGridLine, width: 0.5),
    ),
    child: Text(text, style: LessonsStyles.pinyinHeaderText),
  );

  Widget _cell(BuildContext context, WidgetRef ref, String? syllable) {
    if (syllable == null) {
      return Container(
        width: _cellW,
        height: LessonsStyles.pinyinCellHeight,
        decoration: LessonsStyles.pinyinEmptyCell.copyWith(
          border: Border.all(color: LessonsStyles.pinyinGridLine, width: 0.5),
        ),
      );
    }
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showTones(context, ref, syllable),
        child: Container(
          width: _cellW,
          height: LessonsStyles.pinyinCellHeight,
          alignment: Alignment.center,
          decoration: LessonsStyles.pinyinClickableCell.copyWith(
            border: Border.all(color: LessonsStyles.pinyinGridLine, width: 0.5),
          ),
          child: Text(syllable, style: LessonsStyles.pinyinCellText),
        ),
      ),
    );
  }

  void _showTones(BuildContext context, WidgetRef ref, String syllable) {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final tone in getTones(syllable))
                FilledButton(
                  style: LessonsStyles.pinyinToggle(false),
                  onPressed: () {
                    ref.read(ttsProvider).speak(tone);
                    Navigator.of(sheetContext).pop();
                  },
                  child: Text(tone, style: LessonsStyles.pinyinCellText),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
