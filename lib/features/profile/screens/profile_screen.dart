/// Profile module — the learner's statistics screen.
///
/// Ported from `profile/ProfilePage.tsx` (the statistics half): a header, the
/// learning-statistics block, and the mastered-words list. The practice-review
/// panel (Slice P4) and the account forms (avatar/password) are deferred.
/// Reached from the drawer header; route `/profile`.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/loading_view.dart';
import '../../../shared/data/vocab_row.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/profile_repository.dart';
import '../providers/profile_providers.dart';
import '../styles/profile_styles.dart';
import '../widgets/learning_statistics.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  static const int _pageSize = 20;
  final List<VocabRow> _vocab = [];
  int _page = 0;
  bool _loading = false;
  bool _hasMore = true;
  bool _vocabError = false;

  @override
  void initState() {
    super.initState();
    _loadMore();
  }

  Future<void> _loadMore() async {
    if (_loading || !_hasMore) return;
    setState(() {
      _loading = true;
      _vocabError = false;
    });
    try {
      final page = await ref
          .read(profileRepositoryProvider)
          .getLearnedVocab(_page + 1, _pageSize);
      if (!mounted) return;
      setState(() {
        _vocab.addAll(page.rows);
        _page = page.page;
        _hasMore = page.hasMore;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _vocabError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(authNotifierProvider).value?.user;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileTitle)),
      body: ListView(
        padding: ProfileStyles.pagePadding,
        children: [
          _header(user?.username, user?.avatarUrl),
          ProfileStyles.gap24,
          Text(
            l10n.dashboardLearningStatistics,
            style: ProfileStyles.sectionHeading,
          ),
          ProfileStyles.gap16,
          _statistics(l10n),
          ProfileStyles.gap24,
          Text(l10n.profileLearnedWords, style: ProfileStyles.sectionHeading),
          ProfileStyles.gap16,
          ..._vocabList(l10n),
        ],
      ),
    );
  }

  Widget _header(String? username, String? avatarUrl) {
    final initial = (username != null && username.isNotEmpty)
        ? username[0].toUpperCase()
        : 'Y';
    return Row(
      children: [
        Container(
          width: ProfileStyles.avatarSize,
          height: ProfileStyles.avatarSize,
          decoration: ProfileStyles.avatarDecoration,
          clipBehavior: Clip.antiAlias,
          alignment: Alignment.center,
          child: avatarUrl != null
              ? Image.network(
                  avatarUrl,
                  fit: BoxFit.cover,
                  width: ProfileStyles.avatarSize,
                  height: ProfileStyles.avatarSize,
                  errorBuilder: (_, _, _) =>
                      Text(initial, style: ProfileStyles.avatarInitial),
                )
              : Text(initial, style: ProfileStyles.avatarInitial),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            username ?? '',
            style: ProfileStyles.usernameStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _statistics(AppLocalizations l10n) {
    final statsAsync = ref.watch(globalStatsProvider);
    final wordsAsync = ref.watch(learnedWordsDaysProvider);
    final timeAsync = ref.watch(timeLearnedDaysProvider);

    if (statsAsync.hasError) {
      return EmptyState(
        icon: Icons.cloud_off,
        title: l10n.studyError,
        action: FilledButton.tonal(
          onPressed: () {
            ref.invalidate(globalStatsProvider);
            ref.invalidate(learnedWordsDaysProvider);
            ref.invalidate(timeLearnedDaysProvider);
          },
          child: Text(l10n.commonRetry),
        ),
      );
    }
    final stats = statsAsync.asData?.value;
    if (stats == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: LoadingView(),
      );
    }
    return LearningStatistics(
      stats: stats,
      wordsDays: wordsAsync.asData?.value ?? const [],
      timeDays: timeAsync.asData?.value ?? const [],
    );
  }

  List<Widget> _vocabList(AppLocalizations l10n) {
    if (_vocab.isEmpty && _loading) {
      return const [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: LoadingView(),
        ),
      ];
    }
    if (_vocab.isEmpty && _vocabError) {
      return [
        EmptyState(
          icon: Icons.cloud_off,
          title: l10n.studyError,
          action: FilledButton.tonal(
            onPressed: _loadMore,
            child: Text(l10n.commonRetry),
          ),
        ),
      ];
    }
    if (_vocab.isEmpty) {
      return [
        EmptyState(icon: Icons.menu_book_outlined, title: l10n.vocabNoWords),
      ];
    }
    final isVi = Localizations.localeOf(context).languageCode == 'vi';
    return [
      for (final row in _vocab) ...[
        _vocabRow(row, isVi),
        const SizedBox(height: 8),
      ],
      if (_hasMore)
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Center(
            child: _loading
                ? const CircularProgressIndicator()
                : OutlinedButton(
                    onPressed: _loadMore,
                    child: Text(l10n.commonLoadMore),
                  ),
          ),
        ),
    ];
  }

  Widget _vocabRow(VocabRow row, bool isVi) {
    final meaning = isVi
        ? (row.meaningVn.isNotEmpty ? row.meaningVn : row.meaningEn)
        : (row.meaningEn.isNotEmpty ? row.meaningEn : row.meaningVn);
    return Container(
      decoration: ProfileStyles.cardDecoration,
      padding: ProfileStyles.cardPadding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(row.cn, style: ProfileStyles.vocabHanzi),
              if (row.pinyin.isNotEmpty)
                Text(row.pinyin, style: ProfileStyles.vocabPinyin),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(meaning, style: ProfileStyles.vocabMeaning)),
          if (row.level.isNotEmpty) ...[
            const SizedBox(width: 8),
            Container(
              decoration: ProfileStyles.vocabLevelBadge,
              padding: ProfileStyles.vocabLevelPadding,
              child: Text(row.level, style: ProfileStyles.vocabLevelText),
            ),
          ],
        ],
      ),
    );
  }
}
