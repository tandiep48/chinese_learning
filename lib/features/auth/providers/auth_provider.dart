/// Auth module — authentication state for the learner app.
///
/// Ported from `yi-chinese-manage/components/auth/AuthProvider.tsx`: its
/// mount-time `/api/auth/me` check becomes [AuthNotifier.build], which first
/// restores the persisted token. A 401 there just means "signed out", not an
/// error to surface (same as the web's mount check).
///
/// [authStatusProvider] is the synchronous view the router's redirect guard
/// reads; while the launch check is in flight the status is [AuthStatus.unknown]
/// so the guard holds its position instead of bouncing to login.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_exception.dart';
import '../data/auth_repository.dart';
import '../data/models/auth_user.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  const AuthState({required this.status, this.user});

  final AuthStatus status;
  final AuthUser? user;

  static const AuthState signedOut = AuthState(status: AuthStatus.unauthenticated);
}

final authNotifierProvider =
    AsyncNotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

/// Synchronous status for the router guard: `unknown` while the launch check
/// is still loading (or errored), otherwise the resolved status.
final authStatusProvider = Provider<AuthStatus>((ref) {
  return ref.watch(authNotifierProvider).maybeWhen(
        data: (state) => state.status,
        orElse: () => AuthStatus.unknown,
      );
});

class AuthNotifier extends AsyncNotifier<AuthState> {
  AuthRepository get _repo => ref.read(authRepositoryProvider);

  @override
  Future<AuthState> build() async {
    final token = await _repo.readStoredToken();
    if (token == null || token.isEmpty) return AuthState.signedOut;

    // Make the restored token available to the API client, then verify it.
    ref.read(bearerTokenProvider.notifier).set(token);
    try {
      final user = await _repo.fetchCurrentUser();
      return AuthState(status: AuthStatus.authenticated, user: user);
    } on ApiException {
      // Expired/invalid token or offline → treat as signed out.
      ref.read(bearerTokenProvider.notifier).set(null);
      return AuthState.signedOut;
    }
  }

  /// Sign in. Throws [ApiException] on bad credentials so the login form can
  /// show the message; global auth state is only moved to authenticated on
  /// success (it is never parked in an error state).
  Future<void> login(String username, String password) async {
    final result = await _repo.login(username, password);
    ref.read(bearerTokenProvider.notifier).set(result.token);
    state = AsyncData(AuthState(status: AuthStatus.authenticated, user: result.user));
  }

  /// Sign out, clearing the token locally and the status to unauthenticated.
  Future<void> logout() async {
    await _repo.logout();
    ref.read(bearerTokenProvider.notifier).set(null);
    state = const AsyncData(AuthState.signedOut);
  }
}
