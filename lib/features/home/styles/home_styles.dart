/// Home module — style values for the home screen (plan rules 2 & 4: no
/// widgets, no inline styles in the UI files).
library;

import 'package:flutter/material.dart';

class HomeStyles {
  const HomeStyles._();

  /// Scroll-body padding.
  static const EdgeInsets pagePadding = EdgeInsets.all(16);

  /// Gap between sections (greeting → card → books entry).
  static const SizedBox sectionGap = SizedBox(height: 20);

  /// Inner padding of the continue / books cards.
  static const EdgeInsets cardPadding = EdgeInsets.all(16);
}
