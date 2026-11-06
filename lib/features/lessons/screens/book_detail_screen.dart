/// Lessons module — one book's lessons and their parts.
///
/// Consolidates the web's lesson-list and part-list screens
/// (`app/learner/books/[code]/page.tsx` and `app/learner/books/[code]/[lesson]/page.tsx`)
/// into one: a book header banner followed by expandable `.lesson-card` tiles
/// whose parts (`.part-list-item`) deep-link into lesson study (`GET /api/lesson/book/:code`).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
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
      backgroundColor: BrandColors.card,
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
              return EmptyState(
                icon: Icons.menu_book_outlined,
                title: l10n.booksEmpty,
              );
            }
            return ListView.separated(
              padding: LessonsStyles.listPadding,
              itemCount: detail.lessons.length + 1,
              separatorBuilder: (_, _) => LessonsStyles.lessonListGap,
              itemBuilder: (context, i) {
                if (i == 0) {
                  return _BookHeader(
                    title: detail.bookName ?? code,
                    lessonCount: detail.lessons.length,
                  );
                }
                return _LessonTile(lesson: detail.lessons[i - 1]);
              },
            );
          },
        ),
      ),
    );
  }
}

class _BookHeader extends StatelessWidget {
  const _BookHeader({required this.title, required this.lessonCount});

  final String title;
  final int lessonCount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: LessonsStyles.bookHeaderPadding,
      child: Column(
        children: [
          Text(
            title,
            style: LessonsStyles.bookHeaderTitleStyle,
            textAlign: TextAlign.center,
          ),
          LessonsStyles.pickerTitleGap,
          Text(
            l10n.booksLessonsCount(lessonCount),
            style: LessonsStyles.bookHeaderSubtitleStyle,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _LessonTile extends StatefulWidget {
  const _LessonTile({required this.lesson});

  final LearnerBookLesson lesson;

  @override
  State<_LessonTile> createState() => _LessonTileState();
}

class _LessonTileState extends State<_LessonTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final lesson = widget.lesson;
    final hasTitle = lesson.title != null && lesson.title!.isNotEmpty;
    final label = l10n.lessonLabel(lesson.lesson);
    final heading = hasTitle ? lesson.title! : label;
    final subLabel = hasTitle ? label : null;

    final partsCountText = lesson.doneCount > 0
        ? '${l10n.booksPartsCount(lesson.partCount)} · ${lesson.doneCount}/${lesson.partCount}'
        : l10n.booksPartsCount(lesson.partCount);

    return Container(
      decoration: LessonsStyles.lessonCardDecoration,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Padding(
                padding: LessonsStyles.lessonCardPadding,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            heading,
                            style: LessonsStyles.lessonCardTitleStyle,
                          ),
                          if (subLabel != null) ...[
                            LessonsStyles.lessonSubGap,
                            Text(
                              subLabel,
                              style: LessonsStyles.lessonCardSubStyle,
                            ),
                          ],
                          LessonsStyles.lessonCountGap,
                          Container(
                            padding: LessonsStyles.lessonCountBadgePadding,
                            decoration: LessonsStyles.lessonCountBadgeDecoration,
                            child: Text(
                              partsCountText,
                              style: LessonsStyles.lessonCountBadgeStyle,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      _expanded ? Icons.expand_less : Icons.expand_more,
                      color: BrandColors.mutedText,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_expanded && lesson.parts.isNotEmpty)
            Padding(
              padding: LessonsStyles.partListPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < lesson.parts.length; i++) ...[
                    if (i > 0) LessonsStyles.partItemGap,
                    _PartItem(part: lesson.parts[i]),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _PartItem extends StatelessWidget {
  const _PartItem({required this.part});

  final LearnerBookPart part;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      decoration: LessonsStyles.partItemDecoration,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: LessonsStyles.partItemRadius,
          onTap: () => context.push('/lesson/${part.passageId}'),
          child: Padding(
            padding: LessonsStyles.partItemInnerPadding,
            child: Row(
              children: [
                Expanded(
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        l10n.partLabel(part.part),
                        style: LessonsStyles.partItemTitleStyle,
                      ),
                      if (part.completed) ...[
                        LessonsStyles.partDoneGap,
                        Text(
                          '✓ ${l10n.booksCompleted}',
                          style: LessonsStyles.partDoneBadgeStyle,
                        ),
                      ],
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
