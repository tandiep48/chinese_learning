/// Lessons module — renders the lesson's grammar sections.
///
/// Ported from `grammar/GrammarPanel.tsx` + `grammar-panel.css`: the flat rule
/// list is split into sections at each `type == 1` title, separated by a thin
/// rule; each row renders by type — 1 centred teal title · 2 description ·
/// 3 example (mint, teal left bar) · 4 table (teal header) or reference box ·
/// 5 dialogue (pale sage, green left bar). Content is language-aware (VN on the
/// VI locale, EN otherwise), falling back to whichever the row has.
library;

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../data/models/lesson_grammar.dart';
import '../styles/lessons_styles.dart';

class GrammarPanel extends StatelessWidget {
  const GrammarPanel({super.key, required this.rules});

  final List<LessonGrammarRule> rules;

  @override
  Widget build(BuildContext context) {
    final isVi = Localizations.localeOf(context).languageCode == 'vi';
    final sections = splitGrammarSections(rules);
    return ListView.builder(
      padding: LessonsStyles.grammarPagePadding,
      itemCount: sections.length,
      itemBuilder: (context, i) {
        final last = i == sections.length - 1;
        return Container(
          margin: EdgeInsets.only(bottom: last ? 0 : 18),
          padding: EdgeInsets.only(bottom: last ? 0 : 16),
          decoration: last ? null : LessonsStyles.grammarSectionRule,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [for (final rule in sections[i]) _item(rule, isVi)],
          ),
        );
      },
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
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.only(bottom: 6),
          decoration: LessonsStyles.grammarTitleRule,
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: LessonsStyles.grammarTitleStyle,
          ),
        );
      case 2:
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(text, style: LessonsStyles.grammarDescStyle),
        );
      case 3:
        return _cnVnBox(
          text,
          bar: BrandColors.navTeal,
          fill: BrandColors.background,
          cnStyle: LessonsStyles.grammarExampleCn,
          vnStyle: LessonsStyles.grammarExampleVn,
          padding: const EdgeInsets.all(12),
        );
      case 4:
        final rows = _contextRows(rule, isVi);
        if (rows != null && rows.isNotEmpty) return _table(rows);
        return Container(
          margin: const EdgeInsets.only(top: 10, bottom: 15),
          padding: const EdgeInsets.all(10),
          decoration: LessonsStyles.grammarTableRef,
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: LessonsStyles.grammarTableRefText,
          ),
        );
      case 5:
        return _cnVnBox(
          text,
          bar: LessonsStyles.grammarDialogueBar,
          fill: LessonsStyles.grammarDialogueFill,
          cnStyle: LessonsStyles.grammarDialogueCn,
          vnStyle: LessonsStyles.grammarExampleVn,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _cnVnBox(
    String text, {
    required Color bar,
    required Color fill,
    required TextStyle cnStyle,
    required TextStyle vnStyle,
    required EdgeInsets padding,
  }) {
    final parts = text.split('~');
    final cn = parts.isNotEmpty ? parts[0].trim() : '';
    final vn = parts.length > 1 ? parts[1].trim() : '';
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: ColoredBox(
          color: fill,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(width: 3, color: bar),
                Expanded(
                  child: Padding(
                    padding: padding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (cn.isNotEmpty) Text(cn, style: cnStyle),
                        if (cn.isNotEmpty && vn.isNotEmpty)
                          const SizedBox(height: 4),
                        if (vn.isNotEmpty) Text(vn, style: vnStyle),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _table(List<Map<String, String>> rows) {
    final headers = rows.first.keys.toList();
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 15),
      decoration: LessonsStyles.grammarTableBox,
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Table(
          defaultColumnWidth: const IntrinsicColumnWidth(),
          border: const TableBorder(
            horizontalInside: BorderSide(color: Color(0x0F576856)),
          ),
          children: [
            TableRow(
              decoration: const BoxDecoration(color: BrandColors.navTeal),
              children: [
                for (final h in headers)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 12,
                    ),
                    child: Text(h, style: LessonsStyles.grammarTableHeader),
                  ),
              ],
            ),
            for (final row in rows)
              TableRow(
                children: [
                  for (final h in headers)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 12,
                      ),
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
