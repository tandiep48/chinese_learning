/// Lessons module — the lesson-wide grammar screen.
///
/// Full-screen host for [GrammarPanel], opened from the milestone study screen's
/// app-bar grammar action. Reads `/api/lesson/grammar/:passageId` via
/// [lessonGrammarProvider]; route `/grammar/:passageId`.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/loading_view.dart';
import '../providers/lesson_providers.dart';
import '../widgets/grammar_panel.dart';

class GrammarScreen extends ConsumerWidget {
  const GrammarScreen({super.key, required this.passageId});

  final String passageId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final grammar = ref.watch(lessonGrammarProvider(passageId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.grammarTitle)),
      body: grammar.when(
        loading: () => const LoadingView(),
        error: (_, _) => EmptyState(
          icon: Icons.cloud_off,
          title: l10n.grammarErrorLoading,
          action: FilledButton.tonal(
            onPressed: () => ref.invalidate(lessonGrammarProvider(passageId)),
            child: Text(l10n.commonRetry),
          ),
        ),
        data: (rules) => rules.isEmpty
            ? EmptyState(
                icon: Icons.menu_book_outlined,
                title: l10n.grammarNoRules,
              )
            : GrammarPanel(rules: rules),
      ),
    );
  }
}
