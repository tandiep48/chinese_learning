/// Practice module — the exam lessons list for one HSK level.
///
/// Ported from `PracticeLessonSelect.tsx` with `category="exam"`: lists the
/// available lessons (`/api/practice/<level>?category=exam`); tapping one opens
/// the P2 runner in exam mode. Route `/exam/:level`.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/loading_view.dart';
import '../data/models/practice_question.dart';
import '../data/practice_repository.dart';
import '../styles/practice_styles.dart';

/// Exam lessons for an HSK level (`getLessons(level, exam)`).
final examLessonsProvider = FutureProvider.autoDispose
    .family<List<String>, String>((ref, level) {
      return ref
          .read(practiceRepositoryProvider)
          .getLessons(level, PracticeCategory.exam);
    });

class ExamLessonsScreen extends ConsumerWidget {
  const ExamLessonsScreen({super.key, required this.level});

  final String level;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final lessons = ref.watch(examLessonsProvider(level));

    return Scaffold(
      appBar: AppBar(title: Text('HSK $level · ${l10n.dashboardExam}')),
      body: lessons.when(
        loading: () => const LoadingView(),
        error: (_, _) => EmptyState(
          icon: Icons.cloud_off,
          title: l10n.studyError,
          action: FilledButton.tonal(
            onPressed: () => ref.invalidate(examLessonsProvider(level)),
            child: Text(l10n.commonRetry),
          ),
        ),
        data: (list) => list.isEmpty
            ? EmptyState(icon: Icons.inbox_outlined, title: l10n.examNoLessons)
            : ListView.separated(
                padding: PracticeStyles.screenPadding,
                itemCount: list.length + 1,
                separatorBuilder: (_, _) => PracticeStyles.gap12,
                itemBuilder: (context, i) {
                  if (i == 0) {
                    return Text(
                      l10n.examChooseLesson,
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
          '/practice/$level/${Uri.encodeComponent(lesson)}?category=exam',
        ),
        child: Container(
          decoration: PracticeStyles.lessonCardDecoration,
          padding: PracticeStyles.lessonCardPadding,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '${l10n.examLessonPrefix} $lesson',
                  style: PracticeStyles.lessonLabel,
                ),
              ),
              const Icon(Icons.chevron_right, color: BrandColors.mutedText),
            ],
          ),
        ),
      ),
    );
  }
}
