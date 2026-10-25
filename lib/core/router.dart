/// Core — app navigation (go_router) and the auth redirect guard.
///
/// This is the composition root: the one place allowed to wire modules
/// together, so it imports each feature's entry screen and the auth module's
/// status provider. Unauthenticated users are redirected to `/login`;
/// authenticated users are bounced off `/login` back home.
///
/// Routes: `/login`, `/` (home), `/books`, `/books/:code`,
/// `/lesson/:passageId`. The guard reads [authStatusProvider] and re-runs
/// whenever it changes (via a [refreshListenable]); while the launch-time auth
/// check is pending the status is `unknown` and no redirect happens.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/providers/auth_provider.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/lessons/screens/book_detail_screen.dart';
import '../features/lessons/screens/books_screen.dart';
import '../features/lessons/screens/lesson_study_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  // Bridge Riverpod auth-status changes to go_router's redirect re-evaluation
  // without rebuilding the router (which would drop navigation state).
  final refresh = ValueNotifier<int>(0);
  ref.onDispose(refresh.dispose);
  ref.listen<AuthStatus>(authStatusProvider, (_, _) => refresh.value++);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: refresh,
    redirect: (context, state) {
      final status = ref.read(authStatusProvider);
      final goingToLogin = state.matchedLocation == '/login';

      // While the launch-time auth check is pending (Phase 3), don't redirect.
      if (status == AuthStatus.unknown) return null;

      if (status == AuthStatus.unauthenticated) {
        return goingToLogin ? null : '/login';
      }
      // Authenticated: keep them out of the login screen.
      return goingToLogin ? '/' : null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/books',
        builder: (context, state) => const BooksScreen(),
      ),
      GoRoute(
        path: '/books/:code',
        builder: (context, state) =>
            BookDetailScreen(code: state.pathParameters['code']!),
      ),
      GoRoute(
        path: '/lesson/:passageId',
        builder: (context, state) =>
            LessonStudyScreen(passageId: state.pathParameters['passageId']!),
      ),
    ],
  );
});
