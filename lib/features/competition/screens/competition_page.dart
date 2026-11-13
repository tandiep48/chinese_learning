/// Competition — the Learn Together shell (web `CompetitionPage`).
///
/// Owns the [CompetitionController] (socket + state machine) for the screen's
/// lifetime and dispatches to the five views by `controller.screen`. The route
/// sits behind the app's auth guard, so a signed-in user (token + id) is assumed;
/// if the token is somehow missing the page shows a sign-in prompt instead of
/// opening a socket.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/env.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/providers/auth_provider.dart';
import '../../lessons/data/lesson_repository.dart';
import '../data/competition_repository.dart';
import '../data/room_logic.dart';
import '../providers/competition_controller.dart';
import '../styles/competition_styles.dart';
import 'lobby_view.dart';
import 'ranking_view.dart';
import 'section_view.dart';
import 'setup_view.dart';
import 'waiting_view.dart';

class CompetitionPage extends ConsumerStatefulWidget {
  const CompetitionPage({super.key});

  @override
  ConsumerState<CompetitionPage> createState() => _CompetitionPageState();
}

class _CompetitionPageState extends ConsumerState<CompetitionPage> {
  CompetitionController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller != null) return;
    final token = ref.read(bearerTokenProvider);
    final user = ref.read(authNotifierProvider).asData?.value.user;
    if (token == null || token.isEmpty || user == null) return;

    final l10n = AppLocalizations.of(context);
    final lessonRepo = ref.read(lessonRepositoryProvider);
    _controller = CompetitionController(
      baseUrl: Env.apiBaseUrl,
      token: token,
      userId: user.id,
      repo: ref.read(competitionRepositoryProvider),
      fetchHskPassageIds: (key) => lessonRepo
          .getPassages(key)
          .then((list) => [for (final p in list) p.passageId]),
      labels: OptionLabels(
        lessonPrefix: l10n.competitionLessonPrefix,
        partPrefix: l10n.competitionPartPrefix,
        other: l10n.competitionOtherLabel,
      ),
      strings: CompetitionStrings(
        serverConnectFailed: l10n.competitionServerConnectFailed,
        errorFallback: l10n.competitionErrorFallback,
        couldNotCreateRoom: l10n.competitionCouldNotCreateRoom,
        selectHskLessonPart: l10n.competitionSelectHskLessonPart,
        failedLoadLessons: l10n.competitionFailedLoadLessons,
        noLessonsFound: l10n.competitionNoLessonsFound,
        noSavedBooks: l10n.competitionNoSavedBooks,
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final controller = _controller;

    return Scaffold(
      backgroundColor: BrandColors.card,
      appBar: AppBar(
        title: Text(l10n.competitionTitle),
        backgroundColor: BrandColors.background,
      ),
      body: controller == null
          ? Center(
              child: Text(l10n.loginTitle, style: CompetitionStyles.subtitle),
            )
          : SafeArea(
              child: AnimatedBuilder(
                animation: controller,
                builder: (context, _) => _body(controller, l10n),
              ),
            ),
    );
  }

  Widget _body(CompetitionController c, AppLocalizations l10n) {
    switch (c.screen) {
      case CompetitionScreen.setup:
        return CompetitionSetupView(controller: c);
      case CompetitionScreen.lobby:
        return CompetitionLobbyView(controller: c);
      case CompetitionScreen.section:
        return CompetitionSectionView(controller: c);
      case CompetitionScreen.waiting:
        return CompetitionWaitingView(controller: c);
      case CompetitionScreen.ranking:
        return CompetitionRankingView(controller: c);
    }
  }
}
