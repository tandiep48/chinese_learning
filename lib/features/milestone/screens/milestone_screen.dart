/// Milestone module — the full-screen host of the lesson flow.
///
/// Mounted at `/lesson/:passageId` (`?step=` deep-links a step): an app bar
/// titled with the active part around [LessonFlowView], which owns the six steps and the roll through the
/// lesson.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
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
    final title = ref
        .watch(passageDetailProvider(_passageId))
        .asData
        ?.value
        .title;

    return Scaffold(
      backgroundColor: BrandColors.card,
      appBar: AppBar(title: Text(title ?? _passageId)),
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
