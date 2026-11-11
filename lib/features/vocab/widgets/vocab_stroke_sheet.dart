/// Vocab module — the stroke-order bottom sheet for a word.
///
/// Ported from `VocabStrokeModal`: opens the P1 native [StrokeOrderView] for the
/// tapped word's characters in a bottom sheet.
library;

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../lessons/widgets/stroke_order_view.dart';

Future<void> showVocabStrokeSheet(BuildContext context, String word) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: BrandColors.card,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.75,
          ),
          child: StrokeOrderView(word: word),
        ),
      ),
    ),
  );
}
