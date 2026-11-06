/// Lessons module — one book row in the Books list.
///
/// Ported from `yi-chinese-manage/app/learner/books/page.tsx` and `books.css`
/// (`.book-card`): horizontal bordered card with a square cover on the left and
/// the book title + lesson/part counts on the right.
library;

import 'package:flutter/material.dart';

import '../../../core/env.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../data/models/learner_book.dart';
import '../styles/lessons_styles.dart';

class BookCard extends StatelessWidget {
  const BookCard({super.key, required this.book, required this.onTap});

  final LearnerBookSummary book;
  final VoidCallback onTap;

  String get _coverUrl {
    final raw = book.coverUrl;
    if (raw.isEmpty) return '';
    if (raw.startsWith('http')) return raw;
    return '${Env.apiBaseUrl}$raw';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final title = (book.name != null && book.name!.isNotEmpty) ? book.name! : book.bookCode;
    final partsText = book.doneCount > 0
        ? '${l10n.booksPartsCount(book.partCount)} · ${book.doneCount}/${book.partCount}'
        : l10n.booksPartsCount(book.partCount);

    return Container(
      decoration: LessonsStyles.bookCardDecoration,
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Cover(url: _coverUrl),
              Expanded(
                child: Padding(
                  padding: LessonsStyles.bookCardBodyPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: LessonsStyles.bookCardTitleStyle),
                      LessonsStyles.bookCardBodyGap,
                      Text(
                        l10n.booksLessonsCount(book.lessonCount),
                        style: LessonsStyles.bookCardCountStyle,
                      ),
                      LessonsStyles.bookCardBodyGap,
                      Text(
                        partsText,
                        style: LessonsStyles.bookCardCountStyle,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Cover extends StatelessWidget {
  const _Cover({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      width: LessonsStyles.coverSize,
      height: LessonsStyles.coverSize,
      decoration: LessonsStyles.coverFallbackDecoration,
      child: const Icon(Icons.menu_book, color: BrandColors.mutedText),
    );
    if (url.isEmpty) return fallback;
    return Image.network(
      url,
      width: LessonsStyles.coverSize,
      height: LessonsStyles.coverSize,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => fallback,
    );
  }
}
