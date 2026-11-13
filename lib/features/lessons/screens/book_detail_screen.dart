/// Lessons module — step 2 of the Books flow: one book's lessons.
///
/// Ported from `app/learner/books/[code]/page.tsx`: a back link, the book banner
/// (cover + title + lesson count) and a `.lesson-card` per lesson with its part
/// count / `done/total`. A lesson opens its part list (`/books/:code/:lesson`,
/// [BookPartsScreen]). Data: `GET /api/lesson/book/:code`.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/media/gcs.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/loading_view.dart';
import '../data/models/learner_book.dart';
import '../providers/lesson_providers.dart';
import '../styles/lessons_styles.dart';
import '../widgets/picker_header.dart';

class BookDetailScreen extends ConsumerWidget {
  const BookDetailScreen({super.key, required this.code});

  final String code;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final book = ref.watch(learnerBookProvider(code));

    return Scaffold(
      backgroundColor: BrandColors.card,
      appBar: AppBar(title: Text(book.asData?.value.bookName ?? code)),
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
            final title = detail.bookName ?? code;
            return ListView(
              padding: LessonsStyles.hskListPadding,
              children: [
                PickerBackLink(
                  label: l10n.booksBackToBooks,
                  onTap: () => context.go('/books'),
                ),
                LessonsStyles.pickerToolbarGap,
                PickerHeader(
                  color: Colors.transparent,
                  imageUrl: bookCoverUrl(code),
                  hideImageOnError: true,
                  title: title,
                  subtitle: l10n.booksLessonsCount(detail.lessons.length),
                ),
                LessonsStyles.pickerHeaderBottomGap,
                if (detail.lessons.isEmpty)
                  Padding(
                    padding: LessonsStyles.hskEmptyPadding,
                    child: Text(
                      l10n.booksEmpty,
                      style: LessonsStyles.hskEmptyTextStyle,
                      textAlign: TextAlign.center,
                    ),
                  )
                else
                  for (var i = 0; i < detail.lessons.length; i++) ...[
                    if (i > 0) LessonsStyles.lessonListGap,
                    _LessonCard(code: code, lesson: detail.lessons[i]),
                  ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _LessonCard extends StatelessWidget {
  const _LessonCard({required this.code, required this.lesson});

  final String code;
  final LearnerBookLesson lesson;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hasTitle = lesson.title != null && lesson.title!.isNotEmpty;
    final label = l10n.lessonLabel(lesson.lesson);

    final countText = lesson.doneCount > 0
        ? '${l10n.booksPartsCount(lesson.partCount)} · ${lesson.doneCount}/${lesson.partCount}'
        : l10n.booksPartsCount(lesson.partCount);

    return Container(
      decoration: LessonsStyles.lessonCardDecoration,
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push(
            '/books/${Uri.encodeComponent(code)}/${Uri.encodeComponent(lesson.lesson)}',
          ),
          child: Padding(
            padding: LessonsStyles.lessonCardPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasTitle ? lesson.title! : label,
                  style: LessonsStyles.lessonCardTitleStyle,
                ),
                if (hasTitle) ...[
                  LessonsStyles.lessonSubGap,
                  Text(label, style: LessonsStyles.lessonCardSubStyle),
                ],
                LessonsStyles.lessonCountGap,
                Container(
                  padding: LessonsStyles.lessonCountBadgePadding,
                  decoration: LessonsStyles.lessonCountBadgeDecoration,
                  child: Text(
                    countText,
                    style: LessonsStyles.lessonCountBadgeStyle,
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
