/// Lessons module — the lesson translation screen.
///
/// Full-screen host for [TranslationDrill], opened from the milestone study
/// screen's app-bar translation action. Reads `/api/translation/lesson` via
/// [lessonTranslationsProvider] (keyed by passage id); route
/// `/translation/:passageId`.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/loading_view.dart';
import '../providers/lesson_providers.dart';
import '../widgets/translation_drill.dart';

class TranslationScreen extends ConsumerWidget {
  const TranslationScreen({super.key, required this.passageId});

  final String passageId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final translations = ref.watch(lessonTranslationsProvider(passageId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.translationTitle)),
      body: translations.when(
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
      ),
    );
  }
}
