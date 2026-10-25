/// Lessons module — one book's lessons and their parts.
///
/// Consolidates the web's lesson-list and part-list screens
/// (`app/learner/books/[code]/...`) into one: each lesson is an expandable
/// tile whose parts deep-link into lesson study (`GET /api/lesson/book/:code`).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/loading_view.dart';
import '../data/models/learner_book.dart';
import '../providers/lesson_providers.dart';
import '../styles/lessons_styles.dart';

class BookDetailScreen extends ConsumerWidget {
  const BookDetailScreen({super.key, required this.code});

  final String code;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final book = ref.watch(learnerBookProvider(code));

    return Scaffold(
      appBar: AppBar(
        title: Text(book.asData?.value.bookName ?? code),
      ),
      body: SafeArea(
        child: book.when(
          loading: () => const LoadingView(),
          error: (_, _) => EmptyState(
            icon: Icons.cloud_off,
            title: l10n.bookError,
            action: FilledButton.tonal(
              onPressed: () => ref.invalidate(learnerBookProvider(code)),
              child: Text(l10n.commonRetry),
            ),
          ),
          data: (detail) {
            if (detail.lessons.isEmpty) {
              return EmptyState(icon: Icons.menu_book_outlined, title: l10n.booksEmpty);
            }
            return ListView(
              padding: LessonsStyles.listPadding,
              children: [
                for (final lesson in detail.lessons) _LessonTile(lesson: lesson),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _LessonTile extends StatelessWidget {
  const _LessonTile({required this.lesson});

  final LearnerBookLesson lesson;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final heading = (lesson.title != null && lesson.title!.isNotEmpty)
        ? lesson.title!
        : l10n.lessonLabel(lesson.lesson);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        title: Text(heading, style: theme.textTheme.titleLarge),
        subtitle: Text(l10n.booksPartsCount(lesson.partCount)),
        children: [
          for (final part in lesson.parts)
            ListTile(
              leading: Icon(
                part.completed ? Icons.check_circle : Icons.play_circle_outline,
                color: part.completed ? theme.colorScheme.primary : null,
              ),
              title: Text(l10n.partLabel(part.part)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/lesson/${part.passageId}'),
            ),
        ],
      ),
    );
  }
}
