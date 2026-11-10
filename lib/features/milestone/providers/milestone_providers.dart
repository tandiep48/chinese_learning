/// Milestone module — provider backing the lesson-part milestone.
///
/// Auto-disposed and keyed by passage id, so each part fetches its own state and
/// a revisit refetches. Re-read after a passive step is marked (via `invalidate`)
/// so the progress markers update.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/milestone.dart';
import '../data/milestone_repository.dart';

final milestoneProvider =
    FutureProvider.autoDispose.family<Milestone, String>((ref, passageId) {
  return ref.read(milestoneRepositoryProvider).getMilestone(passageId);
});
