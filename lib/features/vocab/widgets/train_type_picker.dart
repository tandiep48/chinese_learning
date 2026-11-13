/// Vocab module — the "choose which skills to train" sheet.
///
/// Ported from `TrainTypePicker` (vocab engine). Multi-select, all skills checked
/// by default (= train all). Returns the chosen skill ids, or null if cancelled.
/// Offers the vocab engine's three skills — typing, listening (audio match) and
/// reading.
library;

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../styles/vocab_styles.dart';

class _Skill {
  const _Skill(this.id, this.label);
  final String id;
  final String label;
}

/// Which trainer's skills to offer.
enum TrainerEngine { vocab, lesson }

Future<List<String>?> showTrainTypePicker(
  BuildContext context,
  AppLocalizations l10n, {
  TrainerEngine engine = TrainerEngine.vocab,
}) {
  // Ids are exactly what each trainer expects (activity types / task `type`).
  final skills = engine == TrainerEngine.vocab
      ? [
          _Skill('typing', l10n.trainPickerSkillTyping),
          _Skill('listen', l10n.trainPickerSkillListening),
          _Skill('reading', l10n.trainPickerSkillReading),
        ]
      : [
          _Skill('listening', l10n.trainPickerSkillListening),
          _Skill('meaning', l10n.trainPickerSkillMeaning),
          _Skill('typing', l10n.trainPickerSkillTyping),
          _Skill('reorder', l10n.trainPickerSkillReorder),
        ];
  final checked = {for (final s in skills) s.id: true};
  String? error;

  return showModalBottomSheet<List<String>>(
    context: context,
    backgroundColor: BrandColors.card,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setSheet) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.trainPickerTitle, style: VocabStyles.label),
              const SizedBox(height: 4),
              Text(l10n.trainPickerSubtitle, style: VocabStyles.subtitle),
              VocabStyles.gap8,
              for (final s in skills)
                CheckboxListTile(
                  dense: true,
                  activeColor: BrandColors.navTeal,
                  controlAffinity: ListTileControlAffinity.leading,
                  value: checked[s.id],
                  title: Text(s.label, style: VocabStyles.meaning),
                  onChanged: (v) => setSheet(() {
                    checked[s.id] = v ?? false;
                    error = null;
                  }),
                ),
              if (error != null) ...[
                VocabStyles.gap8,
                Text(
                  error!,
                  style: const TextStyle(
                    color: BrandColors.dangerText,
                    fontSize: 13,
                  ),
                ),
              ],
              VocabStyles.gap12,
              FilledButton(
                style: VocabStyles.primaryButton,
                onPressed: () {
                  final chosen = [
                    for (final s in skills)
                      if (checked[s.id] == true) s.id,
                  ];
                  if (chosen.isEmpty) {
                    setSheet(() => error = l10n.trainPickerSelectOne);
                    return;
                  }
                  Navigator.of(ctx).pop(chosen);
                },
                child: Text(l10n.trainPickerStart),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
