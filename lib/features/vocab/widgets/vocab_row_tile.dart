/// Vocab module — one word row in the selection table / card list.
///
/// Shows hanzi, pinyin, the language-aware meaning and the HSK level, with an
/// audio button (when the word has a recording) and a stroke-order button.
/// Provider-free: the screen passes the play/stroke callbacks.
library;

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/data/vocab_row.dart';
import '../styles/vocab_styles.dart';

class VocabRowTile extends StatelessWidget {
  const VocabRowTile({
    super.key,
    required this.row,
    required this.isVi,
    required this.onPlayAudio,
    required this.onStroke,
  });

  final VocabRow row;
  final bool isVi;
  final VoidCallback? onPlayAudio;
  final VoidCallback onStroke;

  @override
  Widget build(BuildContext context) {
    final meaning = isVi
        ? (row.meaningVn.isNotEmpty ? row.meaningVn : row.meaningEn)
        : (row.meaningEn.isNotEmpty ? row.meaningEn : row.meaningVn);

    return Container(
      padding: VocabStyles.rowPadding,
      decoration: VocabStyles.rowCard,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Flexible(child: Text(row.cn, style: VocabStyles.hanzi)),
                    const SizedBox(width: 10),
                    if (row.pinyin.isNotEmpty)
                      Flexible(
                        child: Text(row.pinyin, style: VocabStyles.pinyin),
                      ),
                  ],
                ),
                if (meaning.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(meaning, style: VocabStyles.meaning),
                ],
                if (row.level.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text('HSK ${row.level}', style: VocabStyles.levelBadge),
                ],
              ],
            ),
          ),
          if (row.audioKey != null && row.audioKey!.isNotEmpty)
            IconButton(
              onPressed: onPlayAudio,
              icon: const Icon(Icons.volume_up, color: BrandColors.navTeal),
              tooltip: 'Audio',
            ),
          IconButton(
            onPressed: onStroke,
            icon: const Icon(Icons.gesture, color: BrandColors.primary),
            tooltip: 'Stroke order',
          ),
        ],
      ),
    );
  }
}
