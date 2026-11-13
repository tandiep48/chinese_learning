/// Lessons module — the HSK 1 Lesson 1 pinyin guide.
///
/// Ported from `pinyin/PinyinGuideLayout.tsx`: a Basic / Advanced toggle over the
/// two charts. The **basic** chart is live (recorded audio). The **advanced**
/// initial×final matrix is TTS-only in the web (no recordings); it needs a Flutter
/// TTS plugin + native setup, so it is deferred to a follow-up and shows a
/// "coming soon" panel. Route `/pinyin`.
library;

import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../styles/lessons_styles.dart';
import '../widgets/advanced_pinyin_table.dart';
import '../widgets/basic_pinyin_table.dart';

class PinyinGuideScreen extends StatefulWidget {
  const PinyinGuideScreen({super.key});

  @override
  State<PinyinGuideScreen> createState() => _PinyinGuideScreenState();
}

class _PinyinGuideScreenState extends State<PinyinGuideScreen> {
  bool _advanced = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.pinyinTitle)),
      body: ListView(
        padding: LessonsStyles.pinyinPagePadding,
        children: [
          Center(
            child: Text(
              l10n.pinyinLessonHeading,
              style: LessonsStyles.pinyinHeading,
            ),
          ),
          LessonsStyles.gap16,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                style: LessonsStyles.pinyinToggle(!_advanced),
                onPressed: () => setState(() => _advanced = false),
                child: Text(l10n.pinyinBasic),
              ),
              const SizedBox(width: 8),
              TextButton(
                style: LessonsStyles.pinyinToggle(_advanced),
                onPressed: () => setState(() => _advanced = true),
                child: Text(l10n.pinyinAdvanced),
              ),
            ],
          ),
          LessonsStyles.gap16,
          if (_advanced)
            const AdvancedPinyinTable()
          else
            const BasicPinyinTable(),
        ],
      ),
    );
  }
}
