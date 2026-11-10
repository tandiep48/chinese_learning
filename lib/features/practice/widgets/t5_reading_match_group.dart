/// Practice module — the type-5 reading match/image group layout.
///
/// Ported from `question-types/T5ReadingMatchGroup.tsx`. Two variants share this
/// layout and differ only in what the shared pool shows: pictures ([imageMode])
/// or lettered sentences. Rows are sentences (text mode rows may carry a blank),
/// each matched to one option key from the shared pool.
library;

import 'package:flutter/material.dart';

import '../../../core/media/gcs.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../data/group_state.dart';
import '../data/models/practice_question.dart';
import '../data/practice_engine.dart';
import '../styles/practice_styles.dart';
import 'blanked_content.dart';
import 'feedback.dart';
import 'group_props.dart';
import 'option_widgets.dart';

class T5ReadingMatchGroup extends StatelessWidget {
  const T5ReadingMatchGroup({
    super.key,
    required this.group,
    required this.state,
    required this.category,
    required this.cb,
    required this.imageMode,
  });

  final PracticeGroup group;
  final GroupUIState state;
  final PracticeCategory category;
  final GroupCallbacks cb;
  final bool imageMode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final q0 = group.questions.first;
    final opts = q0.options;
    final optKeys = opts.keys.toList();
    var correctCount = 0;
    for (var i = 0; i < group.questions.length; i++) {
      if (answersMatch(state.userAnswers['q-$i'], group.questions[i].answer)) {
        correctCount++;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (imageMode) ...[
          _imagesRow(q0.level, opts),
          PracticeStyles.gap8,
          Text(
            l10n.practiceChooseImagePerSentence,
            style: PracticeStyles.instructionStyle,
          ),
        ] else ...[
          _optionsBox(opts),
          PracticeStyles.gap8,
          Text(
            l10n.practiceChooseAnswerPerSentence,
            style: PracticeStyles.instructionStyle,
          ),
        ],
        PracticeStyles.gap12,
        for (var idx = 0; idx < group.questions.length; idx++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _row(idx, optKeys),
          ),
        GroupFeedback(
          correctCount: correctCount,
          total: group.questions.length,
          checked: state.checked,
        ),
      ],
    );
  }

  Widget _optionsBox(Map<String, dynamic> opts) {
    return Container(
      decoration: PracticeStyles.chipTrayDecoration,
      padding: PracticeStyles.chipTrayPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final e in opts.entries)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${e.key}.', style: PracticeStyles.optionKeyStyle),
                  PracticeStyles.wGap8,
                  Expanded(
                    child: Text(
                      e.value.toString(),
                      style: PracticeStyles.optionTextStyle,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _imagesRow(int level, Map<String, dynamic> opts) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        for (final e in opts.entries)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 96,
                  height: 96,
                  child: Image.network(
                    practiceImageUrl(level, e.value.toString(), category.wire),
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const ColoredBox(
                      color: BrandColors.coverPlaceholderBg,
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        color: BrandColors.mutedText,
                      ),
                    ),
                  ),
                ),
              ),
              PracticeStyles.gap8,
              Text(e.key, style: PracticeStyles.imageLabelStyle),
            ],
          ),
      ],
    );
  }

  Widget _row(int idx, List<String> optKeys) {
    final q = group.questions[idx];
    final blockId = 'q-$idx';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _rowNumber(idx + 1),
            PracticeStyles.wGap8,
            Expanded(
              child: imageMode
                  ? Text(q.content ?? '', style: PracticeStyles.paragraphStyle)
                  : BlankedContent(content: q.content),
            ),
          ],
        ),
        PracticeStyles.gap8,
        KeyButtons(
          q: q,
          blockId: blockId,
          optKeys: optKeys,
          state: state,
          onSelectKey: cb.onSelectKey,
        ),
      ],
    );
  }

  Widget _rowNumber(int n) => Container(
    width: 28,
    height: 28,
    alignment: Alignment.center,
    decoration: const BoxDecoration(
      color: BrandColors.secondarySurface,
      shape: BoxShape.circle,
    ),
    child: Text(
      '$n',
      style: const TextStyle(
        fontWeight: FontWeight.w700,
        color: BrandColors.bodyText,
      ),
    ),
  );
}
