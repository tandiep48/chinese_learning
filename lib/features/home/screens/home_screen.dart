/// Home module — learner home (placeholder).
///
/// Phase 1 stub so the `/` route resolves. The greeting + "continue where you
/// left off" card (`GET /api/user/dashboard-current-lesson`) is built in
/// Phase 4.
library;

import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(child: Center(child: Text('Home (Phase 4)'))),
    );
  }
}
