/// Shared widget — an accessible empty/error state: an icon, a title, an
/// optional message, and an optional action (plan rule 4.5). Cross-module, so
/// it lives under `shared/`.
library;

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../styles/shared_styles.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: SharedStyles.emptyPadding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: SharedStyles.emptyIconSize,
            color: BrandColors.mutedText,
          ),
          SharedStyles.emptyTitleGap,
          Text(
            title,
            style: SharedStyles.emptyTitleStyle,
            textAlign: TextAlign.center,
          ),
          if (message != null) ...[
            SharedStyles.emptyMessageGap,
            Text(
              message!,
              style: SharedStyles.emptyMessageStyle,
              textAlign: TextAlign.center,
            ),
          ],
          if (action != null) ...[
            SharedStyles.emptyActionGap,
            action!,
          ],
        ],
      ),
    );
  }
}
