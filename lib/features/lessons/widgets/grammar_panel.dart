/// Lessons module — renders the lesson's grammar sections.
///
/// Ported from `grammar/GrammarPanel.tsx` (itself `grammar.js`): the flat rule
/// list is split into sections at each `type == 1` title; each row renders by
/// type — 1 title · 2 description · 3 example (cn~vn) · 4 table/ref · 5 dialogue.
/// Content is language-aware (VN on the VI locale, EN otherwise), falling back to
/// whichever the row has.
library;

import 'package:flutter/material.dart';

import '../data/models/lesson_grammar.dart';
import '../styles/lessons_styles.dart';

class GrammarPanel extends StatelessWidget {
  const GrammarPanel({super.key, required this.rules});

  final List<LessonGrammarRule> rules;

  @override
  Widget build(BuildContext context) {
    final isVi = Localizations.localeOf(context).languageCode == 'vi';
    final sections = splitGrammarSections(rules);
    return ListView.separated(
      padding: LessonsStyles.grammarPagePadding,
      itemCount: sections.length,
      separatorBuilder: (_, _) => LessonsStyles.grammarSectionGap,
      itemBuilder: (context, i) => Container(
        decoration: LessonsStyles.grammarSectionDecoration,
        padding: LessonsStyles.grammarSectionPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final rule in sections[i]) ...[
              _item(rule, isVi),
              LessonsStyles.grammarRowGap,
            ],
          ],
        ),
      ),
    );
  }

  String _content(LessonGrammarRule rule, bool isVi) {
    final primary = isVi ? rule.vietnameseContent : rule.englishContent;
    final text = (primary != null && primary.trim().isNotEmpty)
        ? primary
        : (rule.vietnameseContent ?? rule.englishContent ?? '');
    return text.trim();
  }

  List<Map<String, String>>? _contextRows(LessonGrammarRule rule, bool isVi) {
    final primary = isVi ? rule.vnContext : rule.enContext;
    return primary ?? rule.vnContext ?? rule.enContext;
  }

  Widget _item(LessonGrammarRule rule, bool isVi) {
    final text = _content(rule, isVi);
    switch (rule.type) {
      case 1:
        return Text(text, style: LessonsStyles.grammarTitleStyle);
      case 2:
        return Text(text, style: LessonsStyles.grammarDescStyle);
      case 3:
        return _cnVnBox(text);
      case 4:
        final rows = _contextRows(rule, isVi);
        if (rows != null && rows.isNotEmpty) return _table(rows);
        return Text(text, style: LessonsStyles.grammarDescStyle);
      case 5:
        return _cnVnBox(text);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _cnVnBox(String text) {
    final parts = text.split('~');
    final cn = parts.isNotEmpty ? parts[0].trim() : '';
    final vn = parts.length > 1 ? parts[1].trim() : '';
    return Container(
      width: double.infinity,
      decoration: LessonsStyles.grammarExampleDecoration,
      padding: LessonsStyles.grammarExamplePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (cn.isNotEmpty) Text(cn, style: LessonsStyles.grammarExampleCn),
          if (vn.isNotEmpty) Text(vn, style: LessonsStyles.grammarExampleVn),
        ],
      ),
    );
  }

  Widget _table(List<Map<String, String>> rows) {
    final headers = rows.first.keys.toList();
    final border = TableBorder.all(
      color: LessonsStyles.grammarTableBorder.color,
      width: LessonsStyles.grammarTableBorder.width,
    );
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 240),
        child: Table(
          border: border,
          defaultColumnWidth: const IntrinsicColumnWidth(),
          children: [
            TableRow(
              children: [
                for (final h in headers)
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(h, style: LessonsStyles.grammarTableHeader),
                  ),
              ],
            ),
            for (final row in rows)
              TableRow(
                children: [
                  for (final h in headers)
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        row[h] ?? '',
                        style: LessonsStyles.grammarTableCell,
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
