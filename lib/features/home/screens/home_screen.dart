/// Home module — the learner dashboard (tabbed shell).
///
/// Ported from the web `HomeShell.tsx` + `HomeTabs.tsx`: a pill-style tab bar
/// (Review · Lesson · Recommend, Review first and selected by default) above the
/// active panel. The Lesson tab runs the learner's current lesson in place. While
/// a graded trainer runs, switching tabs asks for confirmation (the web's home
/// guard). This screen is a shell route — the surrounding Scaffold, teal app bar
/// and navigation drawer come from `AppShell`, so it renders body content only.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/session_guard.dart';
import '../../auth/providers/auth_provider.dart';
import '../styles/home_styles.dart';
import '../widgets/lesson_tab.dart';
import '../widgets/recommend_tab.dart';
import '../widgets/review_tab.dart';

/// Web `HOME_TABS` order; Review is the default.
const int _reviewTab = 0;
const int _lessonTab = 1;
const int _recommendTab = 2;

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(
    length: 3,
    initialIndex: _reviewTab,
    vsync: this,
  );

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  /// Switching tabs while a trainer runs asks first (the web's home guard).
  Future<void> _select(int target) async {
    if (target == _tabs.index) return;
    if (ref.read(activityRunningProvider)) {
      final leave = await confirmLeaveSession(context, forTabSwitch: true);
      if (!leave || !mounted) return;
      ref.read(activityRunningProvider.notifier).set(false);
    }
    _tabs.animateTo(target);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final username = ref
        .watch(authNotifierProvider)
        .asData
        ?.value
        .user
        ?.username;
    final running = ref.watch(activityRunningProvider);

    return Column(
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
        Padding(
          padding: HomeStyles.tabsOuterPadding,
          child: AnimatedBuilder(
            animation: _tabs.animation!,
            builder: (context, _) {
              final selected = _tabs.animation!.value.round();
              return Container(
                decoration: HomeStyles.tabsDecoration,
                padding: HomeStyles.tabsPadding,
                child: Row(
                  children: [
                    _DashboardTab(
                      icon: Icons.history,
                      label: l10n.homeTabReview,
                      selected: selected == _reviewTab,
                      onTap: () => _select(_reviewTab),
                    ),
                    HomeStyles.tabsGap,
                    _DashboardTab(
                      icon: Icons.menu_book_outlined,
                      label: l10n.homeTabLesson,
                      selected: selected == _lessonTab,
                      onTap: () => _select(_lessonTab),
                    ),
                    HomeStyles.tabsGap,
                    _DashboardTab(
                      icon: Icons.explore_outlined,
                      label: l10n.homeTabRecommend,
                      selected: selected == _recommendTab,
                      onTap: () => _select(_recommendTab),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabs,
            // No swiping away from a running trainer.
            physics: running ? const NeverScrollableScrollPhysics() : null,
            children: const [ReviewTab(), LessonTab(), RecommendTab()],
          ),
        ),
      ],
    );
  }
}

/// `.learner-home-tab`: icon + label pill sharing the bar's width equally; the
/// selected one is sage-filled with white text. (The web hides the due-count
/// badge on phones, so it is not drawn.)
class _DashboardTab extends StatelessWidget {
  const _DashboardTab({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? Colors.white : HomeStyles.tabTextColor;
    return Expanded(
      child: Material(
        color: selected ? HomeStyles.tabSelectedBg : Colors.transparent,
        borderRadius: HomeStyles.tabRadius,
        child: InkWell(
          borderRadius: HomeStyles.tabRadius,
          onTap: onTap,
          child: Padding(
            padding: HomeStyles.tabPadding,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: HomeStyles.tabIconSize, color: color),
                HomeStyles.tabIconGap,
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: HomeStyles.tabLabelStyle.copyWith(color: color),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
