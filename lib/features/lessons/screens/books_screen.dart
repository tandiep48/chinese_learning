/// Lessons module — the standalone Books screen.
///
/// A thin Scaffold wrapper (own app bar + back button) around [BooksView], used
/// for the `/books` route reached from the home "Browse Books" entry. The same
/// [BooksView] body also backs the Library's Books tab (Slice N2).
library;

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../widgets/books_view.dart';

class BooksScreen extends StatelessWidget {
  const BooksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: BrandColors.card,
      appBar: AppBar(title: Text(l10n.navBooks)),
      body: const SafeArea(child: BooksView()),
    );
  }
}
