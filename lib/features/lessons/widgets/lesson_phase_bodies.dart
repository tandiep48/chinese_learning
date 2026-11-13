/// Lessons module — loading / error / empty / data bodies for a lesson's Grammar
/// and Translation phases, shared by the standalone screens and the lesson flow.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/loading_view.dart';
import '../providers/lesson_providers.dart';
import 'grammar_panel.dart';
import 'translation_drill.dart';

class GrammarBody extends ConsumerWidget {
  const GrammarBody({super.key, required this.passageId});

  final String passageId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return ref
        .watch(lessonGrammarProvider(passageId))
        .when(
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
        );
  }
}

class TranslationBody extends ConsumerWidget {
  const TranslationBody({super.key, required this.passageId});

  final String passageId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return ref
        .watch(lessonTranslationsProvider(passageId))
        .when(
          loading: () => const LoadingView(),
          error: (_, _) => EmptyState(
            icon: Icons.cloud_off,
            title: l10n.translationFailedLoad,
            action: FilledButton.tonal(
              onPressed: () =>
                  ref.invalidate(lessonTranslationsProvider(passageId)),
              child: Text(l10n.commonRetry),
            ),
          ),
          data: (rows) => rows.isEmpty
              ? EmptyState(icon: Icons.translate, title: l10n.translationEmpty)
              : TranslationDrill(rows: rows),
        );
  }
}
