/// Auth module — authentication data access.
///
/// Talks to the backend auth endpoints (all enveloped `{success, data}`):
///   • POST `/api/auth/token` → `{ token, user }` (mobile bearer login)
///   • GET  `/api/auth/me`     → the current user (launch-time session check)
///   • POST `/api/auth/logout` → best-effort server logout
/// The signed token is persisted with `flutter_secure_storage` so a returning
/// user stays logged in. Ported from the web's cookie-session auth in
/// `yi-chinese-manage/lib/api/auth.ts` (cookie → bearer token).
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/validators.dart';
import 'models/auth_user.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    ref.read(apiClientProvider),
    const FlutterSecureStorage(),
  );
});

class AuthRepository {
  AuthRepository(this._api, this._storage);

  final ApiClient _api;
  final FlutterSecureStorage _storage;

  static const String _tokenKey = 'auth_token';

  /// The persisted token from a previous session, or null.
  Future<String?> readStoredToken() => _storage.read(key: _tokenKey);

  /// Exchange credentials for a bearer token + the user; persists the token.
  Future<({String token, AuthUser user})> login(
    String username,
    String password,
  ) async {
    final data = await _api.postEnvelope(
      '/api/auth/token',
      body: {'username': username, 'password': password},
    );
    final map = asMap(data, what: 'token response');
    final token = requireString(map, 'token');
    final user = AuthUser.fromJson(asMap(map['user'], what: 'user'));
    await _storage.write(key: _tokenKey, value: token);
    return (token: token, user: user);
  }

  /// Create an account, then sign in for a bearer token. The register endpoint
  /// starts a cookie session (web parity) but returns no token, so the mobile
  /// client exchanges the fresh credentials for one via [login] — the single
  /// step the web gets from its cookie session.
  Future<({String token, AuthUser user})> register(
    String username,
    String email,
    String password,
  ) async {
    await _api.postEnvelope(
      '/api/auth/register',
      body: {'username': username, 'email': email, 'password': password},
    );
    return login(username, password);
  }

  /// The current user for the active token (throws [UnauthenticatedException]
  /// on 401). `/api/auth/me` returns the user directly as the envelope `data`.
  Future<AuthUser> fetchCurrentUser() async {
    final data = await _api.getEnvelope('/api/auth/me');
    return AuthUser.fromJson(asMap(data, what: 'user'));
  }

  /// Clear the session: best-effort server logout, then drop the local token.
  Future<void> logout() async {
    try {
      await _api.postEnvelope('/api/auth/logout');
    } catch (_) {
      // Signed-out/offline: the local token is cleared regardless.
    }
    await _storage.delete(key: _tokenKey);
  }
}
