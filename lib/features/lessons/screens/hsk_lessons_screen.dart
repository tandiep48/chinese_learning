/// Lessons module — the lessons within one HSK level.
///
/// Step 2 of the web's three-step flow (levels → lessons → parts), ported from
/// `yi-chinese-manage/app/learner/hsk/[level]/page.tsx`: a back link, the level
/// banner, a client-side lesson search, and lesson cards (cover image, title,
/// progress bars, part count) that open the part picker (`/hsk/:level/:lesson`).
/// HSK1 lesson 1 is the pinyin guide and opens it directly. Lessons come grouped
/// from `/api/lesson/passages?hsk_level=` via [hskLessonsProvider]; progress from
/// [hskPickerProgressProvider].
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
import '../data/models/picker_progress.dart';
import '../providers/lesson_providers.dart';
import '../styles/lessons_styles.dart';
import '../widgets/picker_header.dart';
import '../widgets/picker_progress.dart';

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
    final progress =
        ref.watch(hskPickerProgressProvider(level.key)).asData?.value ??
        PickerProgressSummary.empty;

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
                PickerBackLink(
                  label: l10n.pickerBackToLevels,
                  onTap: () => context.go('/library'),
                ),
                LessonsStyles.pickerToolbarGap,
                PickerHeader(
                  color: level.color,
                  imageUrl: hskImageUrl(level.level),
                  title: l10n.hskSelectLessonTitle,
                  subtitle: l10n.hskLessonsAvailable(all.length),
                ),
                LessonsStyles.pickerHeaderBottomGap,
                if (all.isNotEmpty) ...[
                  TextField(
                    controller: _searchController,
                    decoration: LessonsStyles.pickerSearchDecoration(
                      l10n.hskSearchPlaceholder,
                    ),
                    onChanged: (v) => setState(() => _query = v),
                  ),
                  LessonsStyles.lessonListGap,
                ],
                if (all.isEmpty)
                  _Message(l10n.hskNoLessons)
                else if (filtered.isEmpty)
                  _Message(l10n.hskNoMatch)
                else
                  for (var i = 0; i < filtered.length; i++) ...[
                    if (i > 0) LessonsStyles.lessonListGap,
                    _LessonCard(
                      level: level,
                      lesson: filtered[i],
                      progress:
                          progress.lessons[filtered[i].lesson] ??
                          PickerProgress.empty,
                    ),
                  ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: LessonsStyles.hskEmptyPadding,
      child: Text(
        text,
        style: LessonsStyles.hskEmptyTextStyle,
        textAlign: TextAlign.center,
      ),
    );
  }
}

/// `.lesson-card`: cover column + body (title, lesson label, progress, count).
class _LessonCard extends StatelessWidget {
  const _LessonCard({
    required this.level,
    required this.lesson,
    required this.progress,
  });

  final HskLevel level;
  final HskLesson lesson;
  final PickerProgress progress;

  bool get _isPinyinLesson => level.key == 'HSK1' && lesson.lesson == '1';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final numberLabel = lesson.isOther
        ? l10n.hskOtherPassages
        : l10n.lessonLabel(lesson.lesson);
    final hasTitle = lesson.title != null && lesson.title!.isNotEmpty;

    return Container(
      decoration: LessonsStyles.lessonCardDecoration,
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push(
            _isPinyinLesson ? '/pinyin' : '/hsk/${level.key}/${lesson.lesson}',
          ),
          child: LayoutBuilder(
            builder: (context, box) => IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Cover(
                    width: LessonsStyles.lessonImageWidth(box.maxWidth),
                    url: lessonImageUrl(level.key, lesson.lesson),
                  ),
                  Expanded(
                    child: Padding(
                      padding: LessonsStyles.lessonBodyPadding,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hasTitle ? lesson.title! : numberLabel,
                            style: LessonsStyles.lessonCardTitleStyle,
                          ),
                          if (hasTitle) ...[
                            LessonsStyles.lessonBodyGap,
                            Text(
                              numberLabel,
                              style: LessonsStyles.lessonPreviewStyle,
                            ),
                          ],
                          LessonsStyles.lessonBodyGap,
                          PickerProgressLines(progress: progress),
                          LessonsStyles.lessonBodyGap,
                          Container(
                            padding: LessonsStyles.lessonCountBadgePadding,
                            decoration:
                                LessonsStyles.lessonCountBadgeDecoration,
                            child: Text(
                              _isPinyinLesson
                                  ? l10n.pickerPinyinGuide
                                  : l10n.booksPartsCount(lesson.partCount),
                              style: LessonsStyles.lessonCountBadgeStyle,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// `.lesson-card-img-wrap`: the cover, collapsing to nothing when it is missing
/// (pinyin / Other have none).
class _Cover extends StatefulWidget {
  const _Cover({required this.width, required this.url});

  final double width;
  final String url;

  @override
  State<_Cover> createState() => _CoverState();
}

class _CoverState extends State<_Cover> {
  bool _failed = false;

  @override
  Widget build(BuildContext context) {
    if (_failed) return const SizedBox.shrink();
    return Container(
      width: widget.width,
      color: BrandColors.sageSubtleBg,
      child: Image.network(
        widget.url,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _failed = true);
          });
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
