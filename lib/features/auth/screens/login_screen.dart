/// Auth module — login screen (placeholder).
///
/// Phase 1 stub so the `/login` route resolves and the redirect guard has a
/// destination. The native Material sign-in form is built in Phase 3.
library;

import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(child: Center(child: Text('Login (Phase 3)'))),
    );
  }
}
