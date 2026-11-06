/// Home module — the learner home (minimal first pass, web-matched restyle).
///
/// Scoped down from the web dashboard (`HomeShell.tsx` + `CurrentLessonPanel.tsx`
/// + `RecentLessonPanel.tsx`): a greeting, a "continue where you left off" card
/// (`GET /api/user/dashboard-current-lesson`) that deep-links into lesson
/// study, and an entry point to the Books list.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/styles/shared_styles.dart';
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
    final username = ref.watch(authNotifierProvider).asData?.value.user?.username;
    final currentLesson = ref.watch(currentLessonProvider);

    return Scaffold(
      backgroundColor: BrandColors.background,
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
                style: HomeStyles.greetingStyle,
              ),
              HomeStyles.sectionGap,
              currentLesson.when(
                loading: () => Container(
                  decoration: SharedStyles.learnerCardDecoration,
                  padding: HomeStyles.asidePadding,
                  child: const LoadingView(),
                ),
                error: (_, _) => Container(
                  decoration: SharedStyles.learnerCardDecoration,
                  child: EmptyState(
                    icon: Icons.cloud_off,
                    title: l10n.homeError,
                    action: FilledButton(
                      style: HomeStyles.continueButtonStyle,
                      onPressed: () => ref.invalidate(currentLessonProvider),
                      child: Text(l10n.commonRetry),
                    ),
                  ),
                ),
                data: (data) => data.hasRecent && data.lesson != null
                    ? _ContinueCard(lesson: data.lesson!)
                    : const _NoRecentCard(),
              ),
              HomeStyles.sectionGap,
              _BooksEntry(
                title: l10n.homeBrowseBooks,
                subtitle: l10n.booksSubtitle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Resume-lesson card ported from `CurrentLessonPanel.tsx` + `RecentLessonPanel.tsx`.
class _ContinueCard extends StatelessWidget {
  const _ContinueCard({required this.lesson});

  final CurrentLessonInfo lesson;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      decoration: SharedStyles.learnerCardDecoration,
      padding: HomeStyles.asidePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.homeCurrentLessonKicker.toUpperCase(),
            style: HomeStyles.kickerStyle,
          ),
          HomeStyles.asideGap,
          Container(
            decoration: HomeStyles.recentPanelDecoration,
            padding: HomeStyles.recentPanelPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.homeContinueTitle,
                  style: HomeStyles.recentTitleStyle,
                ),
                HomeStyles.recentTitleGap,
                Text(
                  l10n.homeContinueSubtitle(
                    lesson.hskLevel,
                    lesson.lesson,
                    lesson.part,
                  ),
                  style: HomeStyles.recentSubtitleStyle,
                ),
                HomeStyles.recentButtonGap,
                FilledButton(
                  style: HomeStyles.continueButtonStyle,
                  onPressed: () => context.push('/lesson/${lesson.passageId}'),
                  child: Text(l10n.homeContinueButton),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Empty current-lesson card ported from `CurrentLessonPanel.tsx` (`.learner-home-aside`).
class _NoRecentCard extends StatelessWidget {
  const _NoRecentCard();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      decoration: SharedStyles.learnerCardDecoration,
      padding: HomeStyles.asidePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.homeCurrentLessonKicker.toUpperCase(),
            style: HomeStyles.kickerStyle,
          ),
          HomeStyles.asideGap,
          Text(
            l10n.homeNoRecentTitle,
            style: HomeStyles.emptyBodyStyle,
          ),
          HomeStyles.asideGap,
          InkWell(
            onTap: () => context.push('/books'),
            child: Text(
              l10n.homeBrowseBooks,
              style: HomeStyles.noteLinkStyle,
            ),
          ),
        ],
      ),
    );
  }
}

/// Entry point to the Books list, styled after `.learner-home-aside`.
class _BooksEntry extends StatelessWidget {
  const _BooksEntry({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: SharedStyles.learnerCardDecoration,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: HomeStyles.cardBorderRadius,
          onTap: () => context.push('/books'),
          child: Padding(
            padding: HomeStyles.asidePadding,
            child: Row(
              children: [
                const Icon(
                  Icons.menu_book_outlined,
                  color: BrandColors.primary,
                  size: HomeStyles.booksIconSize,
                ),
                HomeStyles.booksIconGap,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: HomeStyles.booksTitleStyle),
                      HomeStyles.booksSubtitleGap,
                      Text(subtitle, style: HomeStyles.booksSubtitleStyle),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: BrandColors.mutedText,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
