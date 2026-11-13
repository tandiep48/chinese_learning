/// Profile module — pure helpers for the practice-review panel.
///
/// Ported from `lib/review/reviewLogic.ts` (itself the DOM logic of the legacy
/// `review.js`).
library;

import 'models/review_models.dart';

/// Splits a stored answer into comparable tokens (comma, 、 or whitespace).
Set<String> answerTokens(String? raw) {
  if (raw == null) return const {};
  return {
    for (final t in raw.split(RegExp(r'[,、\s]+')))
      if (t.trim().isNotEmpty) t.trim(),
  };
}

/// A real image extension, or the `12.3` / `12.3a` id form the bank uses.
bool isImageFilename(Object? val) {
  if (val is! String) return false;
  final v = val.trim();
  return RegExp(
        r'\.(jpg|jpeg|png|gif|webp)$',
        caseSensitive: false,
      ).hasMatch(v) ||
      RegExp(r'^\d+\.\d+[a-zA-Z]*$').hasMatch(v);
}

/// The image to show: the explicit column, or the question when it is itself one.
String? questionImageFile(ReviewQuestion q) {
  if (q.image != null && q.image!.isNotEmpty) return q.image;
  if (isImageFilename(q.question)) return q.question;
  return null;
}

enum ResultFilter { all, correct, incorrect }

enum SkillFilter { all, reading, listening }

/// Filters while keeping each question's original 1-based number.
List<({ReviewQuestion question, int number})> filterReviewQuestions(
  List<ReviewQuestion> questions,
  ResultFilter result,
  SkillFilter skill,
) {
  return [
    for (var i = 0; i < questions.length; i++)
      if (!(result == ResultFilter.correct && !questions[i].isCorrect) &&
          !(result == ResultFilter.incorrect && questions[i].isCorrect) &&
          (skill == SkillFilter.all || questions[i].skill == skill.name))
        (question: questions[i], number: i + 1),
  ];
}
