/// Settings module — learner display-preference persistence.
///
/// Ported from `yi-chinese-manage/lib/api/learner/userSettings.ts`: the account's
/// UI language, hanzi script and hanzi font. All three are legacy raw-JSON POSTs
/// (`{ status, ... }` / `{ error }`), so they use the raw client path. The chosen
/// language is also cached locally (`flutter_secure_storage`, reusing the auth
/// dependency) so it survives a relaunch before the auth check resolves and for
/// signed-out users.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../core/api/api_client.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository(ref.read(apiClientProvider), const FlutterSecureStorage());
});

class SettingsRepository {
  SettingsRepository(this._api, this._storage);

  final ApiClient _api;
  final FlutterSecureStorage _storage;

  static const String _langKey = 'ui_language';

  /// The locally cached UI language, or null when none was saved on this device.
  Future<String?> readStoredLanguage() => _storage.read(key: _langKey);
  Future<void> writeStoredLanguage(String lang) =>
      _storage.write(key: _langKey, value: lang);

  Future<void> saveUiLanguage(String lang) =>
      _api.postRaw('/api/user/ui-language', body: {'ui_language': lang});

  Future<void> saveHanziScript(String script) =>
      _api.postRaw('/api/user/hanzi-script', body: {'hanzi_script': script});

  Future<void> saveHanziFont(String font) =>
      _api.postRaw('/api/user/hanzi-font', body: {'hanzi_font': font});
}
