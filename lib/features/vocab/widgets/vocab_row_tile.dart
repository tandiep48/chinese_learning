/// Vocab module — one word card in the selection list.
///
/// Phone `.vcl-card` of `vocab-card-list.css`: the hanzi on the left, pinyin
/// (teal) over a two-line meaning, then the audio and stroke-order buttons.
/// Provider-free: the screen passes the play / stroke callbacks.
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
        children: [
          Text(row.cn, style: VocabStyles.hanzi),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (row.pinyin.isNotEmpty)
                  Text(row.pinyin, style: VocabStyles.pinyin),
                if (meaning.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    meaning,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: VocabStyles.meaning,
                  ),
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
            icon: const Icon(Icons.gesture, color: BrandColors.navTeal),
            tooltip: 'Stroke order',
          ),
        ],
      ),
    );
  }
}
