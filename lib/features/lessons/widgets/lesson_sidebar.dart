/// Lessons module — the lesson-study sidebar, as a bottom sheet.
///
/// Ported from `LessonSidebar.tsx` (its phone drawer form): the lesson's parts
/// with mini progress stats (jump to any part), a whole-lesson Exam entry (HSK
/// only) and direct Grammar / Translation buttons. The current part / phase is
/// highlighted. The lesson flow supplies the callbacks so every jump happens in
/// place.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/loading_view.dart';
import '../data/lesson_flow_logic.dart';
import '../data/lesson_repository.dart';
import '../data/models/picker_progress.dart';
import '../providers/lesson_providers.dart';
import '../../vocab/widgets/train_type_picker.dart' show TrainerEngine;
import 'lesson_exam.dart';
import 'picker_progress.dart';

/// The flow phase the sidebar highlights.
enum SidebarDomain { lesson, grammar, translation }

class SidebarPart {
  const SidebarPart({
    required this.passageId,
    required this.partNum,
    required this.isNumber,
    this.title,
    this.progress,
  });

  final String passageId;
  final String partNum;
  final bool isNumber;
  final String? title;
  final PickerProgress? progress;
}

class SidebarData {
  const SidebarData({
    required this.badge,
    required this.lessonNum,
    required this.isBook,
    required this.parts,
    this.lessonProgress,
  });

  final String badge;
  final String lessonNum;
  final bool isBook;
  final List<SidebarPart> parts;
  final PickerProgress? lessonProgress;
}

String _partNum(String passageId) {
  final seg = passageId.split('_');
  return seg.length > 2 ? seg[2] : '1';
}

/// Parts of the lesson a passage belongs to (HSK picker endpoints with
/// progress, or the book detail without).
final lessonSidebarProvider = FutureProvider.autoDispose
    .family<SidebarData, String>((ref, passageId) async {
      final lessonNum = lessonOfPassageId(passageId);
      if (isBookPassageId(passageId)) {
        final code = passageId.split('_').first;
        final book = await ref.watch(learnerBookProvider(code).future);
        final lesson = book.lessons.where((l) => l.lesson == lessonNum);
        final parts = <LearnerBookPartLike>[
          if (lesson.isNotEmpty)
            for (final p in lesson.first.parts)
              LearnerBookPartLike(p.part, p.passageId),
        ];
        parts.sort(
          (a, b) =>
              (int.tryParse(a.part) ?? 0).compareTo(int.tryParse(b.part) ?? 0),
        );
        return SidebarData(
          badge: code,
          lessonNum: lessonNum,
          isBook: true,
          parts: [
            for (final p in parts)
              SidebarPart(
                passageId: p.passageId,
                partNum: p.part,
                isNumber: false,
              ),
          ],
        );
      }

      final level = hskLevelKeyFromPassageId(passageId);
      final lessons = await ref.watch(hskLessonsProvider(level).future);
      final progress = await ref
          .read(lessonRepositoryProvider)
          .getPickerProgress(level);
      final current = lessons.where((l) => l.lesson == lessonNum);
      return SidebarData(
        badge: level,
        lessonNum: lessonNum,
        isBook: false,
        lessonProgress: progress.lessons[lessonNum],
        parts: [
          if (current.isNotEmpty)
            for (final p in current.first.parts)
              SidebarPart(
                passageId: p.passageId,
                partNum: p.passageId == 'H1_5_99' ? '' : _partNum(p.passageId),
                isNumber: p.passageId == 'H1_5_99',
                title: p.title,
                progress: progress.parts[p.passageId],
              ),
        ],
      );
    });

/// A (part number, passage id) pair, so book parts sort without the model type.
class LearnerBookPartLike {
  LearnerBookPartLike(this.part, this.passageId);

  final String part;
  final String passageId;
}

/// Opens the sidebar sheet for the lesson containing [passageId].
Future<void> showLessonSidebar(
  BuildContext context, {
  required String passageId,
  required SidebarDomain domain,
  required ValueChanged<String> onSelectPart,
  required ValueChanged<SidebarDomain> onSelectDomain,
  required ValueChanged<TrainerEngineChoice> onStartMaster,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: BrandColors.card,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      builder: (ctx, controller) => _SidebarBody(
        scrollController: controller,
        passageId: passageId,
        domain: domain,
        onSelectPart: (id) {
          Navigator.of(ctx).pop();
          onSelectPart(id);
        },
        onSelectDomain: (d) {
          Navigator.of(ctx).pop();
          onSelectDomain(d);
        },
        onStartMaster: (e) {
          Navigator.of(ctx).pop();
          onStartMaster(e);
        },
      ),
    ),
  );
}

/// The Exam entry's engine pick, mapped for the lesson flow.
enum TrainerEngineChoice { vocab, lesson }

class _SidebarBody extends ConsumerWidget {
  const _SidebarBody({
    required this.scrollController,
    required this.passageId,
    required this.domain,
    required this.onSelectPart,
    required this.onSelectDomain,
    required this.onStartMaster,
  });

  final ScrollController scrollController;
  final String passageId;
  final SidebarDomain domain;
  final ValueChanged<String> onSelectPart;
  final ValueChanged<SidebarDomain> onSelectDomain;
  final ValueChanged<TrainerEngineChoice> onStartMaster;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final data = ref.watch(lessonSidebarProvider(passageId));
    final info = data.asData?.value;

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            IconButton(
              tooltip: l10n.sidebarPartSelection,
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                final seg = passageId.split('_');
                final lesson = seg.length > 1 ? seg[1] : '';
                Navigator.of(context).pop();
                context.push(
                  isBookPassageId(passageId)
                      ? '/books/${Uri.encodeComponent(seg.first)}/${Uri.encodeComponent(lesson)}'
                      : '/hsk/${hskLevelKeyFromPassageId(passageId)}/${Uri.encodeComponent(lesson)}',
                );
              },
            ),
            if (info != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: BrandColors.studyTealLight,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  info.badge,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: BrandColors.navTeal,
                  ),
                ),
              ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                info == null ? '' : l10n.lessonLabel(info.lessonNum),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: BrandColors.darkText,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _SectionTitle(
          icon: Icons.menu_book_outlined,
          label: l10n.sidebarLessonParts,
        ),
        if (data.isLoading)
          const Padding(padding: EdgeInsets.all(16), child: LoadingView())
        else if (info == null)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(l10n.sidebarFailedParts),
          )
        else if (info.parts.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(l10n.sidebarNoParts),
          )
        else
          for (final p in info.parts)
            _PartTile(
              part: p,
              active:
                  domain == SidebarDomain.lesson && p.passageId == passageId,
              onTap: () => onSelectPart(p.passageId),
            ),
        if (info != null && !info.isBook)
          _ActionTile(
            icon: Icons.school_outlined,
            label: l10n.pickerExam,
            active: false,
            below: info.lessonProgress == null
                ? null
                : PickerProgressLines(progress: info.lessonProgress!),
            onTap: () async {
              final engine = await showExamEngineChooser(context);
              if (engine == null) return;
              onStartMaster(
                engine == TrainerEngine.vocab
                    ? TrainerEngineChoice.vocab
                    : TrainerEngineChoice.lesson,
              );
            },
          ),
        _ActionTile(
          icon: Icons.font_download_outlined,
          label: l10n.grammarTitle,
          active: domain == SidebarDomain.grammar,
          onTap: () => onSelectDomain(SidebarDomain.grammar),
        ),
        _ActionTile(
          icon: Icons.translate,
          label: l10n.translationTitle,
          active: domain == SidebarDomain.translation,
          onTap: () => onSelectDomain(SidebarDomain.translation),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: BrandColors.navTeal),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: BrandColors.studyText,
            ),
          ),
        ],
      ),
    );
  }
}

class _PartTile extends StatelessWidget {
  const _PartTile({
    required this.part,
    required this.active,
    required this.onTap,
  });

  final SidebarPart part;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final label = (part.title != null && part.title!.isNotEmpty)
        ? part.title!
        : (part.isNumber
              ? l10n.pickerNumberPart
              : l10n.partLabel(part.partNum));
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: active ? BrandColors.studyTealLight : BrandColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: active ? BrandColors.navTeal : BrandColors.neutralBorder,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: active
                      ? BrandColors.navTeal
                      : BrandColors.studyTealLight,
                  child: Text(
                    part.isNumber ? '#' : part.partNum,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: active ? Colors.white : BrandColors.navTeal,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: BrandColors.studyText,
                        ),
                      ),
                      if (part.progress != null) ...[
                        const SizedBox(height: 6),
                        PickerProgressLines(progress: part.progress!),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
    this.below,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  final Widget? below;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 4),
      child: Material(
        color: active ? BrandColors.studyTealLight : BrandColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: active ? BrandColors.navTeal : BrandColors.neutralBorder,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 20, color: BrandColors.navTeal),
                    const SizedBox(width: 10),
                    Text(
                      label,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: BrandColors.studyText,
                      ),
                    ),
                  ],
                ),
                if (below != null) ...[const SizedBox(height: 6), below!],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
