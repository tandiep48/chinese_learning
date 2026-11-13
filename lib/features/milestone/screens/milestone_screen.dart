/// Milestone module — the full-screen host of the lesson flow.
///
/// Mounted at `/lesson/:passageId` (`?step=` deep-links a step): an app bar
/// titled with the active part (plus shortcuts to its Translation and Grammar)
/// around [LessonFlowView], which owns the six steps and the roll through the
/// lesson.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../lessons/providers/lesson_providers.dart';
import '../widgets/lesson_flow_view.dart';

class MilestoneScreen extends ConsumerStatefulWidget {
  const MilestoneScreen({super.key, required this.passageId, this.initialStep});

  final String passageId;
  final int? initialStep;

  @override
  ConsumerState<MilestoneScreen> createState() => _MilestoneScreenState();
}

class _MilestoneScreenState extends ConsumerState<MilestoneScreen> {
  late String _passageId = widget.passageId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final title = ref
        .watch(passageDetailProvider(_passageId))
        .asData
        ?.value
        .title;

    return Scaffold(
      backgroundColor: BrandColors.card,
      appBar: AppBar(
        title: Text(title ?? _passageId),
        actions: [
          IconButton(
            icon: const Icon(Icons.translate),
            tooltip: l10n.translationTitle,
            onPressed: () => context.push('/translation/$_passageId'),
          ),
          IconButton(
            icon: const Icon(Icons.menu_book_outlined),
            tooltip: l10n.grammarTitle,
            onPressed: () => context.push('/grammar/$_passageId'),
          ),
        ],
      ),
      body: SafeArea(
        child: LessonFlowView(
          passageId: widget.passageId,
          initialStep: widget.initialStep,
          onPartChange: (id) => setState(() => _passageId = id),
        ),
      ),
    );
  }
}
