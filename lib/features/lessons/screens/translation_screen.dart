/// Lessons module — the lesson translation screen.
///
/// Full-screen host for [TranslationBody], opened from the milestone's app-bar
/// translation action and the HSK part page. Route `/translation/:passageId`.
library;

import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../widgets/lesson_phase_bodies.dart';

class TranslationScreen extends StatelessWidget {
  const TranslationScreen({super.key, required this.passageId});

  final String passageId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translationTitle),
      ),
      body: TranslationBody(passageId: passageId),
    );
  }
}
