/// Home module — the mint "Continue where you left off" panel.
///
/// Ported from `RecentLessonPanel.tsx`. Shared by the dashboard's Lesson tab and
/// the HSK picker; renders nothing while loading or when there is no recent lesson.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../data/models/current_lesson.dart';
import '../providers/home_provider.dart';
import '../styles/home_styles.dart';

/// The panel for a known [lesson].
class RecentLessonPanel extends StatelessWidget {
  const RecentLessonPanel({super.key, required this.lesson});

  final CurrentLessonInfo lesson;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      decoration: HomeStyles.recentPanelDecoration,
      padding: HomeStyles.recentPanelPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.homeContinueTitle, style: HomeStyles.recentTitleStyle),
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
    );
  }
}

/// Self-loading variant for screens outside the dashboard (the HSK picker).
class RecentLessonPanelLoader extends ConsumerWidget {
  const RecentLessonPanelLoader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(currentLessonProvider).asData?.value;
    if (data == null || !data.hasRecent || data.lesson == null) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: RecentLessonPanel(lesson: data.lesson!),
    );
  }
}
