/// Shared widget — a centered loading indicator for async sections
/// (plan rule 4.5). Cross-module, so it lives under `shared/`.
library;

import 'package:flutter/material.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({super.key, this.minHeight = 160});

  /// Minimum height so the spinner is visible inside a scroll view.
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: minHeight,
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}
