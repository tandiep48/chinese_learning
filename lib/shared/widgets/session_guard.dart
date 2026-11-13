/// Shared — the mid-session guard for the learner dashboard.
///
/// Ported from `HomeShell.tsx` (`learner-home-guard`) and `LearnerSidebar.tsx`
/// (`nav.leave_session_*`): while a graded trainer runs in a dashboard tab,
/// switching tabs or using the navigation asks "Session in progress" first.
/// [activityRunningProvider] is armed by the lesson flow and read by the home tab
/// bar and the nav drawer.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';

class ActivityRunning extends Notifier<bool> {
  @override
  bool build() => false;

  // Called from post-frame callbacks and disposal, never during a build.
  void set(bool running) => state = running;
}

/// True while a graded trainer step runs inside the dashboard.
final activityRunningProvider = NotifierProvider<ActivityRunning, bool>(
  ActivityRunning.new,
);

/// Asks whether to abandon the running session. [forTabSwitch] picks the
/// web's tab-switch wording over the navigation wording. Resolves true on leave.
Future<bool> confirmLeaveSession(
  BuildContext context, {
  required bool forTabSwitch,
}) async {
  final l10n = AppLocalizations.of(context);
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l10n.guardTitle),
      content: Text(forTabSwitch ? l10n.guardBodyTab : l10n.guardBodyNav),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text(l10n.guardStay),
        ),
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text(forTabSwitch ? l10n.guardLeaveTab : l10n.guardLeaveNav),
        ),
      ],
    ),
  );
  return result ?? false;
}
