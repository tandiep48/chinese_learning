/// Auth module — authentication state for the learner app.
///
/// Ported from `yi-chinese-manage/components/auth/AuthProvider.tsx` (its
/// mount-time session check becomes a launch-time `/api/auth/me` probe).
///
/// Phase 1 stub: exposes the [AuthStatus] contract the router's redirect guard
/// depends on, defaulting to unauthenticated. The real login/token/me wiring
/// (`AuthRepository` + `AsyncNotifier`) lands in Phase 3 and replaces this
/// provider's body without changing its public shape.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

// Read-only in Phase 1; Phase 3 replaces this with a NotifierProvider that
// drives the status from the token/me check. The router depends only on the
// AuthStatus value, so that swap needs no route changes.
final authStatusProvider =
    Provider<AuthStatus>((ref) => AuthStatus.unauthenticated);
