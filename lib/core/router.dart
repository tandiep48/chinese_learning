/// Core — app navigation (go_router) and the auth redirect guard.
///
/// This is the composition root: the one place allowed to wire modules
/// together, so it imports each feature's entry screen and the auth module's
/// status provider. Unauthenticated users are redirected to `/login`;
/// authenticated users are bounced off `/login` back home.
///
/// Routes: `/login`, `/` (home), `/books`, `/books/:code`,
/// `/lesson/:passageId`. The guard is live but currently reads the Phase 1
/// auth stub; Phase 3 swaps in the real auth notifier (and a
/// `refreshListenable`) without changing these routes.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/providers/auth_provider.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/lessons/screens/book_detail_screen.dart';
import '../features/lessons/screens/books_screen.dart';
import '../features/lessons/screens/lesson_study_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
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
