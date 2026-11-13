/// Lessons module — the Word Summary (milestone step 1).
///
/// Phone layout of `WordSummary.tsx` (`hideActions`): a toolbar (Play All /
/// Shuffle, plus Pinyin / Meaning column toggles), then a tappable `.ws-card`
/// per word — audio button first, number, hanzi, pinyin and a two-line meaning —
/// that opens a detail sheet (hanzi, pinyin, meaning, Listen, Stroke order).
/// The word playing during Play All is highlighted and scrolled into view. Data
/// from `GET /api/lesson/vocab/:id` via [passageVocabProvider]; passive — the
/// milestone's Next completes the step.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/audio/audio_player.dart';
import '../../../core/media/gcs.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/loading_view.dart';
import '../data/models/lesson_vocab_row.dart';
import '../providers/lesson_providers.dart';
import '../styles/lessons_styles.dart';
import 'stroke_order_view.dart';

String learnerMeaning(BuildContext context, String vn, String en) {
  final isVi = Localizations.localeOf(context).languageCode == 'vi';
  return isVi ? (vn.isNotEmpty ? vn : en) : (en.isNotEmpty ? en : vn);
}

class WordSummaryView extends ConsumerWidget {
  const WordSummaryView({super.key, required this.passageId});

  final String passageId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final vocab = ref.watch(passageVocabProvider(passageId));

    return vocab.when(
      loading: () => const LoadingView(),
      error: (_, _) => EmptyState(
        icon: Icons.cloud_off,
        title: l10n.studyError,
        action: FilledButton.tonal(
          onPressed: () => ref.invalidate(passageVocabProvider(passageId)),
          child: Text(l10n.commonRetry),
        ),
      ),
      data: (rows) {
        if (rows.isEmpty) {
          return EmptyState(
            icon: Icons.menu_book_outlined,
            title: l10n.vocabNoWords,
          );
        }
        return _WordSummaryList(rows: rows);
      },
    );
  }
}

class _WordSummaryList extends ConsumerStatefulWidget {
  const _WordSummaryList({required this.rows});

  final List<LessonVocabRow> rows;

  @override
  ConsumerState<_WordSummaryList> createState() => _WordSummaryListState();
}

class _WordSummaryListState extends ConsumerState<_WordSummaryList> {
  late List<LessonVocabRow> _items = [...widget.rows];
  bool _hidePinyin = false;
  bool _hideMeaning = false;

  int? _activeIndex;
  bool _sequenceActive = false;
  int _playToken = 0;
  final Map<int, GlobalKey> _keys = {};

  @override
  void dispose() {
    _playToken++;
    ref.read(audioPlayerProvider).stop();
    super.dispose();
  }

  void _setActive(int? index) {
    setState(() => _activeIndex = index);
    final ctx = index == null ? null : _keys[index]?.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        alignment: 0.5,
        duration: const Duration(milliseconds: 300),
      );
    }
  }

  Future<void> _playSingle(int index) async {
    final key = _items[index].audioKey;
    if (key == null || key.isEmpty) return;
    final token = ++_playToken;
    setState(() => _sequenceActive = false);
    _setActive(index);
    await ref.read(audioPlayerProvider).playUrl(vocabAudioUrl(key));
    if (mounted && token == _playToken) _setActive(null);
  }

  Future<void> _toggleSequence() async {
    final player = ref.read(audioPlayerProvider);
    if (_sequenceActive) {
      _playToken++;
      await player.stop();
      if (mounted) {
        setState(() => _sequenceActive = false);
        _setActive(null);
      }
      return;
    }
    final token = ++_playToken;
    setState(() => _sequenceActive = true);
    for (var i = 0; i < _items.length; i++) {
      final key = _items[i].audioKey;
      if (key == null || key.isEmpty) continue;
      if (!mounted || token != _playToken) return;
      _setActive(i);
      await player.playUrl(vocabAudioUrl(key));
    }
    if (mounted && token == _playToken) {
      setState(() => _sequenceActive = false);
      _setActive(null);
    }
  }

  void _shuffle() => setState(() {
    _items = [..._items]..shuffle();
    _activeIndex = null;
  });

  @override
  Widget build(BuildContext context) {
    final hasAudio = _items.any((r) => (r.audioKey ?? '').isNotEmpty);

    return ListView.builder(
      padding: LessonsStyles.studyPagePadding,
      itemCount: _items.length + 1,
      itemBuilder: (context, i) {
        if (i == 0) {
          return Padding(
            padding: LessonsStyles.summaryToolbarBottomPadding,
            child: _Toolbar(
              sequenceActive: _sequenceActive,
              canPlay: hasAudio,
              hidePinyin: _hidePinyin,
              hideMeaning: _hideMeaning,
              onPlay: _toggleSequence,
              onShuffle: _shuffle,
              onTogglePinyin: () => setState(() => _hidePinyin = !_hidePinyin),
              onToggleMeaning: () =>
                  setState(() => _hideMeaning = !_hideMeaning),
            ),
          );
        }
        final index = i - 1;
        final row = _items[index];
        return Padding(
          padding: EdgeInsets.only(bottom: index == _items.length - 1 ? 0 : 10),
          child: _WsCard(
            key: _keys.putIfAbsent(index, GlobalKey.new),
            row: row,
            number: index + 1,
            highlighted: _activeIndex == index,
            hidePinyin: _hidePinyin,
            hideMeaning: _hideMeaning,
            onAudio: (row.audioKey ?? '').isEmpty
                ? null
                : () => _playSingle(index),
            onOpen: () => _openDetail(row, index),
          ),
        );
      },
    );
  }

  void _openDetail(LessonVocabRow row, int index) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: BrandColors.card,
      shape: LessonsStyles.wordPopupShape,
      constraints: const BoxConstraints(maxWidth: 520),
      builder: (_) => _DetailSheet(
        row: row,
        onListen: (row.audioKey ?? '').isEmpty
            ? null
            : () => _playSingle(index),
      ),
    );
  }
}

class _Toolbar extends StatelessWidget {
  const _Toolbar({
    required this.sequenceActive,
    required this.canPlay,
    required this.hidePinyin,
    required this.hideMeaning,
    required this.onPlay,
    required this.onShuffle,
    required this.onTogglePinyin,
    required this.onToggleMeaning,
  });

  final bool sequenceActive;
  final bool canPlay;
  final bool hidePinyin;
  final bool hideMeaning;
  final VoidCallback onPlay;
  final VoidCallback onShuffle;
  final VoidCallback onTogglePinyin;
  final VoidCallback onToggleMeaning;

  Widget _button({
    required VoidCallback? onPressed,
    required IconData icon,
    required String label,
    required bool active,
  }) {
    return OutlinedButton(
      style: LessonsStyles.toolbarButtonStyle(active: active),
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: LessonsStyles.toolbarIconSize),
          LessonsStyles.toolbarButtonIconGap,
          Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _button(
                    onPressed: canPlay ? onPlay : null,
                    icon: sequenceActive ? Icons.stop : Icons.play_arrow,
                    label: sequenceActive
                        ? l10n.studyStopAutoPlay
                        : l10n.wordSummaryPlayAll,
                    active: true,
                  ),
                  LessonsStyles.toolbarStackGap,
                  _button(
                    onPressed: onShuffle,
                    icon: Icons.shuffle,
                    label: l10n.wordSummaryShuffle,
                    active: false,
                  ),
                ],
              ),
            ),
            LessonsStyles.toolbarColumnGap,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _button(
                    onPressed: onTogglePinyin,
                    icon: hidePinyin
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    label: l10n.wordSummaryPinyin,
                    active: hidePinyin,
                  ),
                  LessonsStyles.toolbarStackGap,
                  _button(
                    onPressed: onToggleMeaning,
                    icon: hideMeaning
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    label: l10n.wordSummaryMeaning,
                    active: hideMeaning,
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

class _WsCard extends StatelessWidget {
  const _WsCard({
    super.key,
    required this.row,
    required this.number,
    required this.highlighted,
    required this.hidePinyin,
    required this.hideMeaning,
    required this.onAudio,
    required this.onOpen,
  });

  final LessonVocabRow row;
  final int number;
  final bool highlighted;
  final bool hidePinyin;
  final bool hideMeaning;
  final VoidCallback? onAudio;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: highlighted
          ? LessonsStyles.wsCardHighlightDecoration
          : LessonsStyles.wsCardDecoration,
      padding: LessonsStyles.wsCardPadding,
      child: Row(
        children: [
          if (onAudio != null) ...[
            SizedBox(
              width: LessonsStyles.wsAudioSize,
              height: LessonsStyles.wsAudioSize,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  padding: EdgeInsets.zero,
                  backgroundColor: BrandColors.navTeal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: onAudio,
                child: const Icon(Icons.volume_up, size: 18),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: InkWell(
              onTap: onOpen,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 44),
                child: Row(
                  children: [
                    SizedBox(
                      width: 18,
                      child: Text('$number', style: LessonsStyles.wsNumStyle),
                    ),
                    const SizedBox(width: 12),
                    Text(row.cn, style: LessonsStyles.wsHanziStyle),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Opacity(
                            opacity: hidePinyin ? 0 : 1,
                            child: Text(
                              row.pinyin,
                              style: LessonsStyles.wsPinyinStyle,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Opacity(
                            opacity: hideMeaning ? 0 : 1,
                            child: Text(
                              learnerMeaning(
                                context,
                                row.meaningVn,
                                row.meaningEn,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: LessonsStyles.wsMeaningStyle,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      size: 18,
                      color: BrandColors.studyMuted,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailSheet extends StatefulWidget {
  const _DetailSheet({required this.row, required this.onListen});

  final LessonVocabRow row;
  final VoidCallback? onListen;

  @override
  State<_DetailSheet> createState() => _DetailSheetState();
}

class _DetailSheetState extends State<_DetailSheet> {
  bool _strokeOpen = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final row = widget.row;
    final isVi = Localizations.localeOf(context).languageCode == 'vi';
    // Only the UI-language meaning; blank when that language has none.
    final meaning = isVi ? row.meaningVn : row.meaningEn;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 28, 22, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              row.cn,
              textAlign: TextAlign.center,
              style: LessonsStyles.wsSheetHanziStyle,
            ),
            const SizedBox(height: 6),
            Text(
              row.pinyin,
              textAlign: TextAlign.center,
              style: LessonsStyles.wsSheetPinyinStyle,
            ),
            if (meaning.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                meaning,
                textAlign: TextAlign.center,
                style: LessonsStyles.wsSheetMeaningStyle,
              ),
            ],
            const SizedBox(height: 22),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              runSpacing: 10,
              children: [
                if (widget.onListen != null)
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: BrandColors.navTeal,
                      minimumSize: const Size(0, 44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: widget.onListen,
                    icon: const Icon(Icons.volume_up, size: 18),
                    label: Text(l10n.wordListen),
                  ),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: BrandColors.navTeal,
                    minimumSize: const Size(0, 44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => setState(() => _strokeOpen = !_strokeOpen),
                  icon: Icon(
                    _strokeOpen ? Icons.keyboard_arrow_up : Icons.edit_outlined,
                    size: 18,
                  ),
                  label: Text(l10n.wordStroke),
                ),
              ],
            ),
            if (_strokeOpen) StrokeOrderView(word: row.cn),
          ],
        ),
      ),
    );
  }
}
