/// Lessons module — the typing flash-card learner shared by milestone steps 2
/// (vocab) and 5 (lesson lines).
///
/// Ported from `FlashcardView.tsx` and `LessonCardStudy.tsx` + `flashcards.css`:
/// one card at a time with a counter, a thin progress bar, the hanzi (coloured per
/// character as you type), pinyin and meaning that start hidden, a typing
/// self-check, and the `CardShortcutLegend` button bar (Previous / Next / Audio +
/// reveal / Show-hide, plus Shuffle and Stroke order for vocab). The card's audio
/// plays when it comes up and when the typed text matches. The last card locks
/// (the milestone's Next advances the step).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/audio/audio_player.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../data/typing_glow.dart';
import '../styles/lessons_styles.dart';
import 'stroke_order_view.dart';

class StudyCardItem {
  const StudyCardItem({
    required this.text,
    required this.pinyin,
    required this.meaning,
    this.audioUrl,
  });

  final String text;
  final String pinyin;
  final String meaning;
  final String? audioUrl;
}

final RegExp _hanzi = RegExp(r'[一-鿿]');

class TypingCardStudy extends ConsumerStatefulWidget {
  const TypingCardStudy({
    super.key,
    required this.items,
    required this.placeholder,
    this.isSentence = false,
  });

  final List<StudyCardItem> items;
  final String placeholder;

  /// Lesson lines: wider card, smaller hanzi, no Shuffle / Stroke order.
  final bool isSentence;

  @override
  ConsumerState<TypingCardStudy> createState() => _TypingCardStudyState();
}

class _TypingCardStudyState extends ConsumerState<TypingCardStudy> {
  late List<StudyCardItem> _order = [...widget.items];
  final TextEditingController _typing = TextEditingController();
  int _index = 0;
  bool _revealed = false;
  bool _success = false;

  StudyCardItem get _item => _order[_index];

  @override
  void initState() {
    super.initState();
    _typing.addListener(_onTyping);
    WidgetsBinding.instance.addPostFrameCallback((_) => _playAudio());
  }

  @override
  void dispose() {
    _typing.dispose();
    ref.read(audioPlayerProvider).stop();
    super.dispose();
  }

  void _playAudio() {
    final url = _item.audioUrl;
    if (!mounted || url == null || url.isEmpty) return;
    ref.read(audioPlayerProvider).playUrl(url);
  }

  void _onTyping() {
    final matches = _typing.text.trim() == _item.text;
    if (matches && !_success) _playAudio();
    setState(() => _success = matches);
  }

  void _goTo(int index) {
    if (index < 0 || index >= _order.length || index == _index) return;
    _typing.removeListener(_onTyping);
    _typing.clear();
    _typing.addListener(_onTyping);
    setState(() {
      _index = index;
      _revealed = false;
      _success = false;
    });
    _playAudio();
  }

  void _shuffle() {
    if (_order.length <= 1) return;
    _typing.removeListener(_onTyping);
    _typing.clear();
    _typing.addListener(_onTyping);
    setState(() {
      _order = [..._order]..shuffle();
      _index = 0;
      _revealed = false;
      _success = false;
    });
    _playAudio();
  }

  void _openStroke() {
    final item = _item;
    if (!_hanzi.hasMatch(item.text)) return;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: BrandColors.card,
      shape: LessonsStyles.wordPopupShape,
      builder: (_) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(item.text, style: LessonsStyles.wsSheetHanziStyle),
              if (item.pinyin.isNotEmpty)
                Text(item.pinyin, style: LessonsStyles.wsSheetPinyinStyle),
              StrokeOrderView(word: item.text),
            ],
          ),
        ),
      ),
    );
  }

  Widget _hanziText(double width) {
    final item = _item;
    final base = widget.isSentence
        ? TextStyle(
            fontSize: (width * 0.04).clamp(24.0, 38.0),
            fontWeight: FontWeight.w700,
            height: 1.3,
            color: BrandColors.darkText,
          )
        : LessonsStyles.vlHanziStyle(width);
    if (_typing.text.isEmpty) {
      return Text(item.text, textAlign: TextAlign.center, style: base);
    }
    final target = item.text.runes.map(String.fromCharCode).toList();
    final states = typingGlow(target, _typing.text);
    return Text.rich(
      TextSpan(
        children: [
          for (var i = 0; i < target.length; i++)
            TextSpan(
              text: target[i],
              style: switch (states[i]) {
                GlowState.correct => base.copyWith(color: BrandColors.navTeal),
                GlowState.wrong => base.copyWith(color: LessonsStyles.vlWrongChar),
                GlowState.none => base,
              },
            ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final item = _item;
    final total = _order.length;
    final maxWidth = widget.isSentence ? 900.0 : LessonsStyles.cardMaxWidth;
    final canStroke = !widget.isSentence && _hanzi.hasMatch(item.text);

    return SingleChildScrollView(
      padding: LessonsStyles.studyPagePadding,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${_index + 1} / $total',
                  style: LessonsStyles.vlCounterStyle,
                ),
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: (_index + 1) / total,
                  minHeight: LessonsStyles.vlProgressHeight,
                  backgroundColor: LessonsStyles.vlProgressTrack,
                  valueColor: const AlwaysStoppedAnimation(BrandColors.navTeal),
                ),
              ),
              const SizedBox(height: 28),
              Container(
                decoration: LessonsStyles.vlCardDecoration,
                padding: LessonsStyles.vlCardPadding(width),
                child: Column(
                  children: [
                    _hanziText(width),
                    const SizedBox(height: 10),
                    ConstrainedBox(
                      constraints: const BoxConstraints(
                        minHeight: LessonsStyles.vlPinyinMinHeight,
                      ),
                      child: Text(
                        _revealed ? item.pinyin : '',
                        textAlign: TextAlign.center,
                        style: LessonsStyles.vlPinyinStyle,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ConstrainedBox(
                      constraints: const BoxConstraints(
                        minHeight: LessonsStyles.vlMeaningMinHeight,
                      ),
                      child: Text(
                        _revealed ? item.meaning : '',
                        textAlign: TextAlign.center,
                        style: LessonsStyles.vlMeaningStyle,
                      ),
                    ),
                    const SizedBox(height: 28),
                    TextField(
                      controller: _typing,
                      textAlign: TextAlign.center,
                      minLines: 1,
                      maxLines: widget.isSentence ? null : 1,
                      textInputAction: TextInputAction.done,
                      autocorrect: false,
                      style: _success
                          ? LessonsStyles.vlInputStyle.copyWith(
                              color: LessonsStyles.vlInputSuccessText,
                            )
                          : LessonsStyles.vlInputStyle,
                      decoration: LessonsStyles.vlInputDecoration(
                        widget.placeholder,
                        success: _success,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  _LegendButton(
                    keyLabel: 'A',
                    label: l10n.cardPrev,
                    onTap: () => _goTo(_index - 1),
                  ),
                  _LegendButton(
                    keyLabel: 'D',
                    label: l10n.cardNext,
                    onTap: () => _goTo(_index + 1),
                  ),
                  _LegendButton(
                    keyLabel: 'W',
                    label: l10n.cardAudioReveal,
                    onTap: () {
                      setState(() => _revealed = true);
                      _playAudio();
                    },
                  ),
                  _LegendButton(
                    keyLabel: 'S',
                    label: l10n.cardReveal,
                    onTap: () => setState(() => _revealed = !_revealed),
                  ),
                  if (!widget.isSentence)
                    _LegendButton(
                      keyLabel: 'Space',
                      label: l10n.cardShuffle,
                      onTap: _shuffle,
                    ),
                  if (canStroke)
                    _LegendButton(
                      keyLabel: 'Q',
                      label: l10n.cardStroke,
                      onTap: _openStroke,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// `.card-shortcut-item`: a tappable pill with a keyboard-key hint.
class _LegendButton extends StatelessWidget {
  const _LegendButton({
    required this.keyLabel,
    required this.label,
    required this.onTap,
  });

  final String keyLabel;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: LessonsStyles.shortcutItemDecoration,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 40),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  constraints: const BoxConstraints(minWidth: 26),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2,
                  ),
                  decoration: LessonsStyles.shortcutKeyDecoration,
                  alignment: Alignment.center,
                  child: Text(keyLabel, style: LessonsStyles.shortcutKeyStyle),
                ),
                const SizedBox(width: 6),
                Text(label, style: LessonsStyles.shortcutLabelStyle),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
