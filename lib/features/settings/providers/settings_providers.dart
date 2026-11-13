/// Settings module — the app locale controller + hanzi-preference helpers.
///
/// [localeControllerProvider] is the source of truth for `MaterialApp.locale`.
/// It seeds from a local cache first (so a relaunch keeps the chosen language
/// before auth resolves), then from the signed-in user's `uiLanguage` unless the
/// device already has an explicit choice. Changing the language persists it
/// locally and — when signed in — to the server (`POST /api/user/ui-language`),
/// mirroring the web `LanguageSwitcher` + `saveUiLanguage`. Vietnamese is the
/// default (plan decision b).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_provider.dart';
import '../data/settings_repository.dart';

const Set<String> supportedLanguageCodes = {'vi', 'en'};
const Locale defaultLocale = Locale('vi');

Locale localeForCode(String code) =>
    supportedLanguageCodes.contains(code) ? Locale(code) : defaultLocale;

final localeControllerProvider = NotifierProvider<LocaleController, Locale>(
  LocaleController.new,
);

class LocaleController extends Notifier<Locale> {
  /// True once the language was set explicitly on this device (locally cached or
  /// chosen in Settings), so a later server value never overrides the choice.
  bool _deviceOverride = false;

  @override
  Locale build() {
    // Seed from the signed-in user's saved language when the auth check resolves,
    // unless this device already has an explicit choice.
    ref.listen(authNotifierProvider, (_, next) {
      if (_deviceOverride) return;
      final lang = next.asData?.value.user?.uiLanguage;
      if (lang != null && lang.isNotEmpty) state = localeForCode(lang);
    });
    _restoreLocal();
    return defaultLocale;
  }

  Future<void> _restoreLocal() async {
    final saved = await ref
        .read(settingsRepositoryProvider)
        .readStoredLanguage();
    if (saved != null && saved.isNotEmpty) {
      _deviceOverride = true;
      state = localeForCode(saved);
    }
  }

  /// Switch the UI language: apply immediately, cache locally, and (when signed
  /// in) persist to the account and patch the in-memory user. The server save is
  /// soft-fail — the local choice is already applied.
  Future<void> setLanguage(String code) async {
    _deviceOverride = true;
    state = localeForCode(code);
    final repo = ref.read(settingsRepositoryProvider);
    await repo.writeStoredLanguage(code);
    if (ref.read(authStatusProvider) == AuthStatus.authenticated) {
      await repo.saveUiLanguage(code);
      ref.read(authNotifierProvider.notifier).updateUser(uiLanguage: code);
    }
  }
}
