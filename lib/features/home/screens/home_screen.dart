/// Home module — the learner home (minimal first pass).
///
/// Scoped down from the web dashboard: a greeting, a "continue where you left
/// off" card (`GET /api/user/dashboard-current-lesson`) that deep-links into
/// lesson study, and an entry point to the Books list. Stats charts and
/// recommendations are deferred per the port plan.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/loading_view.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/models/current_lesson.dart';
import '../providers/home_provider.dart';
import '../styles/home_styles.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final username = ref.watch(authNotifierProvider).asData?.value.user?.username;
    final currentLesson = ref.watch(currentLessonProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            tooltip: l10n.logoutTooltip,
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authNotifierProvider.notifier).logout(),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.refresh(currentLessonProvider.future),
          child: ListView(
            padding: HomeStyles.pagePadding,
            children: [
              Text(
                username != null ? l10n.homeGreeting(username) : l10n.homeGreetingGeneric,
                style: theme.textTheme.headlineMedium,
              ),
              HomeStyles.sectionGap,
              currentLesson.when(
                loading: () => const LoadingView(),
                error: (_, _) => EmptyState(
                  icon: Icons.cloud_off,
                  title: l10n.homeError,
                  action: FilledButton.tonal(
                    onPressed: () => ref.invalidate(currentLessonProvider),
                    child: Text(l10n.commonRetry),
                  ),
                ),
                data: (data) => data.hasRecent && data.lesson != null
                    ? _ContinueCard(lesson: data.lesson!)
                    : EmptyState(
                        icon: Icons.menu_book_outlined,
                        title: l10n.homeNoRecentTitle,
                        message: l10n.homeNoRecentMessage,
                      ),
              ),
              HomeStyles.sectionGap,
              _BooksEntry(label: l10n.homeBrowseBooks),
            ],
          ),
        ),
      ),
    );
  }
}

/// Resume-lesson card: tapping it deep-links into lesson study.
class _ContinueCard extends StatelessWidget {
  const _ContinueCard({required this.lesson});

  final CurrentLessonInfo lesson;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        onTap: () => context.go('/lesson/${lesson.passageId}'),
        child: Padding(
          padding: HomeStyles.cardPadding,
          child: Row(
            children: [
              Icon(Icons.play_circle_fill, color: theme.colorScheme.primary, size: 40),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.homeContinueTitle, style: theme.textTheme.titleLarge),
                    const SizedBox(height: 4),
                    Text(
                      l10n.homeContinueSubtitle(lesson.hskLevel, lesson.lesson, lesson.part),
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

/// Entry point to the Books list.
class _BooksEntry extends StatelessWidget {
  const _BooksEntry({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.library_books_outlined),
        title: Text(label),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.go('/books'),
      ),
    );
  }
}
