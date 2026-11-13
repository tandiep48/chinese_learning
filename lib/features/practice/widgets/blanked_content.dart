/// Practice module — content with its blanks rendered.
///
/// Ported from `question-types/BlankedContent.tsx`. Either interactive spans the
/// learner taps to target (type 6) or read-only display spans showing the
/// current fill (fill-in preview and the t5 sentence rows). Han text is plain.
library;

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../data/group_state.dart';
import '../data/practice_engine.dart';
import '../styles/practice_styles.dart';
import 'group_props.dart';

const String _blankPlaceholder = '　　';

class BlankedContent extends StatelessWidget {
  const BlankedContent({
    super.key,
    required this.content,
    this.interactive = false,
    this.fills,
    this.blockId,
    this.activeBlank,
    this.onBlankClick,
  });

  final String? content;
  final bool interactive;
  final List<String?>? fills; // value shown per blank index
  final String? blockId;
  final ActiveBlank? activeBlank;
  final BlankCb? onBlankClick;

  @override
  Widget build(BuildContext context) {
    final segments = tokenizeContent(content);
    final spans = <InlineSpan>[];
    for (final seg in segments) {
      if (!seg.isBlank) {
        spans.add(
          TextSpan(text: seg.text, style: PracticeStyles.paragraphStyle),
        );
        continue;
      }
      final val = (fills != null && seg.index < fills!.length)
          ? fills![seg.index]
          : null;
      final filled = val != null && val.isNotEmpty;
      if (interactive) {
        final active =
            activeBlank != null &&
            activeBlank!.blockId == blockId &&
            activeBlank!.index == seg.index;
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: GestureDetector(
              onTap: blockId == null
                  ? null
                  : () => onBlankClick?.call(blockId!, seg.index),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: active
                      ? BrandColors.studyTealLight
                      : BrandColors.secondarySurface,
                  border: Border.all(
                    color: active
                        ? BrandColors.navTeal
                        : BrandColors.neutralBorder,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  filled ? val : _blankPlaceholder,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: filled ? BrandColors.navTeal : BrandColors.mutedText,
                  ),
                ),
              ),
            ),
          ),
        );
      } else {
        spans.add(
          TextSpan(
            text: filled ? val : _blankPlaceholder,
            style: PracticeStyles.blankStyle(filled: filled, active: false),
          ),
        );
      }
    }
    return Text.rich(TextSpan(children: spans));
  }
}
