/// Profile module — the learner's statistics screen.
///
/// Ported from `profile/ProfilePage.tsx` (the statistics half): a header, the
/// learning-statistics block, and the mastered-words list. The practice-review
/// panel and the change-password form follow. Tapping the avatar opens the upload dialog.
/// Reached from the drawer header; route `/profile`.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/media/gcs.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/loading_view.dart';
import '../../../shared/data/vocab_row.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/profile_repository.dart';
import '../providers/profile_providers.dart';
import '../styles/profile_styles.dart';
import '../widgets/avatar_dialog.dart';
import '../widgets/learning_statistics.dart';
import '../widgets/password_form.dart';
import '../widgets/review_panel.dart';

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
    _refreshSummary();
  }

  /// Refreshes the avatar and the server-recomputed HSK level on view
  /// (`GET /api/user/profile-summary`); best-effort.
  Future<void> _refreshSummary() async {
    try {
      final user = await ref
          .read(profileRepositoryProvider)
          .getProfileSummary();
      if (mounted) ref.read(authNotifierProvider.notifier).setUser(user);
    } catch (_) {}
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
          _header(user?.username, user?.email, user?.avatarUrl, user?.level),
          ProfileStyles.gap24,
          _section(l10n.dashboardLearningStatistics, [_statistics(l10n)]),
          _section(l10n.profileLearnedWords, _vocabList(l10n)),
          _section(l10n.reviewTitle, const [ReviewPanel()]),
          _section(l10n.profileChangePassword, const [PasswordForm()]),
        ],
      ),
    );
  }

  /// `.profile-section`: a tinted card with a left-aligned heading.
  Widget _section(String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(top: 18),
      padding: ProfileStyles.sectionPadding,
      decoration: ProfileStyles.sectionDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: ProfileStyles.sectionHeading),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  /// `.profile-header` (phone): avatar with a camera hint, name, email, then the
  /// HSK badge, centred in one column.
  Widget _header(
    String? username,
    String? email,
    String? avatarUrl,
    int? level,
  ) {
    final initial = (username != null && username.isNotEmpty)
        ? username[0].toUpperCase()
        : 'Y';
    final badge = badgeUrl(level);
    return Column(
      children: [
        InkWell(
          customBorder: const CircleBorder(),
          onTap: () => showAvatarDialog(context),
          child: Stack(
            alignment: Alignment.center,
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
              // The web shows the camera on hover; phones have none, so a small
              // badge keeps the tap target discoverable.
              const Positioned(
                right: 2,
                bottom: 2,
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.black54,
                  child: Icon(
                    Icons.photo_camera,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        ProfileStyles.gap16,
        Text(
          username ?? '',
          textAlign: TextAlign.center,
          style: ProfileStyles.usernameStyle,
        ),
        if (email != null && email.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            email,
            textAlign: TextAlign.center,
            style: ProfileStyles.emailStyle,
          ),
        ],
        if (badge != null) ...[
          ProfileStyles.gap16,
          Image.network(
            badge,
            height: ProfileStyles.badgeHeight,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => const SizedBox.shrink(),
          ),
        ],
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
