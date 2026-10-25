/// Lessons module — books list (placeholder).
///
/// Phase 1 stub so the `/books` route resolves. The real list (`GET
/// /api/lesson/books`) with skeleton loading and empty state is built in
/// Phase 5.
library;

import 'package:flutter/material.dart';

class BooksScreen extends StatelessWidget {
  const BooksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(child: Center(child: Text('Books (Phase 5)'))),
    );
  }
}
