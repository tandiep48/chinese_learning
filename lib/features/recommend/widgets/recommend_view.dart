/// Recommend module — the dashboard's Recommend tab body.
///
/// Ported from `recommend/RecommendPage.tsx` (embedded): loads
/// `/api/practice/recommend`, a filter bar (level / skill / category / status),
/// the selectable recommendation cards, a numbered pager (10 per page) and the
/// sticky "N items selected · Start Selected" bar, which queues the selected
/// groups into one practice session in the P2 runner (`multi` mode).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../practice/data/models/practice_question.dart';
import '../../practice/data/practice_repository.dart';
import '../../practice/screens/practice_runner_page.dart';
import '../data/models/recommended_practice.dart';
import '../data/recommend_logic.dart';
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
  String _level = 'all';
  String _skill = 'all';
  String _category = 'all';
  String _statusFilter = 'all';
  int _page = 1;
  final Map<String, RecommendedPractice> _selected = {};

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

  void _setFilter({
    String? level,
    String? skill,
    String? category,
    String? status,
  }) {
    setState(() {
      _level = level ?? _level;
      _skill = skill ?? _skill;
      _category = category ?? _category;
      _statusFilter = status ?? _statusFilter;
      _page = 1;
    });
  }

  void _toggle(RecommendedPractice rec) {
    final key = recommendationKey(rec);
    setState(() {
      if (_selected.remove(key) == null) _selected[key] = rec;
    });
  }

  PracticeCategory _categoryOf(RecommendedPractice r) =>
      r.category == 'exam' ? PracticeCategory.exam : PracticeCategory.practice;

  Future<void> _startSelected() async {
    final recs = _selected.values.toList();
    if (recs.isEmpty) return;
    final items = [
      for (final r in recs)
        PracticeMultiItem(
          level: r.level,
          lesson: '${r.lesson}',
          progress: r.progress,
          category: _categoryOf(r),
        ),
    ];
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => PracticeRunnerPage(
          options: PracticeOptions(
            category: _categoryOf(recs.first),
            multi: true,
            items: items,
            onExit: () => Navigator.of(ctx).pop(),
          ),
        ),
      ),
    );
    // Finishing a run changes what is recommended — refresh on return.
    if (!mounted) return;
    setState(_selected.clear);
    _load();
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
          cta: FilledButton.icon(
            onPressed: () => context.push('/vocab'),
            icon: const Icon(Icons.menu_book_outlined, size: 18),
            label: Text(l10n.recommendNewUserCta),
          ),
        );
      case _Status.ready:
        return _ready(l10n);
    }
  }

  Widget _ready(AppLocalizations l10n) {
    final filtered = filterRecommendations(
      _recs,
      level: _level,
      skill: _skill,
      category: _category,
      status: _statusFilter,
    );
    final pages = totalPages(filtered.length);
    final page = _page.clamp(1, pages);
    final start = (page - 1) * recommendPageSize;
    final slice = filtered.skip(start).take(recommendPageSize).toList();

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: RecommendStyles.pagePadding,
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 10,
                children: [
                  _Filter(
                    label: l10n.reviewLevel,
                    value: _level,
                    items: {
                      'all': l10n.reviewAllLevels,
                      for (var n = 1; n <= 6; n++) '$n': 'HSK $n',
                    },
                    onChanged: (v) => _setFilter(level: v),
                  ),
                  _Filter(
                    label: l10n.reviewSkill,
                    value: _skill,
                    items: {
                      'all': l10n.recommendAllSkills,
                      'listening': l10n.reviewListening,
                      'reading': l10n.reviewReading,
                    },
                    onChanged: (v) => _setFilter(skill: v),
                  ),
                  _Filter(
                    label: l10n.reviewCategory,
                    value: _category,
                    items: {
                      'all': l10n.reviewAllCategories,
                      'practice': l10n.dashboardExercise,
                      'exam': l10n.dashboardExam,
                    },
                    onChanged: (v) => _setFilter(category: v),
                  ),
                  _Filter(
                    label: l10n.recommendStatus,
                    value: _statusFilter,
                    items: {
                      'all': l10n.recommendAllStatuses,
                      'Not start': l10n.recommendStatusNotStart,
                      'Finish and success': l10n.recommendStatusFinishSuccess,
                      'Finish and fail': l10n.recommendStatusFinishFail,
                    },
                    onChanged: (v) => _setFilter(status: v),
                  ),
                ],
              ),
              RecommendStyles.gap12,
              if (filtered.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.school_outlined,
                        size: 44,
                        color: BrandColors.mutedText,
                      ),
                      RecommendStyles.gap12,
                      Text(
                        l10n.recommendEmptyTitle,
                        style: RecommendStyles.stateTitle,
                      ),
                    ],
                  ),
                )
              else ...[
                Text(
                  l10n.recommendGroupsFound(filtered.length),
                  style: RecommendStyles.resultsCount,
                ),
                RecommendStyles.gap12,
                for (final rec in slice) ...[
                  RecommendCard(
                    rec: rec,
                    selected: _selected.containsKey(recommendationKey(rec)),
                    onToggle: () => _toggle(rec),
                  ),
                  const SizedBox(height: 20),
                ],
                if (pages > 1) _pager(page, pages, filtered.length),
              ],
            ],
          ),
        ),
        if (_selected.isNotEmpty)
          Container(
            color: RecommendStyles.selectBarBg,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.recommendItemsSelected(_selected.length),
                      style: RecommendStyles.selectBarText,
                    ),
                  ),
                  FilledButton.icon(
                    style: RecommendStyles.startButton,
                    onPressed: _startSelected,
                    icon: const Icon(Icons.play_arrow, size: 18),
                    label: Text(l10n.recommendStartSelected),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _pager(int page, int pages, int total) {
    final end = (page * recommendPageSize).clamp(0, total);
    final start = (page - 1) * recommendPageSize + 1;
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 6,
      runSpacing: 6,
      children: [
        OutlinedButton(
          style: RecommendStyles.pageButton,
          onPressed: page == 1 ? null : () => setState(() => _page = page - 1),
          child: const Icon(Icons.chevron_left, size: 18),
        ),
        for (final n in pageNumbers(page, pages))
          if (n == null)
            const SizedBox(width: 28, child: Center(child: Text('…')))
          else if (n == page)
            FilledButton(
              style: RecommendStyles.pageButtonActive,
              onPressed: null,
              child: Text('$n'),
            )
          else
            OutlinedButton(
              style: RecommendStyles.pageButton,
              onPressed: () => setState(() => _page = n),
              child: Text('$n'),
            ),
        OutlinedButton(
          style: RecommendStyles.pageButton,
          onPressed: page == pages
              ? null
              : () => setState(() => _page = page + 1),
          child: const Icon(Icons.chevron_right, size: 18),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Text('$start–$end / $total', style: RecommendStyles.skillText),
        ),
      ],
    );
  }

  Widget _stateBox({
    required IconData icon,
    required String title,
    required String sub,
    bool spinner = false,
    bool retry = false,
    Widget? cta,
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
            if (cta != null) ...[RecommendStyles.gap12, cta],
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

class _Filter extends StatelessWidget {
  const _Filter({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String value;
  final Map<String, String> items;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: RecommendStyles.filterLabel),
        const SizedBox(height: 4),
        DropdownButton<String>(
          value: value,
          isDense: true,
          items: [
            for (final e in items.entries)
              DropdownMenuItem(value: e.key, child: Text(e.value)),
          ],
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ],
    );
  }
}
