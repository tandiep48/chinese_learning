/// Review module — the saved-word review tab body.
///
/// Ported from `vocab-review/VocabReviewPage.tsx` (embedded): a watch-only word
/// browser with two tabs — **Recent learn word** (`/api/vocab/review-recent/query`)
/// and **Review word** (`/api/vocab/review/query`) — 50 words per page (≤ 2 pages).
/// Study tools kept for mobile: reveal pinyin / meaning toggles and per-word
/// audio. Stroke order is deferred (its viewer lives in the lessons module).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/audio/audio_player.dart';
import '../../../core/media/gcs.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/data/vocab_row.dart';
import '../data/review_repository.dart';
import '../styles/review_styles.dart';

enum _Source { recent, review }

enum _Status { loading, ready, error }

class ReviewView extends ConsumerStatefulWidget {
  const ReviewView({super.key});

  @override
  ConsumerState<ReviewView> createState() => _ReviewViewState();
}

class _ReviewViewState extends ConsumerState<ReviewView> {
  _Source _source = _Source.recent;
  _Status _status = _Status.loading;
  List<VocabRow> _rows = const [];
  int _page = 1;
  int _totalPages = 1;
  int _total = 0;
  bool _showPinyin = true;
  bool _showMeaning = true;

  @override
  void initState() {
    super.initState();
    _load(1);
  }

  Future<void> _load(int page) async {
    setState(() => _status = _Status.loading);
    final repo = ref.read(reviewRepositoryProvider);
    try {
      final result = _source == _Source.recent
          ? await repo.getRecentList(page, reviewPageSize)
          : await repo.getReviewList(page, reviewPageSize);
      if (!mounted) return;
      setState(() {
        _rows = result.rows;
        _page = result.page;
        _totalPages = result.totalPages;
        _total = result.total;
        _status = _Status.ready;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _status = _Status.error);
    }
  }

  void _setSource(_Source source) {
    if (source == _source) return;
    setState(() => _source = source);
    _load(1);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ready = _status == _Status.ready && _rows.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: ReviewStyles.pagePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(l10n.reviewHeading, style: ReviewStyles.heading),
                  if (ready) ...[
                    const SizedBox(width: 8),
                    Container(
                      decoration: ReviewStyles.countPill,
                      padding: ReviewStyles.countPillPadding,
                      child: Text('$_total', style: ReviewStyles.countPillText),
                    ),
                  ],
                ],
              ),
              ReviewStyles.gap8,
              Text(
                _source == _Source.recent
                    ? l10n.reviewSubtitleRecent
                    : l10n.reviewSubtitleReview,
                style: ReviewStyles.subtitle,
              ),
              ReviewStyles.gap12,
              _tabs(l10n),
              if (ready) ...[ReviewStyles.gap12, _revealToggles(l10n)],
            ],
          ),
        ),
        Expanded(child: _content(l10n)),
        if (ready && _totalPages > 1) _pager(l10n),
      ],
    );
  }

  Widget _tabs(AppLocalizations l10n) {
    return Row(
      children: [
        TextButton(
          style: ReviewStyles.tabStyle(_source == _Source.recent),
          onPressed: () => _setSource(_Source.recent),
          child: Text(l10n.reviewTabRecent),
        ),
        const SizedBox(width: 8),
        TextButton(
          style: ReviewStyles.tabStyle(_source == _Source.review),
          onPressed: () => _setSource(_Source.review),
          child: Text(l10n.reviewTabReview),
        ),
      ],
    );
  }

  Widget _revealToggles(AppLocalizations l10n) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        OutlinedButton.icon(
          style: ReviewStyles.revealStyle(_showPinyin),
          onPressed: () => setState(() => _showPinyin = !_showPinyin),
          icon: Icon(
            _showPinyin
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            size: 16,
          ),
          label: Text(
            _showPinyin ? l10n.studyHidePinyin : l10n.studyShowPinyin,
          ),
        ),
        OutlinedButton.icon(
          style: ReviewStyles.revealStyle(_showMeaning),
          onPressed: () => setState(() => _showMeaning = !_showMeaning),
          icon: Icon(
            _showMeaning
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            size: 16,
          ),
          label: Text(
            _showMeaning ? l10n.studyHideMeaning : l10n.studyShowMeaning,
          ),
        ),
        OutlinedButton.icon(
          style: ReviewStyles.revealStyle(true),
          onPressed: () => setState(() => _rows = [..._rows]..shuffle()),
          icon: const Icon(Icons.shuffle, size: 16),
          label: Text(l10n.wordSummaryShuffle),
        ),
      ],
    );
  }

  Widget _content(AppLocalizations l10n) {
    if (_status == _Status.loading) {
      return _stateMessage(l10n.reviewLoading);
    }
    if (_status == _Status.error) {
      return _stateMessage(l10n.reviewLoadFailed);
    }
    if (_rows.isEmpty) {
      return _stateMessage(
        _source == _Source.recent
            ? l10n.reviewEmptyRecent
            : l10n.reviewEmptyReview,
      );
    }
    final isVi = Localizations.localeOf(context).languageCode == 'vi';
    return ListView.separated(
      padding: ReviewStyles.pagePadding,
      itemCount: _rows.length,
      separatorBuilder: (_, _) => ReviewStyles.gap8,
      itemBuilder: (context, i) => _card(_rows[i], isVi),
    );
  }

  Widget _stateMessage(String text) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Text(
        text,
        style: ReviewStyles.stateMessage,
        textAlign: TextAlign.center,
      ),
    ),
  );

  Widget _card(VocabRow row, bool isVi) {
    final meaning = isVi
        ? (row.meaningVn.isNotEmpty ? row.meaningVn : row.meaningEn)
        : (row.meaningEn.isNotEmpty ? row.meaningEn : row.meaningVn);
    final audioKey = row.audioKey;
    return Container(
      decoration: ReviewStyles.cardDecoration,
      padding: ReviewStyles.cardPadding,
      child: Row(
        children: [
          Text(row.cn, style: ReviewStyles.hanzi),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Opacity(
                  opacity: _showPinyin ? 1 : 0,
                  child: Text(row.pinyin, style: ReviewStyles.pinyin),
                ),
                const SizedBox(height: 2),
                Opacity(
                  opacity: _showMeaning ? 1 : 0,
                  child: Text(
                    meaning,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: ReviewStyles.meaning,
                  ),
                ),
              ],
            ),
          ),
          if (audioKey != null && audioKey.isNotEmpty) ...[
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(Icons.volume_up, color: BrandColors.navTeal),
              onPressed: () => ref
                  .read(audioPlayerProvider)
                  .playUrl(vocabAudioUrl(audioKey)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _pager(AppLocalizations l10n) {
    final start = (_page - 1) * reviewPageSize + 1;
    final end = (_page * reviewPageSize).clamp(0, _total);
    return Padding(
      padding: ReviewStyles.pagePadding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          OutlinedButton(
            style: ReviewStyles.pageStyle(false),
            onPressed: _page > 1 ? () => _load(_page - 1) : null,
            child: const Icon(Icons.chevron_left, size: 18),
          ),
          for (var p = 1; p <= _totalPages; p++) ...[
            const SizedBox(width: 6),
            OutlinedButton(
              style: ReviewStyles.pageStyle(p == _page),
              onPressed: p == _page ? null : () => _load(p),
              child: Text('$p'),
            ),
          ],
          const SizedBox(width: 6),
          OutlinedButton(
            style: ReviewStyles.pageStyle(false),
            onPressed: _page < _totalPages ? () => _load(_page + 1) : null,
            child: const Icon(Icons.chevron_right, size: 18),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              l10n.reviewPageRange(start, end, _total),
              style: ReviewStyles.pageInfo,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
