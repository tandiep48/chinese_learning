/// Lessons module — step 3 of the Books flow: the parts of one book lesson.
///
/// Ported from `app/learner/books/[code]/[lesson]/page.tsx`: a back link, a
/// "Book · Lesson" heading and a `.part-list-item` per part (with `✓ Completed`),
/// each opening the milestone runner (`/lesson/:passageId`). Route
/// `/books/:code/:lesson`; data `GET /api/lesson/book/:code`.
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
import '../widgets/picker_header.dart';

class BookPartsScreen extends ConsumerWidget {
  const BookPartsScreen({super.key, required this.code, required this.lesson});

  final String code;
  final String lesson;

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
            final matches = detail.lessons.where((l) => l.lesson == lesson);
            final current = matches.isEmpty ? null : matches.first;
            final lessonLabel = (current?.title?.isNotEmpty ?? false)
                ? current!.title!
                : l10n.lessonLabel(lesson);
            final parts = current?.parts ?? const <LearnerBookPart>[];

            return ListView(
              padding: LessonsStyles.hskListPadding,
              children: [
                PickerBackLink(
                  label: l10n.pickerBackToLessons,
                  onTap: () => context.canPop()
                      ? context.pop()
                      : context.go('/books/${Uri.encodeComponent(code)}'),
                ),
                LessonsStyles.pickerToolbarGap,
                PickerHeader(
                  color: Colors.transparent,
                  title: '${detail.bookName ?? code} · $lessonLabel',
                ),
                LessonsStyles.pickerHeaderBottomGap,
                if (parts.isEmpty)
                  Padding(
                    padding: LessonsStyles.hskEmptyPadding,
                    child: Text(
                      l10n.hskNoLessons,
                      style: LessonsStyles.hskEmptyTextStyle,
                      textAlign: TextAlign.center,
                    ),
                  )
                else
                  for (var i = 0; i < parts.length; i++) ...[
                    if (i > 0) LessonsStyles.partRowGap,
                    _PartRow(part: parts[i]),
                  ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PartRow extends StatelessWidget {
  const _PartRow({required this.part});

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
            padding: LessonsStyles.partRowPadding,
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
        ),
      ),
    );
  }
}
