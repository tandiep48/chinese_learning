/// Lessons module — the coloured banner atop the lesson and part pickers.
///
/// Ported from `.picker-header-section` (`lesson-picker.css`): a cover image
/// column beside a centred title + subtitle, stacking vertically at ≤700px, with
/// a graduation-cap tile when the cover fails to load (or no tile at all for
/// book covers, which the web hides on error).
library;

import 'package:flutter/material.dart';

import '../styles/lessons_styles.dart';

class PickerHeader extends StatelessWidget {
  const PickerHeader({
    super.key,
    required this.color,
    required this.title,
    this.imageUrl,
    this.subtitle,
    this.hideImageOnError = false,
  });

  final Color color;
  final String title;

  /// Cover image; null renders the text column only (book part page).
  final String? imageUrl;
  final String? subtitle;

  /// Show nothing instead of the graduation-cap tile when the cover fails.
  final bool hideImageOnError;

  @override
  Widget build(BuildContext context) {
    final stacks = LessonsStyles.headerStacks(MediaQuery.sizeOf(context).width);
    final url = imageUrl;

    final image = url == null
        ? null
        : ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: LessonsStyles.pickerHeaderImageWidth,
              maxHeight: LessonsStyles.pickerHeaderImageMaxHeight,
            ),
            child: Image.network(
              url,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => hideImageOnError
                  ? const SizedBox.shrink()
                  : const SizedBox(
                      height: 150,
                      child: Center(
                        child: Icon(
                          Icons.school_outlined,
                          size: 56,
                          color: Color(0x73111827),
                        ),
                      ),
                    ),
            ),
          );

    final text = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: LessonsStyles.pickerHeaderTitleStyle,
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(
            subtitle!,
            textAlign: TextAlign.center,
            style: LessonsStyles.pickerHeaderSubtitleStyle,
          ),
        ],
      ],
    );

    return Container(
      width: double.infinity,
      padding: stacks
          ? const EdgeInsets.all(20)
          : LessonsStyles.pickerHeaderPadding,
      decoration: LessonsStyles.hskHeaderDecoration(color),
      child: image == null
          ? text
          : stacks
          ? Column(
              children: [
                image,
                const SizedBox(height: LessonsStyles.pickerHeaderGapSize),
                text,
              ],
            )
          : Row(
              children: [
                SizedBox(
                  width: LessonsStyles.pickerHeaderImageWidth,
                  child: Center(child: image),
                ),
                const SizedBox(width: LessonsStyles.pickerHeaderGapSize),
                Expanded(child: text),
              ],
            ),
    );
  }
}

/// `.picker-back-button`: "← Back to …" text link above the header.
class PickerBackLink extends StatelessWidget {
  const PickerBackLink({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text('← $label', style: LessonsStyles.pickerBackStyle),
        ),
      ),
    );
  }
}
