/// Lesson trainer — a task the learner got wrong, for the recap table.
/// Mirrors `MissedTask` in `hooks/lesson/useLessonTrainer.ts`.
library;

import 'models/lesson_task.dart';

class MissedTask {
  const MissedTask(this.task, this.userAnswer);
  final LessonTask task;
  final String userAnswer;
}
