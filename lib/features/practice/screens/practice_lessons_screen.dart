/// Practice module — the practice lessons list for one HSK level.
///
/// Ported from `PracticeLessonSelect.tsx` with `category="practice"`: lists the
/// available lessons (`/api/practice/<level>?category=practice`); tapping one
/// opens the practice runner in practice mode. Route `/practice/:level` (the
/// runner itself is the two-segment `/practice/:level/:lesson`). Mirrors
/// [ExamLessonsScreen].
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/loading_view.dart';
import '../data/models/practice_question.dart';
import '../data/practice_repository.dart';
import '../styles/practice_styles.dart';

/// Practice lessons for an HSK level (`getLessons(level, practice)`).
final practiceLessonsProvider = FutureProvider.autoDispose
    .family<List<String>, String>((ref, level) {
      return ref
          .read(practiceRepositoryProvider)
          .getLessons(level, PracticeCategory.practice);
    });

class PracticeLessonsScreen extends ConsumerWidget {
  const PracticeLessonsScreen({super.key, required this.level});

  final String level;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final lessons = ref.watch(practiceLessonsProvider(level));

    return Scaffold(
      appBar: AppBar(title: Text('HSK $level · ${l10n.libraryTabPractice}')),
      body: lessons.when(
        loading: () => const LoadingView(),
        error: (_, _) => EmptyState(
          icon: Icons.cloud_off,
          title: l10n.studyError,
          action: FilledButton.tonal(
            onPressed: () => ref.invalidate(practiceLessonsProvider(level)),
            child: Text(l10n.commonRetry),
          ),
        ),
        data: (list) => list.isEmpty
            ? EmptyState(
                icon: Icons.inbox_outlined,
                title: l10n.practiceNoLessons,
              )
            : ListView.separated(
                padding: PracticeStyles.screenPadding,
                itemCount: list.length + 1,
                separatorBuilder: (_, _) => PracticeStyles.gap12,
                itemBuilder: (context, i) {
                  if (i == 0) {
                    return Text(
                      l10n.practiceChooseLesson,
                      style: PracticeStyles.pageSubtitle,
                    );
                  }
                  final lesson = list[i - 1];
                  return _lessonCard(context, l10n, lesson);
                },
              ),
      ),
    );
  }

  Widget _lessonCard(
    BuildContext context,
    AppLocalizations l10n,
    String lesson,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push(
          '/practice/$level/${Uri.encodeComponent(lesson)}?category=practice',
        ),
        child: Container(
          decoration: PracticeStyles.lessonCardDecoration,
          padding: PracticeStyles.lessonCardPadding,
          child: Center(
            child: Text(
              '${l10n.practiceLessonPrefix} $lesson',
              style: PracticeStyles.lessonLabel,
            ),
          ),
        ),
      ),
    );
  }
}
