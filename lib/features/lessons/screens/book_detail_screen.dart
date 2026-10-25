/// Lessons module — book detail / lesson picker (placeholder).
///
/// Phase 1 stub so the `/books/:code` route resolves. The lessons/parts list
/// (`GET /api/lesson/book/:code`) is built in Phase 5.
library;

import 'package:flutter/material.dart';

class BookDetailScreen extends StatelessWidget {
  const BookDetailScreen({super.key, required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: Center(child: Text('Book $code (Phase 5)'))),
    );
  }
}
