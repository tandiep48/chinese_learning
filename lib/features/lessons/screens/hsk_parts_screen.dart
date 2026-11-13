/// Lessons module — pick a part of one HSK lesson.
///
/// Step 3 of the web's flow, ported from `app/learner/hsk/[level]/[lesson]/page.tsx`:
/// a back link, the lesson-coloured banner (lesson cover), a row per part with
/// its progress bars, then the lesson-wide Grammar and Translation entries. A
/// part opens the milestone runner (`/lesson/:passageId`) and is recorded as the
/// most recent lesson for the home Continue panel. Route `/hsk/:level/:lesson`.
///
/// The Exam entry opens the engine chooser and runs a lesson-wide trainer.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/loading_view.dart';
import '../data/hsk_grouping.dart';
import '../data/lesson_colors.dart';
import '../data/models/hsk_level.dart';
import '../data/models/picker_passage.dart';
import '../data/models/picker_progress.dart';
import '../data/lesson_repository.dart';
import '../providers/lesson_providers.dart';
import '../styles/lessons_styles.dart';
import '../widgets/lesson_exam.dart';
import '../widgets/picker_header.dart';
import '../widgets/picker_progress.dart';

const String _numberPartId = 'H1_5_99';

class HskPartsScreen extends ConsumerWidget {
  const HskPartsScreen({
    super.key,
    required this.levelKey,
    required this.lesson,
  });

  final String levelKey;
  final String lesson;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final level = hskLevelByKey(levelKey);

    if (level == null) {
      return Scaffold(
        backgroundColor: BrandColors.card,
        appBar: AppBar(title: Text(levelKey)),
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
    final lessonLabel = lesson == 'Other'
        ? l10n.hskOtherPassages
        : l10n.lessonLabel(lesson);

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
            final matches = all.where((l) => l.lesson == lesson);
            final current = matches.isEmpty ? null : matches.first;
            return ListView(
              padding: LessonsStyles.hskListPadding,
              children: [
                PickerBackLink(
                  label: l10n.pickerBackToLessons,
                  onTap: () => context.go('/hsk/${level.key}'),
                ),
                LessonsStyles.pickerToolbarGap,
                PickerHeader(
                  color: lessonColor(level.key, lesson) ?? level.color,
                  imageUrl: lessonImageUrl(level.key, lesson),
                  title: l10n.pickerSelectPart,
                  subtitle: '${level.label} — $lessonLabel',
                ),
                LessonsStyles.pickerHeaderBottomGap,
                if (current == null)
                  Padding(
                    padding: LessonsStyles.hskEmptyPadding,
                    child: Text(
                      l10n.hskNoLessons,
                      style: LessonsStyles.hskEmptyTextStyle,
                      textAlign: TextAlign.center,
                    ),
                  )
                else
                  ..._rows(context, ref, l10n, current, progress),
              ],
            );
          },
        ),
      ),
    );
  }

  List<Widget> _rows(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    HskLesson current,
    PickerProgressSummary progress,
  ) {
    final rows = <Widget>[];
    void add(Widget w) {
      if (rows.isNotEmpty) rows.add(LessonsStyles.partRowGap);
      rows.add(w);
    }

    for (final p in current.parts) {
      add(
        _PartRow(
          title: _partLabel(l10n, p),
          progress: progress.parts[p.passageId],
          onTap: () {
            ref.read(lessonRepositoryProvider).saveRecentLearning(p.passageId);
            context.push('/lesson/${p.passageId}');
          },
        ),
      );
    }

    // Exam — one whole-lesson entry between the parts and Grammar / Translation.
    add(
      _PartRow(
        title: l10n.pickerExam,
        progress: progress.lessons[current.lesson],
        onTap: current.parts.isEmpty
            ? null
            : () => startLessonExam(context, [
                for (final p in current.parts) p.passageId,
              ]),
      ),
    );

    if (current.parts.isNotEmpty) {
      final first = current.parts.first.passageId;
      add(
        _PartRow(
          title: l10n.pickerGrammar,
          onTap: () => context.push('/grammar/$first'),
        ),
      );
      add(
        _PartRow(
          title: l10n.pickerTranslation,
          onTap: () => context.push('/translation/$first'),
        ),
      );
    }
    return rows;
  }

  String _partLabel(AppLocalizations l10n, PickerPassage p) {
    if (p.title != null && p.title!.isNotEmpty) return p.title!;
    if (p.passageId == _numberPartId) return l10n.pickerNumberPart;
    final seg = p.passageId.split('_');
    return l10n.partLabel(seg.length >= 3 ? seg[2] : '1');
  }
}

/// `.part-list-item`: bordered row; title above the progress bars on phones.
class _PartRow extends StatelessWidget {
  const _PartRow({required this.title, required this.onTap, this.progress});

  final String title;
  final PickerProgress? progress;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: LessonsStyles.partItemDecoration,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: LessonsStyles.partItemRadius,
          onTap: onTap,
          child: Padding(
            padding: LessonsStyles.partRowPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(title, style: LessonsStyles.partItemTitleStyle),
                if (progress != null) ...[
                  LessonsStyles.partRowInnerGap,
                  PickerProgressLines(progress: progress!),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
