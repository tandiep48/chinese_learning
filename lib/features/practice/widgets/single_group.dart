/// Practice module — the default group layout.
///
/// Ported from `question-types/SingleGroup.tsx`: each question renders
/// standalone, with the widget chosen per question by [classifyQuestion].
library;

import 'package:flutter/material.dart';

import '../../../core/media/gcs.dart';
import '../../../core/theme/app_theme.dart';
import '../data/group_state.dart';
import '../data/models/practice_question.dart';
import '../data/practice_engine.dart';
import '../styles/practice_styles.dart';
import 'blanked_content.dart';
import 'feedback.dart';
import 'group_props.dart';
import 'option_widgets.dart';
import 'practice_audio.dart';
import 'reorder_chips.dart';

class SingleGroup extends StatelessWidget {
  const SingleGroup({
    super.key,
    required this.group,
    required this.state,
    required this.category,
    required this.cb,
  });

  final PracticeGroup group;
  final GroupUIState state;
  final PracticeCategory category;
  final GroupCallbacks cb;

  @override
  Widget build(BuildContext context) {
    final multi = group.questions.length > 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var idx = 0; idx < group.questions.length; idx++)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _block(idx, multi),
          ),
      ],
    );
  }

  Widget _block(int idx, bool multi) {
    final q = group.questions[idx];
    final blockId = 'q-$idx';
    final kind = classifyQuestion(q);
    final skill = q.skill.isEmpty ? 'listening' : q.skill;
    final blockCorrect = state.checked
        ? answersMatch(state.userAnswers[blockId], q.answer)
        : null;
    final chosen = normalizeAnswer(state.userAnswers[blockId]);

    return Container(
      decoration: PracticeStyles.questionBlockDecoration(correct: blockCorrect),
      padding: PracticeStyles.blockPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (multi) QNum(n: idx + 1),
          if (skill == 'listening' && q.audioKeys.isNotEmpty) ...[
            AudioControl(
              audioKey: q.audioKeys.first,
              level: q.level,
              category: category,
            ),
            PracticeStyles.gap12,
          ],
          ..._bodyFor(kind, q, blockId, skill, chosen),
          AnswerFeedback(
            q: q,
            chosen: state.userAnswers[blockId] ?? '',
            checked: state.checked,
            reorder: kind == QuestionKind.reorder,
          ),
        ],
      ),
    );
  }

  List<Widget> _bodyFor(
    QuestionKind kind,
    PracticeQuestion q,
    String blockId,
    String skill,
    String chosen,
  ) {
    switch (kind) {
      case QuestionKind.tf:
        final imgFile =
            q.image ?? (isImageFilename(q.question) ? q.question : null);
        final hasAudio = q.audioKeys.isNotEmpty;
        final showContent = skill == 'reading' || !hasAudio;
        return [
          if (imgFile != null) ...[
            _image(q.level, imgFile),
            PracticeStyles.gap12,
          ],
          if (showContent &&
              q.content != null &&
              !isImageFilename(q.content)) ...[
            _paragraph(q.content!),
            PracticeStyles.gap12,
          ],
          if (q.question != null && !isImageFilename(q.question)) ...[
            _paragraph(q.question!, center: true),
            PracticeStyles.gap12,
          ],
          TrueFalse(
            q: q,
            blockId: blockId,
            state: state,
            onSelect: cb.onSelectMC,
          ),
        ];
      case QuestionKind.images:
        return [
          if (skill == 'reading' && q.content != null) ...[
            _paragraph(q.content!, center: true),
            PracticeStyles.gap12,
          ],
          ImageOptions(
            q: q,
            blockId: blockId,
            state: state,
            onSelect: cb.onSelectMC,
            category: category,
          ),
        ];
      case QuestionKind.mcReading:
        return [
          if (skill != 'listening' && q.content != null) ...[
            _paragraph(q.content!),
            PracticeStyles.gap12,
          ],
          if (q.question != null) ...[
            _paragraph(q.question!, center: true),
            PracticeStyles.gap12,
          ],
          MCOptions(
            q: q,
            blockId: blockId,
            state: state,
            onSelect: cb.onSelectMC,
          ),
        ];
      case QuestionKind.reorder:
        return [
          ReorderChips(
            q: q,
            blockId: blockId,
            state: state,
            onToggle: cb.onToggleChip,
          ),
        ];
      case QuestionKind.blankMc:
        final sel = state.userAnswers[blockId];
        final fill = (chosen.isNotEmpty && sel != null)
            ? (q.options[sel]?.toString() ?? '')
            : null;
        return [
          _centered(BlankedContent(content: q.content, fills: [fill])),
          PracticeStyles.gap12,
          MCOptions(
            q: q,
            blockId: blockId,
            state: state,
            onSelect: cb.onSelectMC,
          ),
        ];
      case QuestionKind.match:
        return [
          if (q.content != null) ...[
            _paragraph(q.content!, center: true),
            PracticeStyles.gap12,
          ],
          MCOptions(
            q: q,
            blockId: blockId,
            state: state,
            onSelect: cb.onSelectMC,
          ),
        ];
      case QuestionKind.type6Single:
        return [
          if (q.content != null) ...[
            _paragraph(q.content!),
            PracticeStyles.gap12,
          ],
          MCOptions(
            q: q,
            blockId: blockId,
            state: state,
            onSelect: cb.onSelectMC,
          ),
        ];
    }
  }

  Widget _paragraph(String text, {bool center = false}) => Text(
    text,
    textAlign: center ? TextAlign.center : TextAlign.start,
    style: PracticeStyles.paragraphStyle,
  );

  Widget _centered(Widget child) =>
      Align(alignment: Alignment.center, child: child);

  Widget _image(int level, String filename) => ClipRRect(
    borderRadius: BorderRadius.circular(10),
    child: Image.network(
      practiceImageUrl(level, filename, category.wire),
      errorBuilder: (_, _, _) => const SizedBox(
        height: 80,
        child: ColoredBox(
          color: BrandColors.coverPlaceholderBg,
          child: Icon(
            Icons.image_not_supported_outlined,
            color: BrandColors.mutedText,
          ),
        ),
      ),
    ),
  );
}
