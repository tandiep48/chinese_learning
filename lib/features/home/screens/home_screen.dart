/// Home module — the learner dashboard (tabbed shell, Slice N3).
///
/// Ported from the web `HomeShell.tsx` + `HomeTabs.tsx`: a greeting followed by
/// a Lesson / Review / Recommend tab bar. The Lesson tab is the working one
/// (current-lesson card + Library entry points); Review and Recommend are
/// "coming soon" stubs until the SRS / practice slices (R4/R5). This screen is
/// a shell route — the surrounding Scaffold, teal app bar and navigation drawer
/// come from `AppShell`, so it renders body content only. The web's in-place
/// activity guard and the lesson-study sidebar dock are deferred (port plan).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/providers/auth_provider.dart';
import '../../review/data/review_repository.dart';
import '../styles/home_styles.dart';
import '../widgets/lesson_tab.dart';
import '../widgets/recommend_tab.dart';
import '../widgets/review_tab.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final username = ref
        .watch(authNotifierProvider)
        .asData
        ?.value
        .user
        ?.username;
    final reviewCount = ref.watch(reviewCountProvider).asData?.value;

    return DefaultTabController(
      length: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: HomeStyles.greetingPadding,
            child: Text(
              username != null
                  ? l10n.homeGreeting(username)
                  : l10n.homeGreetingGeneric,
              style: HomeStyles.greetingStyle,
            ),
          ),
          DecoratedBox(
            decoration: HomeStyles.tabBarDecoration,
            child: TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelColor: BrandColors.primary,
              unselectedLabelColor: BrandColors.mutedText,
              indicatorColor: BrandColors.primary,
              labelStyle: HomeStyles.tabLabelStyle,
              unselectedLabelStyle: HomeStyles.tabLabelStyle,
              tabs: [
                _DashboardTab(
                  icon: Icons.menu_book_outlined,
                  label: l10n.homeTabLesson,
                ),
                _DashboardTab(
                  icon: Icons.history,
                  label: l10n.homeTabReview,
                  badge: reviewCount,
                ),
                _DashboardTab(
                  icon: Icons.explore_outlined,
                  label: l10n.homeTabRecommend,
                ),
              ],
            ),
          ),
          const Expanded(
            child: TabBarView(
              children: [LessonTab(), ReviewTab(), RecommendTab()],
            ),
          ),
        ],
      ),
    );
  }
}

/// An inline icon + label tab (the web tabs show both side by side).
class _DashboardTab extends StatelessWidget {
  const _DashboardTab({required this.icon, required this.label, this.badge});

  final IconData icon;
  final String label;

  /// Words-due count shown as a pill (Review tab); hidden when null or zero.
  final int? badge;

  @override
  Widget build(BuildContext context) {
    final count = badge;
    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: HomeStyles.tabIconSize),
          HomeStyles.tabIconGap,
          Text(label),
          if (count != null && count > 0) ...[
            HomeStyles.tabIconGap,
            Container(
              decoration: HomeStyles.tabBadgeDecoration,
              padding: HomeStyles.tabBadgePadding,
              child: Text('$count', style: HomeStyles.tabBadgeText),
            ),
          ],
        ],
      ),
    );
  }
}
