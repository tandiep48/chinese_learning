/// Lesson trainer — the centered instruction row (icon + text) shared by the
/// task widgets (the `.instruction` block in the web task components).
library;

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../styles/lesson_trainer_styles.dart';

class TaskInstruction extends StatelessWidget {
  const TaskInstruction({super.key, required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon,
            size: LessonTrainerStyles.instructionIconSize,
            color: BrandColors.primary),
        LessonTrainerStyles.instructionIconGap,
        Flexible(
          child: Text(text,
              textAlign: TextAlign.center,
              style: LessonTrainerStyles.instructionStyle),
        ),
      ],
    );
  }
}
