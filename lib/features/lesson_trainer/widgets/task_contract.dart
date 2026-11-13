/// Lesson trainer — the shared task callback contract.
///
/// Each task widget reports one resolution (answered or skipped) with the typed
/// answer, correctness, and response time, then advances when the learner taps
/// Next. Mirrors `onResolved` / `onAdvance` in `useLessonTaskFlow`.
library;

typedef TaskResolved = void Function(
  String userAnswer,
  bool isCorrect,
  bool skipped,
  int responseMs,
);
