/// Practice module — post-check feedback lines.
///
/// Ported from `question-types/Feedback.tsx` (`QNum`, `Feedback`,
/// `GroupFeedback`). Derived from state, so a "check" simply rebuilds these with
/// the answer revealed.
library;

import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../data/models/practice_question.dart';
import '../data/practice_engine.dart';
import '../styles/practice_styles.dart';

/// The "Question N" label shown above a block in a multi-question group.
class QNum extends StatelessWidget {
  const QNum({super.key, required this.n});

  final int n;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        l10n.practiceQuestionNumber(n),
        style: PracticeStyles.qnumStyle,
      ),
    );
  }
}

/// Per-question result line. (Named `AnswerFeedback` to avoid clashing with
/// Flutter's `Feedback` haptics helper.)
class AnswerFeedback extends StatelessWidget {
  const AnswerFeedback({
    super.key,
    required this.q,
    required this.chosen,
    required this.checked,
    this.reorder = false,
  });

  final PracticeQuestion q;
  final String chosen;
  final bool checked;
  final bool reorder;

  @override
  Widget build(BuildContext context) {
    if (!checked) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    final correct = normalizeAnswer(q.answer);
    final isCorrect = normalizeAnswer(chosen) == correct;
    final String text;
    if (isCorrect) {
      text = l10n.practiceCorrectExclaim;
    } else if (reorder) {
      text = l10n.practiceCorrectOrder(correct);
    } else {
      text = l10n.practiceCorrectAnswerColon(correct);
    }
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(text, style: PracticeStyles.feedbackStyle(isCorrect)),
    );
  }
}

/// Whole-group score line, used by the t5 layouts graded per row.
class GroupFeedback extends StatelessWidget {
  const GroupFeedback({
    super.key,
    required this.correctCount,
    required this.total,
    required this.checked,
  });

  final int correctCount;
  final int total;
  final bool checked;

  @override
  Widget build(BuildContext context) {
    if (!checked) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        l10n.practiceScoreCorrect(correctCount, total),
        style: PracticeStyles.feedbackStyle(correctCount == total),
      ),
    );
  }
}
