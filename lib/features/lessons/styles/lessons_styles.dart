/// Lessons module — style values for the browse + study screens (plan rules 2
/// & 4: style values only, no widgets).
library;

import 'package:flutter/material.dart';

class LessonsStyles {
  const LessonsStyles._();

  /// Padding for the books / lessons lists and the study reader.
  static const EdgeInsets listPadding = EdgeInsets.all(16);

  /// Book cover thumbnail size in the books list.
  static const double coverWidth = 64;
  static const double coverHeight = 80;

  // ── Study reader ──────────────────────────────────────────────────────────
  /// Vertical gap between passage lines.
  static const double lineGap = 20;

  /// Gap between a line's hanzi / pinyin / meaning rows.
  static const SizedBox lineInnerGap = SizedBox(height: 6);

  /// Spacing between word tokens in a line.
  static const double tokenSpacing = 2;
  static const double tokenRunSpacing = 4;
}
