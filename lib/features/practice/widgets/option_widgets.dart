/// Practice module — the shared answer-picker building blocks.
///
/// Ported from `question-types/{MCOptions,TrueFalse,KeyButtons,ImageOptions}.tsx`.
/// Each is stateless and derives its look from [GroupUIState] + the engine's
/// answer comparison; a "check" simply rebuilds with feedback highlights. Han
/// text is rendered plainly (the CJK font swap stays deferred).
library;

import 'package:flutter/material.dart';

import '../../../core/media/gcs.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../data/group_state.dart';
import '../data/models/practice_question.dart';
import '../data/practice_engine.dart';
import '../styles/practice_styles.dart';
import 'group_props.dart';

/// Lettered multiple-choice list. After a check it marks the correct option and,
/// if the learner picked a different one, their wrong pick.
class MCOptions extends StatelessWidget {
  const MCOptions({
    super.key,
    required this.q,
    required this.blockId,
    required this.state,
    required this.onSelect,
  });

  final PracticeQuestion q;
  final String blockId;
  final GroupUIState state;
  final SelectCb onSelect;

  @override
  Widget build(BuildContext context) {
    final chosen = normalizeAnswer(state.userAnswers[blockId]);
    final correct = normalizeAnswer(q.answer);
    final entries = q.options.entries.toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < entries.length; i++) ...[
          if (i > 0) PracticeStyles.optionGap,
          _TapCard(
            enabled: !state.checked,
            decoration: PracticeStyles.optionDecoration(
              selected: state.userAnswers[blockId] == entries[i].key,
              checked: state.checked,
              correct:
                  state.checked && normalizeAnswer(entries[i].key) == correct,
              wrong:
                  state.checked &&
                  normalizeAnswer(entries[i].key) != correct &&
                  normalizeAnswer(entries[i].key) == chosen,
            ),
            onTap: () => onSelect(blockId, entries[i].key),
            child: Row(
              children: [
                Text(entries[i].key, style: PracticeStyles.optionKeyStyle),
                PracticeStyles.optionKeyGap,
                Expanded(
                  child: Text(
                    entries[i].value.toString(),
                    style: PracticeStyles.optionTextStyle,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// Type 1. The options map carries booleans (or their string spellings) for the
/// true/false pair; anything else falls back to "key: value".
class TrueFalse extends StatelessWidget {
  const TrueFalse({
    super.key,
    required this.q,
    required this.blockId,
    required this.state,
    required this.onSelect,
  });

  final PracticeQuestion q;
  final String blockId;
  final GroupUIState state;
  final SelectCb onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final chosen = normalizeAnswer(state.userAnswers[blockId]);
    final correct = normalizeAnswer(q.answer);
    final entries = q.options.entries.toList();
    return Row(
      children: [
        for (var i = 0; i < entries.length; i++) ...[
          if (i > 0) PracticeStyles.wGap8,
          Expanded(
            child: FilledButton(
              style: PracticeStyles.tfButtonStyle(
                selected: state.userAnswers[blockId] == entries[i].key,
                checked: state.checked,
                correct:
                    state.checked && normalizeAnswer(entries[i].key) == correct,
                wrong:
                    state.checked &&
                    normalizeAnswer(entries[i].key) != correct &&
                    normalizeAnswer(entries[i].key) == chosen,
              ),
              onPressed: state.checked
                  ? null
                  : () => onSelect(blockId, entries[i].key),
              child: Text(_label(l10n, entries[i].key, entries[i].value)),
            ),
          ),
        ],
      ],
    );
  }

  String _label(AppLocalizations l10n, String key, dynamic val) {
    if (val == true || val == 'True') return l10n.practiceTrueLabel;
    if (val == false || val == 'False') return l10n.practiceFalseLabel;
    return '$key: $val';
  }
}

/// Per-row option picker for the t5 grouped layouts. Every row draws from one
/// shared pool, so a key already spent elsewhere is disabled, not hidden.
class KeyButtons extends StatelessWidget {
  const KeyButtons({
    super.key,
    required this.q,
    required this.blockId,
    required this.optKeys,
    required this.state,
    required this.onSelectKey,
  });

  final PracticeQuestion q;
  final String blockId;
  final List<String> optKeys;
  final GroupUIState state;
  final SelectCb onSelectKey;

  @override
  Widget build(BuildContext context) {
    final usedKeys = state.userAnswers.values.toSet();
    final chosen = normalizeAnswer(state.userAnswers[blockId]);
    final correct = normalizeAnswer(q.answer);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final key in optKeys)
          Builder(
            builder: (_) {
              final isSelected = state.userAnswers[blockId] == key;
              final usedElsewhere = usedKeys.contains(key) && !isSelected;
              return FilledButton(
                style: PracticeStyles.keyButtonStyle(
                  selected: isSelected,
                  usedElsewhere: usedElsewhere,
                  checked: state.checked,
                  correct: state.checked && normalizeAnswer(key) == correct,
                  wrong: state.checked && isSelected && chosen != correct,
                ),
                onPressed: state.checked || usedElsewhere
                    ? null
                    : () => onSelectKey(blockId, key),
                child: Text(key),
              );
            },
          ),
      ],
    );
  }
}

/// Types 3 and 5: a grid of picture choices.
class ImageOptions extends StatelessWidget {
  const ImageOptions({
    super.key,
    required this.q,
    required this.blockId,
    required this.state,
    required this.onSelect,
    required this.category,
  });

  final PracticeQuestion q;
  final String blockId;
  final GroupUIState state;
  final SelectCb onSelect;
  final PracticeCategory category;

  @override
  Widget build(BuildContext context) {
    final chosen = normalizeAnswer(state.userAnswers[blockId]);
    final correct = normalizeAnswer(q.answer);
    final entries = q.options.entries.toList();
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        for (final e in entries)
          _TapCard(
            width: 132,
            enabled: !state.checked,
            decoration: PracticeStyles.imageTileDecoration(
              selected: state.userAnswers[blockId] == e.key,
              checked: state.checked,
              correct: state.checked && normalizeAnswer(e.key) == correct,
              wrong:
                  state.checked &&
                  normalizeAnswer(e.key) != correct &&
                  normalizeAnswer(e.key) == chosen,
            ),
            onTap: () => onSelect(blockId, e.key),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Image.network(
                      practiceImageUrl(
                        q.level,
                        e.value.toString(),
                        category.wire,
                      ),
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const ColoredBox(
                        color: BrandColors.coverPlaceholderBg,
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          color: BrandColors.mutedText,
                        ),
                      ),
                    ),
                  ),
                ),
                PracticeStyles.gap8,
                Text(e.key, style: PracticeStyles.imageLabelStyle),
              ],
            ),
          ),
      ],
    );
  }
}

/// A rounded, bordered tappable surface used by the option/image pickers.
class _TapCard extends StatelessWidget {
  const _TapCard({
    required this.decoration,
    required this.onTap,
    required this.child,
    this.enabled = true,
    this.width,
  });

  final BoxDecoration decoration;
  final VoidCallback onTap;
  final Widget child;
  final bool enabled;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: enabled ? onTap : null,
        child: Container(
          width: width,
          decoration: decoration,
          padding: PracticeStyles.optionPadding,
          child: child,
        ),
      ),
    );
  }
}
