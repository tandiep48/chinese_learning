/// Lessons module — the basic pinyin chart (initials + finals + toned vowels).
///
/// Ported from `pinyin/BasicPinyinTable.tsx`: a fixed 8-column grid; tap a cell
/// to hear it (recordings from the `audio_pinyin` bucket via the core audio
/// player) and see its pronunciation hint (shown as a brief snackbar on mobile,
/// in place of the web's hover tooltip).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/audio/audio_player.dart';
import '../../../core/media/gcs.dart';
import '../../../l10n/app_localizations.dart';
import '../data/pinyin_data.dart';
import '../styles/lessons_styles.dart';

class BasicPinyinTable extends ConsumerWidget {
  const BasicPinyinTable({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: LessonsStyles.pinyinGridLine),
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Row(
            children: [
              _header(l10n.pinyinInitials),
              _header(l10n.pinyinFinals),
            ],
          ),
          for (var i = 0; i < basicFinalRows.length; i++)
            _row(context, ref, l10n, i),
        ],
      ),
    );
  }

  Widget _header(String text) => Expanded(
    child: Container(
      height: LessonsStyles.pinyinCellHeight,
      alignment: Alignment.center,
      decoration: LessonsStyles.pinyinHeaderCell,
      child: Text(text, style: LessonsStyles.pinyinHeaderText),
    ),
  );

  Widget _row(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    int i,
  ) {
    final finals = basicFinalRows[i];
    final children = <Widget>[];

    if (i == 6) {
      // The "Tones" section head spans the left half.
      children.add(
        Expanded(
          flex: 4,
          child: Container(
            height: LessonsStyles.pinyinCellHeight,
            alignment: Alignment.center,
            decoration: LessonsStyles.pinyinHeaderCell,
            child: Text(
              l10n.pinyinTones,
              style: LessonsStyles.pinyinHeaderText,
            ),
          ),
        ),
      );
    } else {
      final left = i < 6 ? basicInitialRows[i] : basicToneRows[i - 7];
      for (final v in left) {
        children.add(Expanded(child: _cell(context, ref, l10n, v)));
      }
    }
    for (final v in finals) {
      children.add(Expanded(child: _cell(context, ref, l10n, v)));
    }
    return Row(children: children);
  }

  Widget _cell(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    String? value,
  ) {
    if (value == null) {
      return Container(
        height: LessonsStyles.pinyinCellHeight,
        decoration: LessonsStyles.pinyinEmptyCell.copyWith(
          border: Border.all(color: LessonsStyles.pinyinGridLine, width: 0.5),
        ),
      );
    }
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _play(context, ref, l10n, value),
        child: Container(
          height: LessonsStyles.pinyinCellHeight,
          alignment: Alignment.center,
          decoration: LessonsStyles.pinyinClickableCell.copyWith(
            border: Border.all(color: LessonsStyles.pinyinGridLine, width: 0.5),
          ),
          child: Text(value, style: LessonsStyles.pinyinCellText),
        ),
      ),
    );
  }

  void _play(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    String value,
  ) {
    ref
        .read(audioPlayerProvider)
        .playUrl(pinyinAudioUrl(pinyinAudioSyllable(value)));
    final hint =
        pinyinPronunciation[value] ?? l10n.pinyinPronunciationFor(value);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(hint),
          duration: const Duration(milliseconds: 1500),
        ),
      );
  }
}
