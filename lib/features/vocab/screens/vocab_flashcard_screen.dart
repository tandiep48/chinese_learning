/// Vocab module — flashcard study of an arbitrary word list.
///
/// Ported from the `/vocab-learning` FlashcardStudy flow: a swipeable deck of
/// flip cards (front = hanzi + audio; back = pinyin + meaning), with a progress
/// counter. Entered from the Vocab selection page's "Flash Cards" action with the
/// current page's words.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/audio/audio_player.dart';
import '../../../core/media/gcs.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/data/vocab_row.dart';
import '../../../shared/widgets/empty_state.dart';
import '../styles/vocab_styles.dart';

class VocabFlashcardScreen extends ConsumerStatefulWidget {
  const VocabFlashcardScreen({super.key, required this.words});

  final List<VocabRow> words;

  @override
  ConsumerState<VocabFlashcardScreen> createState() =>
      _VocabFlashcardScreenState();
}

class _VocabFlashcardScreenState extends ConsumerState<VocabFlashcardScreen> {
  final _controller = PageController();
  int _index = 0;
  final Set<int> _flipped = {};

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isVi = Localizations.localeOf(context).languageCode == 'vi';

    return Scaffold(
      backgroundColor: BrandColors.background,
      appBar: AppBar(
        backgroundColor: BrandColors.background,
        title: Text(l10n.vocabFlashcardsTitle),
      ),
      body: widget.words.isEmpty
          ? Center(
              child: EmptyState(
                icon: Icons.inbox_outlined,
                title: l10n.vocabNoVocabFound,
              ),
            )
          : SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      '${_index + 1} / ${widget.words.length}',
                      style: VocabStyles.subtitle,
                    ),
                  ),
                  Expanded(
                    child: PageView.builder(
                      controller: _controller,
                      itemCount: widget.words.length,
                      onPageChanged: (i) => setState(() => _index = i),
                      itemBuilder: (context, i) =>
                          _card(l10n, isVi, widget.words[i], i),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _card(AppLocalizations l10n, bool isVi, VocabRow row, int i) {
    final flipped = _flipped.contains(i);
    final meaning = isVi
        ? (row.meaningVn.isNotEmpty ? row.meaningVn : row.meaningEn)
        : (row.meaningEn.isNotEmpty ? row.meaningEn : row.meaningVn);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: GestureDetector(
        onTap: () => setState(() {
          if (flipped) {
            _flipped.remove(i);
          } else {
            _flipped.add(i);
          }
        }),
        child: Container(
          decoration: VocabStyles.rowCard,
          alignment: Alignment.center,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!flipped) ...[
                Text(
                  row.cn,
                  style: const TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.w700,
                    color: BrandColors.bodyText,
                  ),
                ),
                const SizedBox(height: 16),
                if (row.audioKey != null && row.audioKey!.isNotEmpty)
                  IconButton(
                    iconSize: 32,
                    color: BrandColors.navTeal,
                    onPressed: () => ref
                        .read(audioPlayerProvider)
                        .playUrl(vocabAudioUrl(row.audioKey!)),
                    icon: const Icon(Icons.volume_up),
                  ),
                const SizedBox(height: 8),
                Text(l10n.vocabTapToReveal, style: VocabStyles.subtitle),
              ] else ...[
                if (row.pinyin.isNotEmpty)
                  Text(
                    row.pinyin,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: BrandColors.navTeal,
                    ),
                  ),
                const SizedBox(height: 16),
                Text(
                  meaning,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    color: BrandColors.bodyText,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
