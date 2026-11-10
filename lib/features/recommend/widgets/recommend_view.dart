/// Recommend module — the dashboard's Recommend tab body.
///
/// Ported from `recommend/RecommendPage.tsx` (embedded): loads
/// `/api/practice/recommend`, shows the recommendation cards, and launches a
/// card as a practice session in the P2 runner (`multi` mode, one queued item).
/// The web filter bar + multi-select batch + pagination are deferred; mobile
/// starts a single group per tap.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../practice/data/models/practice_question.dart';
import '../../practice/data/practice_repository.dart';
import '../../practice/screens/practice_runner_page.dart';
import '../data/models/recommended_practice.dart';
import '../data/recommend_repository.dart';
import '../styles/recommend_styles.dart';
import 'recommend_card.dart';

enum _Status { loading, ready, empty, newUser, error }

class RecommendView extends ConsumerStatefulWidget {
  const RecommendView({super.key});

  @override
  ConsumerState<RecommendView> createState() => _RecommendViewState();
}

class _RecommendViewState extends ConsumerState<RecommendView> {
  _Status _status = _Status.loading;
  List<RecommendedPractice> _recs = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _status = _Status.loading);
    final repo = ref.read(recommendRepositoryProvider);
    try {
      final recs = await repo.getRecommendations();
      if (!mounted) return;
      if (recs.isEmpty) {
        final hasHistory = await repo.getHasHistory();
        if (!mounted) return;
        setState(() {
          _recs = const [];
          _status = hasHistory ? _Status.empty : _Status.newUser;
        });
        return;
      }
      setState(() {
        _recs = recs;
        _status = _Status.ready;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _status = _Status.error);
    }
  }

  Future<void> _start(RecommendedPractice rec) async {
    final category = rec.category == 'exam'
        ? PracticeCategory.exam
        : PracticeCategory.practice;
    final item = PracticeMultiItem(
      level: rec.level,
      lesson: '${rec.lesson}',
      progress: rec.progress,
      category: category,
    );
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => PracticeRunnerPage(
          options: PracticeOptions(
            category: category,
            multi: true,
            items: [item],
            onExit: () => Navigator.of(ctx).pop(),
          ),
        ),
      ),
    );
    // Finishing a run changes what is recommended — refresh on return.
    if (mounted) _load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (_status) {
      case _Status.loading:
        return _stateBox(
          icon: Icons.hourglass_empty,
          title: l10n.recommendFinding,
          sub: l10n.recommendAnalysing,
          spinner: true,
        );
      case _Status.error:
        return _stateBox(
          icon: Icons.warning_amber_rounded,
          title: l10n.recommendErrorTitle,
          sub: l10n.recommendConnectFailed,
          retry: true,
        );
      case _Status.empty:
        return _stateBox(
          icon: Icons.school_outlined,
          title: l10n.recommendEmptyTitle,
          sub: l10n.recommendEmptySub,
        );
      case _Status.newUser:
        return _stateBox(
          icon: Icons.eco_outlined,
          title: l10n.recommendNewUserTitle,
          sub: l10n.recommendNewUserSub,
        );
      case _Status.ready:
        return ListView.separated(
          padding: RecommendStyles.pagePadding,
          itemCount: _recs.length + 1,
          separatorBuilder: (_, _) => RecommendStyles.gap12,
          itemBuilder: (context, i) {
            if (i == 0) {
              return Text(
                l10n.recommendGroupsFound(_recs.length),
                style: RecommendStyles.resultsCount,
              );
            }
            final rec = _recs[i - 1];
            return RecommendCard(rec: rec, onStart: () => _start(rec));
          },
        );
    }
  }

  Widget _stateBox({
    required IconData icon,
    required String title,
    required String sub,
    bool spinner = false,
    bool retry = false,
  }) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (spinner)
              const CircularProgressIndicator()
            else
              Icon(icon, size: 48, color: BrandColors.mutedText),
            RecommendStyles.gap12,
            Text(
              title,
              style: RecommendStyles.stateTitle,
              textAlign: TextAlign.center,
            ),
            RecommendStyles.gap8,
            Text(
              sub,
              style: RecommendStyles.stateSub,
              textAlign: TextAlign.center,
            ),
            if (retry) ...[
              RecommendStyles.gap12,
              FilledButton.tonal(
                onPressed: _load,
                child: Text(l10n.commonRetry),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
