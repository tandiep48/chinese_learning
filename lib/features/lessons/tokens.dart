/// Lessons module — passage token helpers.
///
/// Punctuation tokens are shown but not tappable in the lesson reader. Mirrors
/// `PUNCT_RE` in `yi-chinese-manage/lib/lessons/tokens.ts` (itself from
/// Learning's reading.js). The ranges cover CJK symbols/punctuation
/// (U+3000–303F), fullwidth/halfwidth forms (U+FF00–FFEF), general punctuation
/// incl. curly quotes/ellipsis/em-dash (U+2000–206F), the middle dot, and ASCII
/// punctuation/brackets/whitespace.
library;

final RegExp _punctRe = RegExp(
  '^[\\u3000-\\u303F\\uFF00-\\uFFEF\\u2000-\\u206F\\u00B7()\\[\\]{}<>,.!?;:\'"/\\\\|\\s]+\$',
);

bool isPunctToken(String token) => _punctRe.hasMatch(token);
