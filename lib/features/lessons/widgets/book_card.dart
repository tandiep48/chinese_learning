/// Lessons module — one book row in the Books list.
///
/// Shows the cover (with an icon fallback when it fails to load), the name and
/// the lesson/part counts; tapping drills into the book's lessons.
library;

import 'package:flutter/material.dart';

import '../../../core/env.dart';
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
    final theme = Theme.of(context);
    final title = (book.name != null && book.name!.isNotEmpty) ? book.name! : book.bookCode;

    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _Cover(url: _coverUrl),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleLarge),
                    const SizedBox(height: 4),
                    Text(
                      l10n.booksLessonsCount(book.lessonCount),
                      style: theme.textTheme.bodyMedium,
                    ),
                    Text(
                      book.doneCount > 0
                          ? '${l10n.booksPartsCount(book.partCount)} · ${book.doneCount}/${book.partCount}'
                          : l10n.booksPartsCount(book.partCount),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
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
    final theme = Theme.of(context);
    final fallback = Container(
      width: LessonsStyles.coverWidth,
      height: LessonsStyles.coverHeight,
      color: theme.colorScheme.surfaceContainer,
      child: Icon(Icons.menu_book, color: theme.colorScheme.outline),
    );
    if (url.isEmpty) return fallback;
    return Image.network(
      url,
      width: LessonsStyles.coverWidth,
      height: LessonsStyles.coverHeight,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => fallback,
    );
  }
}
