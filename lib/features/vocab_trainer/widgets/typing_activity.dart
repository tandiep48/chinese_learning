/// Vocab trainer — the typing activity (type each word).
///
/// Ported from `TypingActivity.tsx` (solo mode): each word shows its character
/// and the learner types it back; Check scores the whole group (a fully-correct
/// group also scores automatically) and reveals pinyin + meaning per word, then
/// Continue advances. Audio reveal is deferred (Slice R0).
library;

import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../data/trainer_word.dart';
import '../data/vocab_activity.dart';
import '../styles/vocab_trainer_styles.dart';
import 'vocab_bottom_bar.dart';

class TypingActivity extends StatefulWidget {
  const TypingActivity({
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
  State<TypingActivity> createState() => _TypingActivityState();
}

enum _Status { none, correct, incorrect }

class _TypingActivityState extends State<TypingActivity> {
  late final List<TextEditingController> _controllers;
  late List<_Status> _status;
  bool _checked = false;

  List<TrainerWord> get _words => widget.activity.words;

  @override
  void initState() {
    super.initState();
    _controllers = [for (final _ in _words) TextEditingController()];
    _status = [for (final _ in _words) _Status.none];
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _score() {
    if (_checked) return;
    for (var i = 0; i < _words.length; i++) {
      final row = _words[i];
      final answer = _controllers[i].text.trim();
      final correct = answer == row.word;
      widget.onRecord(row, 'typing', answer, correct, 0);
      _status[i] = correct ? _Status.correct : _Status.incorrect;
    }
    setState(() => _checked = true);
  }

  void _onChanged() {
    if (_checked) return;
    final allCorrect =
        _words.asMap().entries.every((e) => _controllers[e.key].text.trim() == e.value.word);
    if (allCorrect) {
      _score();
    } else {
      setState(() {});
    }
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
                  Text(l10n.vocabInstructionTyping,
                      textAlign: TextAlign.center,
                      style: VocabTrainerStyles.instructionStyle),
                  VocabTrainerStyles.instructionGap,
                  for (var i = 0; i < _words.length; i++) ...[
                    if (i > 0) VocabTrainerStyles.rowGap,
                    _TypingRow(
                      row: _words[i],
                      controller: _controllers[i],
                      status: _status[i],
                      checked: _checked,
                      isVi: isVi,
                      onChanged: _onChanged,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        VocabBottomBar(
          exitLabel: l10n.milestoneQuit,
          onExit: widget.onExit,
          primaryLabel: _checked ? l10n.milestoneContinue : l10n.trainerCheck,
          onPrimary: _checked ? widget.onAdvance : _score,
        ),
      ],
    );
  }
}

class _TypingRow extends StatelessWidget {
  const _TypingRow({
    required this.row,
    required this.controller,
    required this.status,
    required this.checked,
    required this.isVi,
    required this.onChanged,
  });

  final TrainerWord row;
  final TextEditingController controller;
  final _Status status;
  final bool checked;
  final bool isVi;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(row.word,
            textAlign: TextAlign.center, style: VocabTrainerStyles.promptStyle),
        VocabTrainerStyles.promptInputGap,
        TextField(
          controller: controller,
          enabled: !checked,
          textAlign: TextAlign.center,
          style: VocabTrainerStyles.inputStyle,
          decoration: VocabTrainerStyles.inputDecoration(),
          onChanged: (_) => onChanged(),
        ),
        if (status != _Status.none) ...[
          VocabTrainerStyles.resultGap,
          Text(
            '${status == _Status.correct ? '✓' : '✕'} ${row.pinyin} · ${row.meaning(isVi)}',
            textAlign: TextAlign.center,
            style: status == _Status.correct
                ? VocabTrainerStyles.resultOkStyle
                : VocabTrainerStyles.resultBadStyle,
          ),
        ],
      ],
    );
  }
}
