/// Vocab trainer — the match activity (word/audio → meaning).
///
/// Ported from `MatchActivity.tsx`: two columns of the same words — left the
/// scored anchor (the character for `reading`, an audio button for `listen`),
/// right their meanings shuffled. Tap a left then a right item; a correct pair
/// locks green, a wrong pair flashes red and resets. The board must be fully
/// matched before Continue.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/audio/audio_player.dart';
import '../../../core/media/gcs.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../data/trainer_word.dart';
import '../data/vocab_activity.dart';
import '../styles/vocab_trainer_styles.dart';
import 'vocab_bottom_bar.dart';

class MatchActivity extends ConsumerStatefulWidget {
  const MatchActivity({
    super.key,
    required this.activity,
    required this.onRecord,
    required this.onAdvance,
    required this.onExit,
  });

  final VocabActivity activity;
  final VocabRecordFn onRecord;
  final VoidCallback onAdvance;
  final VoidCallback onExit;

  @override
  ConsumerState<MatchActivity> createState() => _MatchActivityState();
}

class _MatchActivityState extends ConsumerState<MatchActivity> {
  late final List<TrainerWord> _right;
  String? _selLeft;
  String? _selRight;
  final Set<String> _solved = {};
  final Set<String> _wrong = {};
  final Map<String, int> _wrongAttempts = {};

  List<TrainerWord> get _words => widget.activity.words;
  bool get _isListen => widget.activity.type == 'listen';
  String get _dbType => vocabActivityDb[widget.activity.type] ?? 'meaning';

  @override
  void initState() {
    super.initState();
    _right = [..._words]..shuffle();
  }

  bool get _allSolved => _solved.length == _words.length;

  void _playAudio(TrainerWord row) {
    if (row.audioKey.isEmpty) return;
    ref.read(audioPlayerProvider).playUrl(vocabAudioUrl(row.audioKey));
  }

  void _evaluate(String left, String right, bool isVi) {
    final row = _words.firstWhere((w) => w.word == left);
    if (left == right) {
      widget.onRecord(
        row,
        _dbType,
        row.meaning(isVi),
        true,
        _wrongAttempts[left] ?? 0,
      );
      setState(() {
        _solved.add(left);
        _selLeft = null;
        _selRight = null;
      });
    } else {
      _wrongAttempts[left] = (_wrongAttempts[left] ?? 0) + 1;
      setState(() {
        _wrong
          ..clear()
          ..addAll({'L:$left', 'R:$right'});
        _selLeft = null;
        _selRight = null;
      });
      Future.delayed(const Duration(milliseconds: 700), () {
        if (mounted) setState(() => _wrong.clear());
      });
    }
  }

  void _tapLeft(TrainerWord row, bool isVi) {
    final word = row.word;
    if (_solved.contains(word)) return;
    if (_isListen) _playAudio(row);
    setState(() => _selLeft = _selLeft == word ? null : word);
    if (_selLeft == word && _selRight != null) {
      _evaluate(word, _selRight!, isVi);
    }
  }

  void _tapRight(String word, bool isVi) {
    if (_solved.contains(word)) return;
    setState(() => _selRight = _selRight == word ? null : word);
    if (_selRight == word && _selLeft != null) _evaluate(_selLeft!, word, isVi);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isVi = Localizations.localeOf(context).languageCode == 'vi';

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: VocabTrainerStyles.contentPadding,
            child: Container(
              decoration: VocabTrainerStyles.cardDecoration,
              padding: VocabTrainerStyles.cardPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    _isListen
                        ? l10n.vocabInstructionListen
                        : l10n.vocabInstructionMatch,
                    textAlign: TextAlign.center,
                    style: VocabTrainerStyles.instructionStyle,
                  ),
                  VocabTrainerStyles.instructionGap,
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            for (final row in _words) ...[
                              _MatchItem(
                                label: row.word,
                                audio: _isListen,
                                style: VocabTrainerStyles.matchLeftStyle,
                                solved: _solved.contains(row.word),
                                selected: _selLeft == row.word,
                                wrong: _wrong.contains('L:${row.word}'),
                                onTap: () => _tapLeft(row, isVi),
                              ),
                              VocabTrainerStyles.matchItemGap,
                            ],
                          ],
                        ),
                      ),
                      VocabTrainerStyles.matchColumnGap,
                      Expanded(
                        child: Column(
                          children: [
                            for (final row in _right) ...[
                              _MatchItem(
                                label: row.meaning(isVi),
                                style: VocabTrainerStyles.matchRightStyle,
                                solved: _solved.contains(row.word),
                                selected: _selRight == row.word,
                                wrong: _wrong.contains('R:${row.word}'),
                                onTap: () => _tapRight(row.word, isVi),
                              ),
                              VocabTrainerStyles.matchItemGap,
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        VocabBottomBar(
          exitLabel: l10n.milestoneQuit,
          onExit: widget.onExit,
          primaryLabel: l10n.milestoneContinue,
          onPrimary: _allSolved ? widget.onAdvance : null,
        ),
      ],
    );
  }
}

class _MatchItem extends StatelessWidget {
  const _MatchItem({
    required this.label,
    required this.style,
    required this.solved,
    required this.selected,
    required this.wrong,
    required this.onTap,
    this.audio = false,
  });

  final String label;
  final TextStyle style;
  final bool solved;
  final bool selected;
  final bool wrong;
  final VoidCallback onTap;

  /// A `listen` match: show a speaker icon instead of the (hidden) character.
  final bool audio;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: VocabTrainerStyles.matchItemRadius,
        onTap: solved ? null : onTap,
        child: Container(
          width: double.infinity,
          decoration: VocabTrainerStyles.matchItemDecoration(
            solved: solved,
            selected: selected,
            wrong: wrong,
          ),
          padding: VocabTrainerStyles.matchItemPadding,
          alignment: Alignment.center,
          child: audio
              ? Icon(
                  solved ? Icons.check_circle_outline : Icons.volume_up,
                  color: BrandColors.navTeal,
                )
              : Text(label, textAlign: TextAlign.center, style: style),
        ),
      ),
    );
  }
}
