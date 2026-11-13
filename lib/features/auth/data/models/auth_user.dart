/// Auth module — the logged-in learner.
///
/// Ported from `yi-chinese-manage/lib/types/user.ts` (`AuthUser`); returned
/// under the `{success, data: { user }}` envelope by `/api/auth/token` and
/// `/api/auth/me`. `fromJson` validates every field (plan rule 6).
library;

import '../../../../core/api/validators.dart';

class AuthUser {
  const AuthUser({
    required this.id,
    required this.username,
    required this.email,
    this.level,
    this.avatarPath,
    this.avatarUrl,
    this.hanziFont,
    this.hanziScript,
    this.uiLanguage,
  });

  final int id;
  final String username;
  final String email;
  final int? level;
  final String? avatarPath;
  final String? avatarUrl;
  final String? hanziFont;
  final String? hanziScript;
  final String? uiLanguage;

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: requireInt(json, 'id'),
      username: requireString(json, 'username'),
      email: requireString(json, 'email'),
      level: optInt(json, 'level'),
      avatarPath: optString(json, 'avatar_path'),
      avatarUrl: optString(json, 'avatar_url'),
      hanziFont: optString(json, 'hanzi_font'),
      hanziScript: optString(json, 'hanzi_script'),
      uiLanguage: optString(json, 'ui_language'),
    );
  }

  /// Returns a copy with the given display preferences overridden (used when a
  /// settings change is saved, so the in-memory user stays in sync).
  AuthUser copyWith({
    String? hanziFont,
    String? hanziScript,
    String? uiLanguage,
  }) {
    return AuthUser(
      id: id,
      username: username,
      email: email,
      level: level,
      avatarPath: avatarPath,
      avatarUrl: avatarUrl,
      hanziFont: hanziFont ?? this.hanziFont,
      hanziScript: hanziScript ?? this.hanziScript,
      uiLanguage: uiLanguage ?? this.uiLanguage,
    );
  }
}
