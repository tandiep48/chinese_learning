/// Core — app navigation (go_router) and the auth redirect guard.
///
/// This is the composition root: the one place allowed to wire modules
/// together, so it imports each feature's entry screen and the auth module's
/// status provider. Unauthenticated users are redirected to `/login`;
/// authenticated users are bounced off `/login` back home.
///
/// Routes: `/login`, `/` (home), `/library` (HSK | Books hub), `/books`,
/// `/books/:code`, `/books/:code/:lesson`, `/hsk/:level`, `/hsk/:level/:lesson`, `/lesson/:passageId`, `/settings`. The guard
/// reads [authStatusProvider] and re-runs
/// whenever it changes (via a [refreshListenable]); while the launch-time auth
/// check is pending the status is `unknown` and no redirect happens.
///
/// The authed top-level destinations (the dashboard today; the Library in Slice
/// N2) are nested in a [ShellRoute] so [AppShell] gives them a persistent app
/// bar + navigation drawer. Deeper screens (`/books`, book detail, lesson
/// study) stay outside the shell and are pushed with their own app bars.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/providers/auth_provider.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/competition/screens/competition_page.dart';
import '../features/home/screens/home_screen.dart';
import '../features/lessons/screens/book_detail_screen.dart';
import '../features/lessons/screens/book_parts_screen.dart';
import '../features/lessons/screens/books_screen.dart';
import '../features/lessons/screens/grammar_screen.dart';
import '../features/lessons/screens/hsk_lessons_screen.dart';
import '../features/lessons/screens/hsk_parts_screen.dart';
import '../features/lessons/screens/library_screen.dart';
import '../features/lessons/screens/pinyin_guide_screen.dart';
import '../features/lessons/screens/translation_screen.dart';
import '../features/milestone/screens/milestone_screen.dart';
import '../features/practice/data/models/practice_question.dart';
import '../features/practice/screens/exam_lessons_screen.dart';
import '../features/practice/screens/practice_lessons_screen.dart';
import '../features/practice/screens/practice_runner_page.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/settings/screens/settings_screen.dart';
import '../features/shell/screens/app_shell.dart';
import '../features/vocab/screens/vocab_select_screen.dart';

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
      final location = state.matchedLocation;
      final onAuthScreen = location == '/login' || location == '/register';

      // While the launch-time auth check is pending (Phase 3), don't redirect.
      if (status == AuthStatus.unknown) return null;

      if (status == AuthStatus.unauthenticated) {
        return onAuthScreen ? null : '/login';
      }
      // Authenticated: keep them out of the login/register screens.
      return onAuthScreen ? '/' : null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
          GoRoute(
            path: '/library',
            builder: (context, state) => const LibraryScreen(),
          ),
        ],
      ),
      GoRoute(path: '/books', builder: (context, state) => const BooksScreen()),
      GoRoute(
        path: '/hsk/:level',
        builder: (context, state) =>
            HskLessonsScreen(levelKey: state.pathParameters['level']!),
      ),
      GoRoute(
        path: '/hsk/:level/:lesson',
        builder: (context, state) => HskPartsScreen(
          levelKey: state.pathParameters['level']!,
          lesson: state.pathParameters['lesson']!,
        ),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/books/:code',
        builder: (context, state) =>
            BookDetailScreen(code: state.pathParameters['code']!),
      ),
      GoRoute(
        path: '/books/:code/:lesson',
        builder: (context, state) => BookPartsScreen(
          code: state.pathParameters['code']!,
          lesson: state.pathParameters['lesson']!,
        ),
      ),
      GoRoute(
        path: '/lesson/:passageId',
        builder: (context, state) => MilestoneScreen(
          passageId: state.pathParameters['passageId']!,
          initialStep: int.tryParse(state.uri.queryParameters['step'] ?? ''),
        ),
      ),
      GoRoute(
        path: '/grammar/:passageId',
        builder: (context, state) =>
            GrammarScreen(passageId: state.pathParameters['passageId']!),
      ),
      GoRoute(
        path: '/translation/:passageId',
        builder: (context, state) =>
            TranslationScreen(passageId: state.pathParameters['passageId']!),
      ),
      GoRoute(
        path: '/exam/:level',
        builder: (context, state) =>
            ExamLessonsScreen(level: state.pathParameters['level']!),
      ),
      GoRoute(
        path: '/pinyin',
        builder: (context, state) => const PinyinGuideScreen(),
      ),
      GoRoute(
        path: '/competition',
        builder: (context, state) => const CompetitionPage(),
      ),
      GoRoute(
        path: '/vocab',
        builder: (context, state) => const VocabSelectScreen(),
      ),
      // Practice lessons list for an HSK level (Library "Practice" tab → here →
      // runner). One path segment, so it doesn't collide with the two-segment
      // runner route below.
      GoRoute(
        path: '/practice/:level',
        builder: (context, state) =>
            PracticeLessonsScreen(level: state.pathParameters['level']!),
      ),
      // Practice/exam runner (deep-link entry; the Recommend/Exam/Practice pickers
      // that launch it land with their own slices). `?category=exam&progress=<p>`.
      GoRoute(
        path: '/practice/:level/:lesson',
        builder: (context, state) => PracticeRunnerPage(
          options: PracticeOptions(
            category: PracticeCategory.fromWire(
              state.uri.queryParameters['category'],
            ),
            number: state.pathParameters['level'],
            lessonId: state.pathParameters['lesson'],
            progress: state.uri.queryParameters['progress'],
          ),
        ),
      ),
    ],
  );
});
