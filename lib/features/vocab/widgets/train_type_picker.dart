/// Vocab module — the "choose which skills to train" sheet.
///
/// Ported from `TrainTypePicker` (vocab engine). Multi-select, all skills checked
/// by default (= train all). Returns the chosen skill ids, or null if cancelled.
/// Only the two skills the Flutter vocab trainer supports are offered (typing,
/// reading); the audio-only "listen" skill is omitted until the trainer has audio.
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

Future<List<String>?> showTrainTypePicker(
  BuildContext context,
  AppLocalizations l10n,
) {
  final skills = [
    _Skill('typing', l10n.trainPickerSkillTyping),
    _Skill('reading', l10n.trainPickerSkillReading),
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
