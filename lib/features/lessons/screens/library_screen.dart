/// Lessons module — the Library: the HSK | Books browse hub.
///
/// A shell route (`/library`, reached from the nav drawer) that ports the web
/// learning tab bar (`components/page/learner/picker/LearningTabs.tsx`,
/// `learning-tabs.css`): HSK, Books, Practice and Exam (the web's order). The surrounding Scaffold
/// + app bar + drawer come from `AppShell`, so this is body-only.
library;

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../practice/widgets/exam_levels_view.dart';
import '../../practice/widgets/practice_levels_view.dart';
import '../styles/lessons_styles.dart';
import '../widgets/books_view.dart';
import '../widgets/hsk_levels_view.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DefaultTabController(
      length: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DecoratedBox(
            decoration: LessonsStyles.libraryTabBarDecoration,
            child: TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelColor: BrandColors.primary,
              unselectedLabelColor: BrandColors.mutedText,
              indicatorColor: BrandColors.primary,
              labelPadding: const EdgeInsets.symmetric(horizontal: 20),
              labelStyle: LessonsStyles.libraryTabLabelStyle,
              unselectedLabelStyle: LessonsStyles.libraryTabLabelStyle,
              tabs: [
                Tab(text: l10n.libraryTabHsk),
                Tab(text: l10n.navBooks),
                Tab(text: l10n.libraryTabPractice),
                Tab(text: l10n.dashboardExam),
              ],
            ),
          ),
          const Expanded(
            child: TabBarView(
              children: [
                HskLevelsView(),
                BooksView(),
                PracticeLevelsView(),
                ExamLevelsView(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
