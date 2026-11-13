/// Shared widget — a simple placeholder block for skeleton loading states
/// (plan rule 4.5). No animation/dependency; a muted rounded box.
library;

import 'package:flutter/material.dart';

import '../styles/shared_styles.dart';

class SkeletonBox extends StatelessWidget {
  const SkeletonBox({super.key, this.width, this.height = 16, this.radius = 8});

  final double? width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: SharedStyles.skeletonDecoration(radius),
    );
  }
}
