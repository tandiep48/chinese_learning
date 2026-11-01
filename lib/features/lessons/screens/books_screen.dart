/// Lessons module — the Books list (browse entry point).
///
/// Lists the learner's books (`GET /api/lesson/books`) with skeleton loading
/// and an empty/error state; tapping a book drills into its lessons. Ported
/// from the web Books grid (`app/learner/books/page.tsx`).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/skeleton_box.dart';
import '../providers/lesson_providers.dart';
import '../styles/lessons_styles.dart';
import '../widgets/book_card.dart';

class BooksScreen extends ConsumerWidget {
  const BooksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final books = ref.watch(learnerBooksProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.booksTitle)),
      body: SafeArea(
        child: books.when(
          loading: () => const _BooksSkeleton(),
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
              return EmptyState(icon: Icons.menu_book_outlined, title: l10n.booksEmpty);
            }
            return RefreshIndicator(
              onRefresh: () => ref.refresh(learnerBooksProvider.future),
              child: ListView.separated(
                padding: LessonsStyles.listPadding,
                itemCount: list.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final book = list[i];
                  return BookCard(
                    book: book,
                    onTap: () => context.push('/books/${book.bookCode}'),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _BooksSkeleton extends StatelessWidget {
  const _BooksSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: LessonsStyles.listPadding,
      itemCount: 6,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (_, _) => const Card(
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonBox(
                width: LessonsStyles.coverWidth,
                height: LessonsStyles.coverHeight,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(width: 160, height: 18),
                    SizedBox(height: 8),
                    SkeletonBox(width: 100, height: 14),
                    SizedBox(height: 6),
                    SkeletonBox(width: 80, height: 12),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
