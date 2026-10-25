/// Lessons module — lesson study (placeholder).
///
/// Phase 1 stub so the `/lesson/:passageId` route resolves. The passage reader
/// (hanzi / pinyin / translation lines + word popups, `GET
/// /api/lesson/passage/:id`) is the Phase 5 proof slice.
library;

import 'package:flutter/material.dart';

class LessonStudyScreen extends StatelessWidget {
  const LessonStudyScreen({super.key, required this.passageId});

  final String passageId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: Center(child: Text('Lesson $passageId (Phase 5)'))),
    );
  }
}
