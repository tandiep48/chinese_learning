/// Practice module — pure logic for the practice/exam engine.
///
/// Ported 1:1 from `yi-chinese-manage/lib/practice/practiceEngine.ts` (itself
/// extracted from the legacy `practice_engine.js`). No widgets, no state — the
/// runner and group-state hold those; this file only classifies, tokenizes and
/// scores. Keeping it pure keeps it unit-testable and shared by every layout.
library;

import 'models/practice_answer_row.dart';
import 'models/practice_question.dart';

// ── Answer normalisation / comparison ──────────────────────────────────────
/// Compare chosen vs. correct case-insensitively, trimmed.
String normalizeAnswer(dynamic value) =>
    (value ?? '').toString().trim().toUpperCase();

bool answersMatch(dynamic chosen, dynamic correct) =>
    normalizeAnswer(chosen) == normalizeAnswer(correct);

// ── Option-value inspection ────────────────────────────────────────────────
final RegExp _imageExtRe = RegExp(
  r'\.(jpg|jpeg|png|gif|webp)$',
  caseSensitive: false,
);
final RegExp _imageIdRe = RegExp(r'^\d+\.\d+[a-zA-Z]*$');

/// A filename ("a.jpg") or a numeric asset id ("3.12b").
bool isImageFilename(dynamic val) {
  if (val is! String) return false;
  final v = val.trim();
  return _imageExtRe.hasMatch(v) || _imageIdRe.hasMatch(v);
}

bool allOptionsAreImages(Map<String, dynamic>? options) {
  final vals = (options ?? const {}).values;
  if (vals.isEmpty) return false;
  return vals.every((v) => isImageFilename(v.toString()));
}

// ── Blank detection / tokenisation ─────────────────────────────────────────
final RegExp _blankTestRe = RegExp(r'[（(][\s\d]*[）)][\s_]*_*|[（(]\s*[）)]');
final RegExp _blankSplitRe = RegExp(r'[（(][\s\d]*[）)][\s_]*_+|[（(]\s*[）)]');

bool hasBlank(String? content) {
  if (content == null || content.isEmpty) return false;
  return _blankTestRe.hasMatch(content);
}

/// An ordered piece of tokenized content: literal [text], or a numbered [blank].
class ContentSegment {
  const ContentSegment.text(this.text) : index = -1, isBlank = false;
  const ContentSegment.blank(this.index) : text = '', isBlank = true;

  final String text;
  final int index;
  final bool isBlank;
}

/// Split content into ordered text/blank segments so blanks can be rendered as
/// interactive nodes.
List<ContentSegment> tokenizeContent(String? content) {
  final segments = <ContentSegment>[];
  if (content == null || content.isEmpty) return segments;
  var lastIndex = 0;
  var blankIndex = 0;
  for (final m in _blankSplitRe.allMatches(content)) {
    if (m.start > lastIndex) {
      segments.add(ContentSegment.text(content.substring(lastIndex, m.start)));
    }
    segments.add(ContentSegment.blank(blankIndex++));
    lastIndex = m.end;
  }
  if (lastIndex < content.length) {
    segments.add(ContentSegment.text(content.substring(lastIndex)));
  }
  return segments;
}

/// Count blanks in a piece of content (type-6 fill validation).
int countBlanks(String? content) =>
    tokenizeContent(content).where((s) => s.isBlank).length;

// ── Group / question layout classification ─────────────────────────────────
enum GroupLayout {
  type2,
  t5Listening,
  t5ReadingMatch,
  t5ReadingImage,
  type6Group,
  single,
}

GroupLayout classifyGroupLayout(PracticeGroup group) {
  final q0 = group.questions.isEmpty ? null : group.questions.first;
  final skill = q0?.skill ?? 'listening';
  final type = q0?.type;
  final isListening = skill == 'listening';
  final multi = group.questions.length > 1;

  if (type == 2) return GroupLayout.type2;
  if (type == 5 && isListening && multi) return GroupLayout.t5Listening;
  if (type == 5 && !isListening && multi) {
    return allOptionsAreImages(q0?.options)
        ? GroupLayout.t5ReadingImage
        : GroupLayout.t5ReadingMatch;
  }
  if (type == 6) return GroupLayout.type6Group;
  return GroupLayout.single;
}

enum QuestionKind {
  tf, // type 1
  images, // type 3 or 5 with image options
  mcReading, // type 3 non-image
  reorder, // type 4
  blankMc, // type 5 fill-in-blank
  match, // type 5 text-match
  type6Single,
}

QuestionKind classifyQuestion(PracticeQuestion q) {
  final type = q.type;
  final allImg = allOptionsAreImages(q.options);
  if (type == 1) return QuestionKind.tf;
  if (type == 3) return allImg ? QuestionKind.images : QuestionKind.mcReading;
  if (type == 4) return QuestionKind.reorder;
  if (type == 5) {
    if (allImg) return QuestionKind.images;
    if (hasBlank(q.content)) return QuestionKind.blankMc;
    return QuestionKind.match;
  }
  return QuestionKind.type6Single;
}

// ── Scoring ─────────────────────────────────────────────────────────────────
class GroupScore {
  const GroupScore({
    required this.correct,
    required this.total,
    required this.perQuestion,
  });

  final int correct;
  final int total;
  final List<bool> perQuestion; // is-correct per sub-question, in order
}

/// [userAnswers] is keyed by blockId `q-<idx>`.
GroupScore scoreGroup(PracticeGroup group, Map<String, String> userAnswers) {
  var correct = 0;
  final perQuestion = <bool>[];
  for (var idx = 0; idx < group.questions.length; idx++) {
    final ok = answersMatch(userAnswers['q-$idx'], group.questions[idx].answer);
    if (ok) correct++;
    perQuestion.add(ok);
  }
  return GroupScore(
    correct: correct,
    total: group.questions.length,
    perQuestion: perQuestion,
  );
}

/// Build the `/api/practice/submit` rows for one checked group.
List<PracticeAnswerRow> buildAnswerRows(
  PracticeGroup group,
  Map<String, String> userAnswers,
  int perQuestionTimeMs,
  PracticeCategory defaultCategory,
) {
  final rows = <PracticeAnswerRow>[];
  for (var idx = 0; idx < group.questions.length; idx++) {
    final q = group.questions[idx];
    final chosen = normalizeAnswer(userAnswers['q-$idx']);
    rows.add(
      PracticeAnswerRow(
        hskLevel: q.level,
        lesson: q.lesson,
        questionNo: q.no,
        skill: q.skill.isEmpty ? 'listening' : q.skill,
        type: q.type,
        category: q.category ?? defaultCategory,
        userAnswer: chosen,
        isCorrect: answersMatch(chosen, q.answer),
        responseTimeMs: perQuestionTimeMs,
      ),
    );
  }
  return rows;
}

// ── Navigation helpers (operate on the checked[] flags) ─────────────────────
int firstUncheckedAfter(List<bool> checked, int idx) {
  for (var i = idx + 1; i < checked.length; i++) {
    if (!checked[i]) return i;
  }
  return -1;
}

bool allChecked(List<bool> checked) =>
    checked.isNotEmpty && checked.every((c) => c);

// ── Result screen tier ──────────────────────────────────────────────────────
/// Result tier by score fraction; the recap maps this to an icon (the web
/// returned FontAwesome class names in `resultIcon`).
enum ResultTier { trophy, check, chart, retry }

ResultTier resultTier(double pct) {
  if (pct >= 0.9) return ResultTier.trophy;
  if (pct >= 0.7) return ResultTier.check;
  if (pct >= 0.5) return ResultTier.chart;
  return ResultTier.retry;
}
