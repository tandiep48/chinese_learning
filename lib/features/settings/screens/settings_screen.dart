/// Settings module — the learner display-preferences screen.
///
/// Ported from `yi-chinese-manage/components/layout/LearnerSettingsModal.tsx`
/// (the "panel" variant of `LanguageSwitcher` + `HanziSettingsControl`): a UI
/// language switch (applied at runtime) plus the per-user hanzi script and font.
/// Reached from the nav drawer's Settings item; pushed over the shell with its
/// own app bar. Language changes drive `MaterialApp.locale` via
/// [localeControllerProvider]; script/font are persisted to the account (their
/// runtime glyph rendering is deferred — see [settingsHanziNote]).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/hanzi_options.dart';
import '../data/settings_repository.dart';
import '../providers/settings_providers.dart';
import '../styles/settings_styles.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = ref.watch(localeControllerProvider);
    final user = ref.watch(authNotifierProvider).asData?.value.user;

    final script = normalizeHanziScript(user?.hanziScript);
    final font = normalizeHanziFont(user?.hanziFont);

    Future<void> save(Future<void> Function() action) async {
      try {
        await action();
      } catch (_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.settingsSaveError)),
          );
        }
      }
    }

    final repo = ref.read(settingsRepositoryProvider);
    final auth = ref.read(authNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: BrandColors.card,
      appBar: AppBar(title: Text(l10n.navSettings)),
      body: SafeArea(
        child: ListView(
          padding: SettingsStyles.pagePadding,
          children: [
            _Field(
              label: l10n.settingsLanguage,
              child: DropdownButtonFormField<String>(
                initialValue: supportedLanguageCodes.contains(locale.languageCode)
                    ? locale.languageCode
                    : defaultLocale.languageCode,
                decoration: SettingsStyles.fieldDecoration(),
                style: SettingsStyles.valueStyle,
                items: [
                  DropdownMenuItem(value: 'vi', child: Text(l10n.settingsLangVi)),
                  DropdownMenuItem(value: 'en', child: Text(l10n.settingsLangEn)),
                ],
                onChanged: (code) {
                  if (code != null) {
                    save(() =>
                        ref.read(localeControllerProvider.notifier).setLanguage(code));
                  }
                },
              ),
            ),
            SettingsStyles.fieldGap,
            _Field(
              label: l10n.settingsScript,
              child: DropdownButtonFormField<String>(
                initialValue: script,
                decoration: SettingsStyles.fieldDecoration(),
                style: SettingsStyles.valueStyle,
                items: [
                  DropdownMenuItem(
                    value: 'simplified',
                    child: Text(l10n.settingsScriptSimplified),
                  ),
                  DropdownMenuItem(
                    value: 'traditional',
                    child: Text(l10n.settingsScriptTraditional),
                  ),
                ],
                onChanged: (value) {
                  if (value != null && value != script) {
                    save(() async {
                      await repo.saveHanziScript(value);
                      auth.updateUser(hanziScript: value);
                    });
                  }
                },
              ),
            ),
            SettingsStyles.fieldGap,
            _Field(
              label: l10n.settingsFont,
              child: DropdownButtonFormField<String>(
                initialValue: font,
                decoration: SettingsStyles.fieldDecoration(),
                style: SettingsStyles.valueStyle,
                items: [
                  for (final f in hanziFonts)
                    DropdownMenuItem(value: f, child: Text(f)),
                ],
                onChanged: (value) {
                  if (value != null && value != font) {
                    save(() async {
                      await repo.saveHanziFont(value);
                      auth.updateUser(hanziFont: value);
                    });
                  }
                },
              ),
            ),
            SettingsStyles.noteGap,
            Text(l10n.settingsHanziNote, style: SettingsStyles.noteStyle),
          ],
        ),
      ),
    );
  }
}

/// A stacked labeled field (the web settings panel's `<label>` block).
class _Field extends StatelessWidget {
  const _Field({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: SettingsStyles.labelStyle),
        SettingsStyles.labelGap,
        child,
      ],
    );
  }
}
