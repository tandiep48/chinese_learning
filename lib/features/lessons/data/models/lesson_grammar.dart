/// Lessons module — lesson-wide grammar rules for the study screen.
///
/// Ported from `LessonGrammarRule` in `yi-chinese-manage/lib/types/lesson.ts`.
/// Raw JSON from `GET /api/lesson/grammar/:passageId` → `{ grammar: [...] }`
/// (lesson-wide — every part of the lesson). The flat list is id-ordered; the UI
/// splits it into sections at each `type == 1` (section-title) row.
/// type: 1 title · 2 description · 3 example (cn~vn) · 4 table/ref · 5 dialogue.
/// `fromJson` validates (plan rule 6).
library;

import '../../../../core/api/validators.dart';

class LessonGrammarRule {
  const LessonGrammarRule({
    required this.grammarId,
    required this.type,
    this.vietnameseContent,
    this.englishContent,
    this.vnContext,
    this.enContext,
  });

  final String grammarId;
  final int type;
  final String? vietnameseContent;
  final String? englishContent;
  final List<Map<String, String>>? vnContext;
  final List<Map<String, String>>? enContext;

  factory LessonGrammarRule.fromJson(Map<String, dynamic> json) {
    return LessonGrammarRule(
      grammarId: optString(json, 'grammar_id') ?? '',
      type: optInt(json, 'type') ?? 0,
      vietnameseContent: optString(json, 'vietnamese_content'),
      englishContent: optString(json, 'english_content'),
      vnContext: _contextRows(json['vn_context']),
      enContext: _contextRows(json['en_context']),
    );
  }
}

List<Map<String, String>>? _contextRows(dynamic value) {
  if (value == null) return null;
  final list = asList(value, what: 'context');
  return list.map((e) {
    final row = asMap(e, what: 'context row');
    return {
      for (final entry in row.entries)
        entry.key: (entry.value ?? '').toString(),
    };
  }).toList();
}

/// Split the flat id-ordered list into sections, a new section beginning at each
/// `type == 1` title row (leading non-title rows form the first section).
List<List<LessonGrammarRule>> splitGrammarSections(
  List<LessonGrammarRule> rules,
) {
  final sections = <List<LessonGrammarRule>>[];
  for (final rule in rules) {
    if (rule.type == 1 || sections.isEmpty) sections.add(<LessonGrammarRule>[]);
    sections.last.add(rule);
  }
  return sections;
}
