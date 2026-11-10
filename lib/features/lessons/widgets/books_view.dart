/// Lessons module — the Books browse body (list + skeleton/empty/error states).
///
/// Body-only so it mounts both as the standalone Books screen (`BooksScreen`)
/// and as the Library's Books tab (`LibraryScreen`, Slice N2). Ported from the
/// web Books grid (`yi-chinese-manage/app/learner/books/page.tsx` +
/// `lesson-picker.css` + `books.css`). Lists the learner's books
/// (`GET /api/lesson/books`); tapping a book drills into its lessons.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/skeleton_box.dart';
import '../providers/lesson_providers.dart';
import '../styles/lessons_styles.dart';
import 'book_card.dart';

class BooksView extends ConsumerWidget {
  const BooksView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final books = ref.watch(learnerBooksProvider);

    return books.when(
      loading: () => _BooksSkeleton(
        title: l10n.booksTitle,
        subtitle: l10n.booksSubtitle,
      ),
      error: (_, _) => EmptyState(
        icon: Icons.cloud_off,
        title: l10n.booksError,
        action: FilledButton.tonal(
          onPressed: () => ref.invalidate(learnerBooksProvider),
          child: Text(l10n.commonRetry),
        ),
      ),
      data: (list) {
        if (list.isEmpty) {
          return EmptyState(
            icon: Icons.menu_book_outlined,
            title: l10n.booksEmpty,
          );
        }
        return RefreshIndicator(
          onRefresh: () => ref.refresh(learnerBooksProvider.future),
          child: ListView.separated(
            padding: LessonsStyles.listPadding,
            itemCount: list.length + 1,
            separatorBuilder: (_, index) => index == 0
                ? LessonsStyles.pickerHeaderGap
                : LessonsStyles.booksGridGap,
            itemBuilder: (context, i) {
              if (i == 0) {
                return _PickerHeader(
                  title: l10n.booksTitle,
                  subtitle: l10n.booksSubtitle,
                );
              }
              final book = list[i - 1];
              return BookCard(
                book: book,
                onTap: () => context.push('/books/${book.bookCode}'),
              );
            },
          ),
        );
      },
    );
  }
}

class _PickerHeader extends StatelessWidget {
  const _PickerHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: LessonsStyles.pickerTitleStyle,
          textAlign: TextAlign.center,
        ),
        LessonsStyles.pickerTitleGap,
        Text(
          subtitle,
          style: LessonsStyles.pickerSubtitleStyle,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _BooksSkeleton extends StatelessWidget {
  const _BooksSkeleton({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: LessonsStyles.listPadding,
      itemCount: 7,
      separatorBuilder: (_, index) =>
          index == 0 ? LessonsStyles.pickerHeaderGap : LessonsStyles.booksGridGap,
      itemBuilder: (_, i) {
        if (i == 0) {
          return _PickerHeader(title: title, subtitle: subtitle);
        }
        return Container(
          decoration: LessonsStyles.bookCardDecoration,
          clipBehavior: Clip.antiAlias,
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonBox(
                width: LessonsStyles.coverSize,
                height: LessonsStyles.coverSize,
                radius: 0,
              ),
              Expanded(
                child: Padding(
                  padding: LessonsStyles.bookCardBodyPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonBox(width: 160, height: 18),
                      LessonsStyles.bookCardBodyGap,
                      SkeletonBox(width: 100, height: 14),
                      LessonsStyles.bookCardBodyGap,
                      SkeletonBox(width: 80, height: 12),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
