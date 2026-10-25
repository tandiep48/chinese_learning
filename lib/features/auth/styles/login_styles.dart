/// Auth module — styles for the login screen (plan rules 2 & 4: style values
/// only, no widgets, kept out of the screen file).
library;

import 'package:flutter/material.dart';

class LoginStyles {
  const LoginStyles._();

  /// Outer page padding around the centered form.
  static const EdgeInsets pagePadding = EdgeInsets.symmetric(horizontal: 24);

  /// Max width so the form stays readable on tablets/large screens (rule 4.3).
  static const double maxFormWidth = 420;

  /// Gap between stacked form elements.
  static const SizedBox fieldGap = SizedBox(height: 16);

  /// Gap below the title block.
  static const SizedBox titleGap = SizedBox(height: 32);

  /// Fixed submit-button height for a comfortable tap target.
  static const double submitHeight = 48;
}
