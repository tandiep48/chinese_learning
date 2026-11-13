/// Shell module — the app shell for top-level learner destinations.
///
/// Wraps the shell routes (the dashboard today; the Library joins in Slice N2)
/// in a [Scaffold] that provides the teal app bar — whose leading hamburger
/// opens the [NavDrawer] — and the navigation drawer itself. Deeper screens
/// (book detail, lesson study) are pushed over this shell with their own app
/// bars, so they are deliberately NOT shell routes. Ported from the persistent
/// learner layout in `yi-chinese-manage/app/learner/layout.tsx`.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../widgets/nav_drawer.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  /// The active shell route's screen body (provided by go_router's [ShellRoute]).
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final location = GoRouterState.of(context).uri.path;
    // Title tracks the active shell destination (the dashboard and the Library
    // today); anything else falls back to the app name.
    final title = switch (location) {
      '/' => l10n.navDashboard,
      '/library' => l10n.navLibrary,
      _ => l10n.appTitle,
    };

    return Scaffold(
      backgroundColor: BrandColors.card,
      appBar: AppBar(title: Text(title)),
      drawer: const NavDrawer(),
      body: SafeArea(top: false, child: child),
    );
  }
}
