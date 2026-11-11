/// Shell module — the learner navigation drawer.
///
/// Faithful port of the mobile drawer branch of
/// `yi-chinese-manage/components/layout/LearnerSidebar.tsx`: a teal off-canvas
/// panel with the primary destinations (Dashboard, Library/HSK, Vocabulary,
/// Recommend) plus an account footer (username, Settings, Logout). Destinations
/// whose target slice has not shipped are shown disabled and surface a
/// "coming soon" notice on tap. Reads the signed-in user and triggers logout via
/// [authNotifierProvider]. Learn Together (realtime competition) routes to
/// `/competition` (Slice P11).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../auth/providers/auth_provider.dart';
import '../styles/shell_styles.dart';

/// A single primary-nav entry. [route] is null for a destination not yet routed.
class _NavItem {
  const _NavItem({
    required this.label,
    required this.icon,
    this.route,
    this.enabled = true,
  });

  final String label;
  final IconData icon;
  final String? route;
  final bool enabled;
}

class NavDrawer extends ConsumerWidget {
  const NavDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(authNotifierProvider).asData?.value.user;
    final location = GoRouterState.of(context).uri.path;

    final items = <_NavItem>[
      _NavItem(
        label: l10n.navDashboard,
        icon: Icons.space_dashboard_outlined,
        route: '/',
      ),
      _NavItem(
        label: l10n.navLibrary,
        icon: Icons.layers_outlined,
        route: '/library',
      ),
      _NavItem(
        label: l10n.navVocabulary,
        icon: Icons.menu_book_outlined,
        route: '/vocab',
      ),
      _NavItem(
        label: l10n.navRecommend,
        icon: Icons.star_outline,
        enabled: false,
      ),
      _NavItem(
        label: l10n.competitionTitle,
        icon: Icons.groups_outlined,
        route: '/competition',
      ),
    ];

    // Top-level destinations that live inside the shell (so they keep the
    // drawer); switching between them replaces rather than stacks.
    const shellRoutes = {'/', '/library'};

    bool isActive(String? route) {
      if (route == null) return false;
      return route == '/' ? location == '/' : location.startsWith(route);
    }

    void comingSoon() {
      ScaffoldMessenger.of(context)
        ..hideCurrentMaterialBanner()
        ..showSnackBar(SnackBar(content: Text(l10n.comingSoon)));
    }

    void navTo(String route) {
      Navigator.pop(context); // close the drawer first
      if (isActive(route)) return;
      // Shell destinations switch in place (go); deeper destinations are pushed
      // so their own app bar provides a back button.
      if (shellRoutes.contains(route)) {
        context.go(route);
      } else {
        context.push(route);
      }
    }

    return Drawer(
      width: ShellStyles.drawerWidth,
      backgroundColor: ShellStyles.navBg,
      shape: const RoundedRectangleBorder(), // square edge, like the web rail
      child: Column(
        children: [
          _Header(
            username: user?.username,
            avatarUrl: user?.avatarUrl,
            onTap: () => navTo('/profile'),
          ),
          Expanded(
            child: ListView(
              padding: ShellStyles.listPadding,
              children: [
                for (final item in items)
                  _DrawerRow(
                    icon: item.icon,
                    label: item.label,
                    active: isActive(item.route),
                    enabled: item.enabled,
                    onTap: item.enabled && item.route != null
                        ? () => navTo(item.route!)
                        : comingSoon,
                  ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: ShellStyles.divider),
          Padding(
            padding: ShellStyles.sectionPadding,
            child: Column(
              children: [
                _DrawerRow(
                  icon: Icons.settings_outlined,
                  label: l10n.navSettings,
                  active: isActive('/settings'),
                  onTap: () {
                    Navigator.pop(context);
                    if (!isActive('/settings')) context.push('/settings');
                  },
                ),
                if (user != null)
                  _DrawerRow(
                    icon: Icons.logout,
                    label: l10n.navLogout,
                    onTap: () {
                      Navigator.pop(context);
                      ref.read(authNotifierProvider.notifier).logout();
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Account header: avatar (initial fallback) + username. Tapping it opens the
/// learner's profile / statistics screen (Slice P3).
class _Header extends StatelessWidget {
  const _Header({this.username, this.avatarUrl, this.onTap});

  final String? username;
  final String? avatarUrl;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final name = username ?? l10n.appTitle;
    final initial = (username != null && username!.isNotEmpty)
        ? username![0].toUpperCase()
        : 'Y';

    return SafeArea(
      bottom: false,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: ShellStyles.headerPadding,
          child: Row(
            children: [
              Container(
                width: ShellStyles.avatarSize,
                height: ShellStyles.avatarSize,
                decoration: const BoxDecoration(
                  color: ShellStyles.avatarBg,
                  shape: BoxShape.circle,
                ),
                clipBehavior: Clip.antiAlias,
                alignment: Alignment.center,
                child: avatarUrl != null
                    ? Image.network(
                        avatarUrl!,
                        fit: BoxFit.cover,
                        width: ShellStyles.avatarSize,
                        height: ShellStyles.avatarSize,
                        errorBuilder: (_, _, _) =>
                            Text(initial, style: ShellStyles.avatarInitial),
                      )
                    : Text(initial, style: ShellStyles.avatarInitial),
              ),
              ShellStyles.headerAvatarGap,
              Expanded(
                child: Text(
                  name,
                  style: ShellStyles.username,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One drawer row — icon + label with the web `rowCls` highlight states.
class _DrawerRow extends StatelessWidget {
  const _DrawerRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
    this.enabled = true,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final color = enabled ? ShellStyles.rowText : ShellStyles.rowDisabled;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: active ? ShellStyles.rowActiveBg : Colors.transparent,
        borderRadius: BorderRadius.circular(ShellStyles.rowRadius),
        child: InkWell(
          borderRadius: BorderRadius.circular(ShellStyles.rowRadius),
          hoverColor: ShellStyles.rowHoverBg,
          onTap: onTap,
          child: Padding(
            padding: ShellStyles.rowPadding,
            child: Row(
              children: [
                Icon(icon, size: ShellStyles.iconSize, color: color),
                const SizedBox(width: ShellStyles.rowGap),
                Expanded(
                  child: Text(
                    label,
                    style: enabled
                        ? ShellStyles.rowLabel
                        : ShellStyles.rowLabelDisabled,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
