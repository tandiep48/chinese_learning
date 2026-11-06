/// Auth module — styles for the login screen (plan rules 2 & 4: style values
/// only, no widgets, kept out of the screen file).
///
/// Ported from `yi-chinese-manage/app/learner/login/page.tsx`.
library;

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class LoginStyles {
  const LoginStyles._();

  /// Outer page padding (`p-6` = 24px).
  static const EdgeInsets pagePadding = EdgeInsets.all(24);

  /// Max card width (`max-w-sm` = 384px).
  static const double maxCardWidth = 384;

  /// Inner card padding (`p-8` = 32px).
  static const EdgeInsets cardPadding = EdgeInsets.all(32);

  /// White login card (`rounded-2xl border border-black/5 bg-white shadow-[0_8px_32px_rgba(0,0,0,0.06)]`).
  static final BoxDecoration cardDecoration = BoxDecoration(
    color: BrandColors.card,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: BrandColors.learnerBorder),
    boxShadow: const [
      BoxShadow(
        color: Color(0x0F000000),
        blurRadius: 32,
        offset: Offset(0, 8),
      ),
    ],
  );

  /// Heading (`text-2xl font-extrabold text-[var(--learner-text)]`).
  static const TextStyle headingStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    color: BrandColors.bodyText,
  );

  /// Field label (`text-sm font-semibold text-[var(--learner-text)]`).
  static const TextStyle labelStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: BrandColors.bodyText,
  );

  /// Input text (`text-[15px] text-[var(--learner-text)]`).
  static const TextStyle inputTextStyle = TextStyle(
    fontSize: 15,
    color: BrandColors.bodyText,
  );

  /// Input decoration (`rounded-lg border border-black/10 bg-white px-3 py-2.5`).
  static InputDecoration inputDecoration() {
    final borderRadius = BorderRadius.circular(8);
    return InputDecoration(
      filled: true,
      fillColor: BrandColors.card,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: const BorderSide(color: BrandColors.neutralBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: const BorderSide(color: BrandColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: const BorderSide(color: BrandColors.danger),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: const BorderSide(color: BrandColors.danger, width: 1.5),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: const BorderSide(color: BrandColors.neutralBorder),
      ),
    );
  }

  /// Inline error box (`rounded-lg border border-red-200 bg-red-50 px-3 py-2`).
  static final BoxDecoration errorBoxDecoration = BoxDecoration(
    color: BrandColors.dangerSurface,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: BrandColors.dangerBorder),
  );

  static const EdgeInsets errorBoxPadding = EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 8,
  );

  static const TextStyle errorTextStyle = TextStyle(
    fontSize: 14,
    color: BrandColors.dangerText,
  );

  /// Spacing constants (`mb-6`, `space-y-4`, `mb-1.5`).
  static const SizedBox headingGap = SizedBox(height: 24);
  static const SizedBox fieldGap = SizedBox(height: 16);
  static const SizedBox labelGap = SizedBox(height: 6);

  /// Submit button style (`Button variant="primary" size="md"`).
  static const double submitHeight = 44;
  static const double spinnerSize = 20;

  static final ButtonStyle submitButtonStyle = FilledButton.styleFrom(
    backgroundColor: BrandColors.primary,
    foregroundColor: BrandColors.card,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    textStyle: const TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w700,
    ),
  );
}
