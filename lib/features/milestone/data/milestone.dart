/// Milestone module — the six-step lesson-part progress state.
///
/// Ported from `yi-chinese-manage/lib/api/learner/milestone.ts` (`Milestone` +
/// `MilestoneStep`): raw JSON from `GET /api/lesson/milestone?passage_id=`.
/// `current_step` is the lowest incomplete step, or `total_steps + 1` once the
/// part is finished. `fromJson` validates its fields (plan rule 6).
library;

import '../../../core/api/validators.dart';

const int milestoneTotalSteps = 6;

class MilestoneStep {
  const MilestoneStep({
    required this.step,
    required this.completed,
    this.completedAt,
  });

  final int step;
  final bool completed;
  final String? completedAt;

  factory MilestoneStep.fromJson(Map<String, dynamic> json) {
    return MilestoneStep(
      step: requireInt(json, 'step'),
      completed: optBool(json, 'completed'),
      completedAt: optString(json, 'completed_at'),
    );
  }
}

class Milestone {
  const Milestone({
    required this.passageId,
    required this.totalSteps,
    required this.currentStep,
    required this.steps,
  });

  final String passageId;
  final int totalSteps;
  final int currentStep;
  final List<MilestoneStep> steps;

  bool isStepCompleted(int step) =>
      steps.any((s) => s.step == step && s.completed);

  factory Milestone.fromJson(Map<String, dynamic> json) {
    return Milestone(
      passageId: requireString(json, 'passage_id'),
      totalSteps: requireInt(json, 'total_steps'),
      currentStep: requireInt(json, 'current_step'),
      steps: modelList(json, 'steps', MilestoneStep.fromJson),
    );
  }
}
