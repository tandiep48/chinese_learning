/// Home module — the dashboard's Lesson tab.
///
/// Ported from the web `LessonTab.tsx`: it runs the lesson in place by mounting
/// [LessonFlowView] on the learner's current lesson (`GET
/// /api/user/dashboard-current-lesson`) — the six-step milestone across every
/// part, then Grammar, Translation and on to the next lesson. With no recent
/// lesson it shows the empty note with a link to the HSK picker.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/styles/shared_styles.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/loading_view.dart';
import '../../../shared/widgets/session_guard.dart';
import '../../milestone/widgets/lesson_flow_view.dart';
import '../providers/home_provider.dart';
import '../styles/home_styles.dart';

class LessonTab extends ConsumerWidget {
  const LessonTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final currentLesson = ref.watch(currentLessonProvider);

    return currentLesson.when(
      // Keep the flow mounted while the roll to the next lesson refreshes this.
      skipLoadingOnReload: true,
      loading: () => const LoadingView(),
      error: (_, _) => EmptyState(
        icon: Icons.cloud_off,
        title: l10n.homeError,
        action: FilledButton(
          style: HomeStyles.continueButtonStyle,
          onPressed: () => ref.invalidate(currentLessonProvider),
          child: Text(l10n.commonRetry),
        ),
      ),
      data: (data) {
        final lesson = data.lesson;
        if (!data.hasRecent || lesson == null) {
          return RefreshIndicator(
            onRefresh: () => ref.refresh(currentLessonProvider.future),
            child: ListView(
              padding: HomeStyles.pagePadding,
              children: const [_NoRecentCard()],
            ),
          );
        }
        return LessonFlowView(
          passageId: lesson.passageId,
          onRunningChange: ref.read(activityRunningProvider.notifier).set,
        );
      },
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
          Text(l10n.homeNoRecentTitle, style: HomeStyles.emptyBodyStyle),
          HomeStyles.asideGap,
          InkWell(
            onTap: () => context.go('/library'),
            child: Text(l10n.homeBrowseHsk, style: HomeStyles.noteLinkStyle),
          ),
        ],
      ),
    );
  }
}
