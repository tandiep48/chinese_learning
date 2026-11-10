/// Lessons module — the lessons within one HSK level.
///
/// Step 2 of the HSK browse flow (ported from
/// `yi-chinese-manage/app/learner/hsk/[level]/page.tsx`): a level header banner,
/// a client-side lesson search, and expandable lesson tiles whose parts deep-link
/// into lesson study. Lessons come grouped from `/api/lesson/passages?hsk_level=`
/// via [hskLessonsProvider]. Pushed over the shell with its own app bar (back
/// button). The HSK1 pinyin/number special-cases and progress bars are deferred
/// (port plan, Slices N2 / R2).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/loading_view.dart';
import '../data/hsk_grouping.dart';
import '../data/models/hsk_level.dart';
import '../data/models/picker_passage.dart';
import '../providers/lesson_providers.dart';
import '../styles/lessons_styles.dart';

class HskLessonsScreen extends ConsumerStatefulWidget {
  const HskLessonsScreen({super.key, required this.levelKey});

  final String levelKey;

  @override
  ConsumerState<HskLessonsScreen> createState() => _HskLessonsScreenState();
}

class _HskLessonsScreenState extends ConsumerState<HskLessonsScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<HskLesson> _filter(List<HskLesson> lessons) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return lessons;
    return lessons
        .where(
          (l) =>
              l.lesson.toLowerCase().contains(q) ||
              (l.title ?? '').toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final level = hskLevelByKey(widget.levelKey);

    if (level == null) {
      return Scaffold(
        backgroundColor: BrandColors.card,
        appBar: AppBar(title: Text(widget.levelKey)),
        body: SafeArea(
          child: EmptyState(
            icon: Icons.error_outline,
            title: l10n.hskNoLessons,
          ),
        ),
      );
    }

    final lessons = ref.watch(hskLessonsProvider(level.key));

    return Scaffold(
      backgroundColor: BrandColors.card,
      appBar: AppBar(title: Text(level.label)),
      body: SafeArea(
        child: lessons.when(
          loading: () => const LoadingView(),
          error: (_, _) => EmptyState(
            icon: Icons.cloud_off,
            title: l10n.bookError,
            action: FilledButton.tonal(
              onPressed: () => ref.invalidate(hskLessonsProvider(level.key)),
              child: Text(l10n.commonRetry),
            ),
          ),
          data: (all) {
            final filtered = _filter(all);
            return ListView(
              padding: LessonsStyles.hskListPadding,
              children: [
                _LevelHeader(level: level, lessonCount: all.length),
                if (all.isNotEmpty) ...[
                  LessonsStyles.hskSearchGap,
                  TextField(
                    controller: _searchController,
                    decoration: LessonsStyles.hskSearchDecoration(
                      l10n.hskSearchPlaceholder,
                    ),
                    onChanged: (v) => setState(() => _query = v),
                  ),
                ],
                LessonsStyles.hskHeaderBottomGap,
                if (widget.levelKey == 'HSK1') ...[
                  _Hsk1EntryTile(
                    icon: Icons.spellcheck,
                    label: l10n.pinyinGuideEntry,
                    route: '/pinyin',
                  ),
                  LessonsStyles.lessonListGap,
                  _Hsk1EntryTile(
                    icon: Icons.pin_outlined,
                    label: l10n.numbersEntry,
                    route: '/lesson/H1_5_99',
                  ),
                  LessonsStyles.lessonListGap,
                ],
                if (all.isEmpty)
                  Padding(
                    padding: LessonsStyles.hskEmptyPadding,
                    child: Text(
                      l10n.hskNoLessons,
                      style: LessonsStyles.hskEmptyTextStyle,
                      textAlign: TextAlign.center,
                    ),
                  )
                else if (filtered.isEmpty)
                  Padding(
                    padding: LessonsStyles.hskEmptyPadding,
                    child: Text(
                      l10n.hskNoMatch,
                      style: LessonsStyles.hskEmptyTextStyle,
                      textAlign: TextAlign.center,
                    ),
                  )
                else
                  for (var i = 0; i < filtered.length; i++) ...[
                    if (i > 0) LessonsStyles.lessonListGap,
                    _HskLessonTile(lesson: filtered[i]),
                  ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _LevelHeader extends StatelessWidget {
  const _LevelHeader({required this.level, required this.lessonCount});

  final HskLevel level;
  final int lessonCount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: LessonsStyles.hskHeaderPadding,
      decoration: LessonsStyles.hskHeaderDecoration(level.color),
      child: Row(
        children: [
          SizedBox(
            width: LessonsStyles.hskHeaderImageSize,
            height: LessonsStyles.hskHeaderImageSize,
            child: Image.network(
              hskImageUrl(level.level),
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => const Icon(
                Icons.school_outlined,
                size: LessonsStyles.hskHeaderFallbackIconSize,
                color: BrandColors.darkText,
              ),
            ),
          ),
          LessonsStyles.hskHeaderGap,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.hskSelectLessonTitle,
                  style: LessonsStyles.hskHeaderTitleStyle,
                ),
                LessonsStyles.hskHeaderTitleGap,
                Text(
                  l10n.hskLessonsAvailable(lessonCount),
                  style: LessonsStyles.hskHeaderSubtitleStyle,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Expandable lesson tile — mirrors the Book-detail lesson tile, grouped from
/// picker passages rather than a book model.
class _HskLessonTile extends StatefulWidget {
  const _HskLessonTile({required this.lesson});

  final HskLesson lesson;

  @override
  State<_HskLessonTile> createState() => _HskLessonTileState();
}

class _HskLessonTileState extends State<_HskLessonTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final lesson = widget.lesson;
    final numberLabel = lesson.isOther
        ? l10n.hskOtherPassages
        : l10n.lessonLabel(lesson.lesson);
    final hasTitle = lesson.title != null && lesson.title!.isNotEmpty;
    final heading = hasTitle ? lesson.title! : numberLabel;
    final subLabel = hasTitle ? numberLabel : null;

    return Container(
      decoration: LessonsStyles.lessonCardDecoration,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Padding(
                padding: LessonsStyles.lessonCardPadding,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            heading,
                            style: LessonsStyles.lessonCardTitleStyle,
                          ),
                          if (subLabel != null) ...[
                            LessonsStyles.lessonSubGap,
                            Text(
                              subLabel,
                              style: LessonsStyles.lessonCardSubStyle,
                            ),
                          ],
                          LessonsStyles.lessonCountGap,
                          Container(
                            padding: LessonsStyles.lessonCountBadgePadding,
                            decoration:
                                LessonsStyles.lessonCountBadgeDecoration,
                            child: Text(
                              l10n.booksPartsCount(lesson.partCount),
                              style: LessonsStyles.lessonCountBadgeStyle,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      _expanded ? Icons.expand_less : Icons.expand_more,
                      color: BrandColors.mutedText,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_expanded && lesson.parts.isNotEmpty)
            Padding(
              padding: LessonsStyles.partListPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < lesson.parts.length; i++) ...[
                    if (i > 0) LessonsStyles.partItemGap,
                    _HskPartItem(passage: lesson.parts[i]),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// HSK1-only entry card (the web's `PINYIN_PASSAGE_ID` / `NUMBER_PART_ID`
/// special cases, surfaced at the top of the HSK 1 lesson list).
class _Hsk1EntryTile extends StatelessWidget {
  const _Hsk1EntryTile({
    required this.icon,
    required this.label,
    required this.route,
  });

  final IconData icon;
  final String label;
  final String route;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: LessonsStyles.lessonCardDecoration,
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push(route),
          child: Padding(
            padding: LessonsStyles.lessonCardPadding,
            child: Row(
              children: [
                Icon(icon, color: BrandColors.navTeal),
                LessonsStyles.hskHeaderGap,
                Expanded(
                  child: Text(label, style: LessonsStyles.lessonCardTitleStyle),
                ),
                const Icon(Icons.chevron_right, color: BrandColors.mutedText),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HskPartItem extends StatelessWidget {
  const _HskPartItem({required this.passage});

  final PickerPassage passage;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final seg = passage.passageId.split('_');
    final partNum = seg.length >= 3 ? seg[2] : '1';

    return Container(
      decoration: LessonsStyles.partItemDecoration,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: LessonsStyles.partItemRadius,
          onTap: () => context.push('/lesson/${passage.passageId}'),
          child: Padding(
            padding: LessonsStyles.partItemInnerPadding,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    passage.title != null && passage.title!.isNotEmpty
                        ? passage.title!
                        : l10n.partLabel(partNum),
                    style: LessonsStyles.partItemTitleStyle,
                  ),
                ),
                const Icon(Icons.chevron_right, color: BrandColors.mutedText),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
