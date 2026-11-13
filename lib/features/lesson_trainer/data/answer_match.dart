/// Lesson trainer — answer normalization + matching.
///
/// Ported from `yi-chinese-manage/lib/lessons/lessonTrainer.ts`
/// (`normalizeAnswer`, `answersMatch`, `reorderMatches`), itself ported from
/// `Learning/web_app/static/lesson/lesson.js`: punctuation is optional when
/// typing and full/half-width variants are unified by stripping all CJK + ASCII
/// punctuation and every space / zero-width character. (The web's extra NFKC
/// width-folding is omitted — the answers compared here are hanzi, which NFKC
/// leaves unchanged.)
library;

final RegExp _punctuation = RegExp(
  '[、。｡，？！；：【】《》「」『』“”‘’～—–…‧·・.,?!;:\'"()\\[\\]<>~\\-]',
);
final RegExp _spaces = RegExp(r'[\s​‌‍﻿]');

String normalizeAnswer(String? value) {
  if (value == null) return '';
  return value.replaceAll(_punctuation, '').replaceAll(_spaces, '');
}

bool answersMatch(String a, String b) =>
    normalizeAnswer(a) == normalizeAnswer(b);

/// Token-by-token order check: same length and each token normalizes equal.
bool reorderMatches(List<String> userTokens, List<String> correctTokens) {
  if (userTokens.length != correctTokens.length) return false;
  for (var i = 0; i < correctTokens.length; i++) {
    if (normalizeAnswer(userTokens[i]) != normalizeAnswer(correctTokens[i])) {
      return false;
    }
  }
  return true;
}
