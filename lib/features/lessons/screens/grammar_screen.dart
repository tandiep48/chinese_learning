/// Lessons module — the lesson-wide grammar screen.
///
/// Full-screen host for [GrammarBody], opened from the milestone's app-bar
/// grammar action and the HSK part page. Route `/grammar/:passageId`.
library;

import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../widgets/lesson_phase_bodies.dart';

class GrammarScreen extends StatelessWidget {
  const GrammarScreen({super.key, required this.passageId});

  final String passageId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).grammarTitle)),
      body: GrammarBody(passageId: passageId),
    );
  }
}
