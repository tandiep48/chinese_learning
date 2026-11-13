/// Profile module — the "Practice Review" panel.
///
/// Ported from `ReviewPanel.tsx` + `ReviewSessionDetail.tsx` +
/// `ReviewQuestionCard.tsx`: a filterable (level / category / sort), paged list
/// of past practice and exam sessions, and a read-only per-session detail with
/// result / skill filters, option marks and your-vs-correct answers.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/audio/audio_player.dart';
import '../../../core/media/gcs.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/loading_view.dart';
import '../data/models/review_models.dart';
import '../data/profile_repository.dart';
import '../data/review_logic.dart';
import '../styles/review_styles.dart';

class ReviewPanel extends ConsumerStatefulWidget {
  const ReviewPanel({super.key});

  @override
  ConsumerState<ReviewPanel> createState() => _ReviewPanelState();
}

class _ReviewPanelState extends ConsumerState<ReviewPanel> {
  String _level = 'all';
  String _category = 'all';
  String _sort = 'recent';
  int _page = 1;

  List<ReviewSession> _sessions = const [];
  bool _hasMore = false;
  bool _loading = true;
  bool _error = false;

  /// Non-null while the detail view is open.
  int? _openId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = false;
    });
    try {
      final page = await ref
          .read(profileRepositoryProvider)
          .getPracticeHistory(
            page: _page,
            level: _level == 'all' ? null : _level,
            category: _category == 'all' ? null : _category,
            sort: _sort,
          );
      if (!mounted) return;
      setState(() {
        _sessions = page.sessions;
        _hasMore = page.hasMore;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _sessions = const [];
        _hasMore = false;
        _loading = false;
        _error = true;
      });
    }
  }

  /// Any filter change restarts at page 1.
  void _setFilter({String? level, String? category, String? sort}) {
    _level = level ?? _level;
    _category = category ?? _category;
    _sort = sort ?? _sort;
    _page = 1;
    _load();
  }

  void _changePage(int delta) {
    final next = _page + delta;
    if (next < 1 || (delta > 0 && !_hasMore)) return;
    _page = next;
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final id = _openId;
    if (id != null) {
      return _SessionDetail(
        sessionId: id,
        onBack: () => setState(() => _openId = null),
      );
    }
    final l10n = AppLocalizations.of(context);
    final showPager = _page > 1 || _hasMore;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 16,
          runSpacing: 12,
          children: [
            _FilterDropdown<String>(
              label: l10n.reviewLevel,
              value: _level,
              items: {
                'all': l10n.reviewAllLevels,
                for (var n = 1; n <= 6; n++) '$n': 'HSK $n',
              },
              onChanged: (v) => _setFilter(level: v),
            ),
            _FilterDropdown<String>(
              label: l10n.reviewCategory,
              value: _category,
              items: {
                'all': l10n.reviewAllCategories,
                'practice': l10n.dashboardExercise,
                'exam': l10n.dashboardExam,
              },
              onChanged: (v) => _setFilter(category: v),
            ),
            _FilterDropdown<String>(
              label: l10n.reviewSort,
              value: _sort,
              items: {
                'recent': l10n.reviewSortRecent,
                'oldest': l10n.reviewSortOldest,
              },
              onChanged: (v) => _setFilter(sort: v),
            ),
          ],
        ),
        ReviewStyles.gap18,
        if (_loading)
          const Padding(
            padding: ReviewStyles.stateBoxPadding,
            child: LoadingView(),
          )
        else if (_error)
          _StateBox(title: l10n.reviewFailedLoad)
        else if (_sessions.isEmpty)
          _page > 1
              ? _StateBox(sub: l10n.reviewNoMore)
              : _StateBox(
                  title: l10n.reviewEmptyTitle,
                  sub: l10n.reviewEmptySub,
                )
        else
          for (final s in _sessions) ...[
            _SessionCard(
              session: s,
              onTap: () => setState(() => _openId = s.sessionId),
            ),
            ReviewStyles.gap14,
          ],
        if (showPager && !_loading)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: _page <= 1 ? null : () => _changePage(-1),
                icon: const Icon(Icons.chevron_left, size: 18),
                label: Text(l10n.milestonePrevious),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  l10n.reviewPageIndicator(_page),
                  style: ReviewStyles.sessionMeta,
                ),
              ),
              OutlinedButton(
                onPressed: _hasMore ? () => _changePage(1) : null,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(l10n.milestoneNext),
                    const Icon(Icons.chevron_right, size: 18),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _StateBox extends StatelessWidget {
  const _StateBox({this.title, this.sub});

  final String? title;
  final String? sub;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: ReviewStyles.stateBoxPadding,
      child: Column(
        children: [
          const Icon(Icons.folder_open, size: 44, color: BrandColors.primary),
          ReviewStyles.gap12,
          if (title != null)
            Text(
              title!,
              textAlign: TextAlign.center,
              style: ReviewStyles.stateTitle,
            ),
          if (sub != null) ...[
            ReviewStyles.gap6,
            Text(
              sub!,
              textAlign: TextAlign.center,
              style: ReviewStyles.stateSub,
            ),
          ],
        ],
      ),
    );
  }
}

class _FilterDropdown<T> extends StatelessWidget {
  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final T value;
  final Map<T, String> items;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: ReviewStyles.filterLabel),
        const SizedBox(height: 6),
        DropdownButton<T>(
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

class _SessionCard extends StatelessWidget {
  const _SessionCard({required this.session, required this.onTap});

  final ReviewSession session;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final levels = session.levels.map((l) => 'HSK $l').join(', ');
    final lessons = session.lessons.join(', ');
    final title = lessons.isEmpty
        ? levels
        : '$levels · ${l10n.lessonLabel(lessons)}';
    final date = session.endedAt == null
        ? ''
        : MaterialLocalizations.of(context).formatShortDate(session.endedAt!);

    return Container(
      decoration: ReviewStyles.sessionCard,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: ReviewStyles.sessionCardPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: ReviewStyles.sessionTitle),
                ReviewStyles.gap6,
                Wrap(
                  spacing: 14,
                  children: [
                    if (date.isNotEmpty)
                      Text(date, style: ReviewStyles.sessionMeta),
                    Text(
                      l10n.reviewQuestions(session.total),
                      style: ReviewStyles.sessionMeta,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SessionDetail extends ConsumerStatefulWidget {
  const _SessionDetail({required this.sessionId, required this.onBack});

  final int sessionId;
  final VoidCallback onBack;

  @override
  ConsumerState<_SessionDetail> createState() => _SessionDetailState();
}

class _SessionDetailState extends ConsumerState<_SessionDetail> {
  ReviewDetail? _detail;
  bool _error = false;
  ResultFilter _result = ResultFilter.all;
  SkillFilter _skill = SkillFilter.all;

  @override
  void initState() {
    super.initState();
    ref
        .read(profileRepositoryProvider)
        .getPracticeHistoryDetail(widget.sessionId)
        .then((d) {
          if (mounted) setState(() => _detail = d);
        })
        .catchError((_) {
          if (mounted) setState(() => _error = true);
        });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final detail = _detail;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: widget.onBack,
            child: Text('← ${l10n.reviewBackToList}'),
          ),
        ),
        if (_error)
          _StateBox(title: l10n.reviewFailedLoad)
        else if (detail == null)
          const Padding(
            padding: ReviewStyles.stateBoxPadding,
            child: LoadingView(),
          )
        else ...[
          Wrap(
            spacing: 16,
            runSpacing: 12,
            children: [
              _FilterDropdown<ResultFilter>(
                label: l10n.reviewFilterResult,
                value: _result,
                items: {
                  ResultFilter.all: l10n.reviewResultAll,
                  ResultFilter.correct: l10n.reviewCorrectBadge,
                  ResultFilter.incorrect: l10n.reviewIncorrectBadge,
                },
                onChanged: (v) => setState(() => _result = v),
              ),
              _FilterDropdown<SkillFilter>(
                label: l10n.reviewSkill,
                value: _skill,
                items: {
                  SkillFilter.all: l10n.reviewSkillAll,
                  SkillFilter.reading: l10n.reviewReading,
                  SkillFilter.listening: l10n.reviewListening,
                },
                onChanged: (v) => setState(() => _skill = v),
              ),
            ],
          ),
          ReviewStyles.gap18,
          ..._cards(l10n, detail),
        ],
      ],
    );
  }

  List<Widget> _cards(AppLocalizations l10n, ReviewDetail detail) {
    final rows = filterReviewQuestions(detail.questions, _result, _skill);
    if (rows.isEmpty) return [_StateBox(title: l10n.reviewEmptySub)];
    return [
      for (final r in rows) ...[
        _QuestionCard(question: r.question, number: r.number),
        ReviewStyles.gap18,
      ],
    ];
  }
}

class _QuestionCard extends ConsumerWidget {
  const _QuestionCard({required this.question, required this.number});

  final ReviewQuestion question;
  final int number;

  Widget _optionBody(AppLocalizations l10n, Object? val) {
    if (val == true || val == 'True') return Text(l10n.practiceTrueLabel);
    if (val == false || val == 'False') return Text(l10n.practiceFalseLabel);
    if (isImageFilename(val)) {
      return Image.network(
        practiceImageUrl(question.level, '$val', question.category),
        height: 80,
        alignment: Alignment.centerLeft,
        errorBuilder: (_, _, _) => Text('$val'),
      );
    }
    return Text('$val');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final q = question;
    final imgFile = questionImageFile(q);
    final showPrompt =
        q.question != null &&
        q.question!.isNotEmpty &&
        !isImageFilename(q.question);
    final correctSet = answerTokens(q.answer);
    final userSet = answerTokens(q.userAnswer);
    final nothing =
        q.options.isEmpty &&
        (q.content ?? '').isEmpty &&
        (q.question ?? '').isEmpty &&
        imgFile == null;

    return Container(
      decoration: ReviewStyles.questionCard(q.isCorrect),
      padding: ReviewStyles.questionCardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.reviewQuestionLabel(number),
                style: ReviewStyles.questionNumber,
              ),
              Container(
                decoration: ReviewStyles.badge(q.isCorrect),
                padding: ReviewStyles.badgePadding,
                child: Text(
                  q.isCorrect
                      ? '✓ ${l10n.reviewCorrectBadge}'
                      : '✗ ${l10n.reviewIncorrectBadge}',
                  style: ReviewStyles.badgeText.copyWith(
                    color: q.isCorrect
                        ? BrandColors.success
                        : BrandColors.danger,
                  ),
                ),
              ),
            ],
          ),
          ReviewStyles.gap12,
          if (nothing) ...[
            Text(l10n.reviewDetailMissing, style: ReviewStyles.missingText),
            ReviewStyles.gap12,
          ],
          for (final key in q.audioKeys)
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: IconButton.filled(
                  style: IconButton.styleFrom(
                    backgroundColor: BrandColors.primary,
                  ),
                  icon: const Icon(Icons.play_arrow),
                  onPressed: () => ref
                      .read(audioPlayerProvider)
                      .playUrl(practiceAudioUrl(key, q.level, q.category)),
                ),
              ),
            ),
          if (imgFile != null) ...[
            Image.network(
              practiceImageUrl(q.level, imgFile, q.category),
              height: 220,
              alignment: Alignment.centerLeft,
              errorBuilder: (_, _, _) => const SizedBox.shrink(),
            ),
            ReviewStyles.gap12,
          ],
          if ((q.content ?? '').isNotEmpty) ...[
            Container(
              decoration: ReviewStyles.contentBox,
              padding: ReviewStyles.contentPadding,
              child: Text(q.content!, style: ReviewStyles.contentText),
            ),
            ReviewStyles.gap12,
          ],
          if (showPrompt) ...[
            Text(q.question!, style: ReviewStyles.promptText),
            ReviewStyles.gap12,
          ],
          for (final e in q.options.entries) ...[
            _optionRow(l10n, e.key, e.value, correctSet, userSet),
            const SizedBox(height: 8),
          ],
          ReviewStyles.gap6,
          _answerLine(
            l10n.reviewYourAnswer,
            (q.userAnswer == null || q.userAnswer!.isEmpty)
                ? Text(
                    l10n.reviewNoAnswer,
                    style: const TextStyle(fontStyle: FontStyle.italic),
                  )
                : Text(q.userAnswer!),
            ok: q.isCorrect,
          ),
          const SizedBox(height: 4),
          _answerLine(
            l10n.reviewCorrectAnswer,
            Text(q.answer.isEmpty ? '—' : q.answer),
            ok: true,
          ),
        ],
      ),
    );
  }

  Widget _optionRow(
    AppLocalizations l10n,
    String key,
    Object? val,
    Set<String> correctSet,
    Set<String> userSet,
  ) {
    final isCorrect = correctSet.contains(key);
    final isUser = userSet.contains(key);
    return Container(
      decoration: ReviewStyles.option(correct: isCorrect, user: isUser),
      padding: ReviewStyles.optionPadding,
      child: Row(
        children: [
          Text(key, style: ReviewStyles.optionKey),
          const SizedBox(width: 10),
          Expanded(child: _optionBody(l10n, val)),
          if (isUser)
            Tooltip(
              message: l10n.reviewYourAnswer,
              child: const Icon(
                Icons.person,
                size: 16,
                color: BrandColors.mutedText,
              ),
            ),
          if (isCorrect)
            Tooltip(
              message: l10n.reviewCorrectAnswer,
              child: const Icon(
                Icons.check,
                size: 16,
                color: BrandColors.success,
              ),
            ),
        ],
      ),
    );
  }

  Widget _answerLine(String label, Widget value, {required bool ok}) {
    return DefaultTextStyle.merge(
      style: ok ? ReviewStyles.answerOk : ReviewStyles.answerBad,
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 8,
        children: [
          Text(label, style: ReviewStyles.answerLabel),
          value,
        ],
      ),
    );
  }
}
