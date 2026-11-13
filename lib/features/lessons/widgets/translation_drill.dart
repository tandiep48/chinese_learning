/// Lessons module — the lesson-translation flashcard drill.
///
/// Ported from `translation/TranslationPanel.tsx` (card half of the legacy
/// `translation.js`): one sentence at a time — its meaning in the UI language, an
/// input for the Chinese that highlights green on a match, a reveal toggle, and
/// Prev / Shuffle / Next with a progress bar.
library;

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../data/models/translation_row.dart';
import '../styles/lessons_styles.dart';

class TranslationDrill extends StatefulWidget {
  const TranslationDrill({super.key, required this.rows});

  final List<TranslationRow> rows;

  @override
  State<TranslationDrill> createState() => _TranslationDrillState();
}

class _TranslationDrillState extends State<TranslationDrill> {
  late List<TranslationRow> _deck = [...widget.rows];
  final TextEditingController _controller = TextEditingController();
  int _index = 0;
  bool _revealed = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goTo(int target) {
    setState(() {
      _index = target;
      _revealed = false;
      _controller.clear();
    });
  }

  void _reshuffle() {
    if (_deck.length <= 1) return;
    setState(() => _deck = [..._deck]..shuffle());
    _goTo(0);
  }

  String _meaning(TranslationRow row, bool isVi) {
    String pick(String? a, String? b) {
      if (a != null && a.isNotEmpty) return a;
      if (b != null && b.isNotEmpty) return b;
      return '';
    }

    return isVi ? pick(row.vn, row.en) : pick(row.en, row.vn);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isVi = Localizations.localeOf(context).languageCode == 'vi';
    final total = _deck.length;
    final row = _deck[_index];
    final matched = _controller.text.trim() == row.cn.trim();

    return Padding(
      padding: LessonsStyles.translationPagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${_index + 1} / $total',
              style: LessonsStyles.translationCounter,
            ),
          ),
          LessonsStyles.gap8,
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: total == 0 ? 0 : (_index + 1) / total,
              minHeight: LessonsStyles.translationProgressHeight,
              backgroundColor: LessonsStyles.translationProgressTrack,
              valueColor: const AlwaysStoppedAnimation(BrandColors.navTeal),
            ),
          ),
          LessonsStyles.gap16,
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(
              minHeight: LessonsStyles.translationCardMinHeight,
            ),
            decoration: LessonsStyles.translationCardDecoration,
            padding: LessonsStyles.translationCardPadding(
              MediaQuery.sizeOf(context).width,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _meaning(row, isVi),
                  textAlign: TextAlign.center,
                  style: LessonsStyles.translationMeaning,
                ),
                LessonsStyles.gap16,
                TextField(
                  controller: _controller,
                  textAlign: TextAlign.center,
                  autocorrect: false,
                  enableSuggestions: false,
                  style: LessonsStyles.translationInputText,
                  decoration: LessonsStyles.translationInputDecoration(
                    l10n.translationInputPlaceholder,
                    matched,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                if (_revealed) ...[
                  LessonsStyles.gap16,
                  Text(
                    row.cn,
                    textAlign: TextAlign.center,
                    style: LessonsStyles.translationAnswer,
                  ),
                ],
                LessonsStyles.gap16,
                Center(
                  child: FilledButton(
                    style: LessonsStyles.translationRevealButton,
                    onPressed: () => setState(() => _revealed = !_revealed),
                    child: Text(
                      _revealed ? l10n.translationHide : l10n.translationReveal,
                    ),
                  ),
                ),
              ],
            ),
          ),
          LessonsStyles.gap16,
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: LessonsStyles.translationNavButton,
                  onPressed: _index > 0 ? () => _goTo(_index - 1) : null,
                  child: Text('← ${l10n.translationPrev}'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  style: LessonsStyles.translationNavButton,
                  onPressed: total > 1 ? _reshuffle : null,
                  icon: const Icon(Icons.shuffle, size: 16),
                  label: Text(l10n.translationShuffle),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton(
                  style: LessonsStyles.translationPrimaryNav,
                  onPressed: _index < total - 1
                      ? () => _goTo(_index + 1)
                      : null,
                  child: Text('${l10n.translationNext} →'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
