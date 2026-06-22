import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

/// Branch indexes matching app_router.dart
///   0 dashboard | 1 sessions | 2 courts | 3 reservations
///   4 tournaments | 5 analytics | 6 expenses | 7 settings | 8 more
class AppScaffold extends StatefulWidget {
  final StatefulNavigationShell navigationShell;
  const AppScaffold({super.key, required this.navigationShell});

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 900;
        if (isDesktop) {
          return _DesktopShell(navigationShell: widget.navigationShell);
        }
        // Mobile – track only 5 bottom-tab branches
        final mobileIndex = _mobileTabIndex(widget.navigationShell.currentIndex);
        return _MobileShell(
          currentMobileIndex: mobileIndex,
          onTabTap: (i) => _onMobileTap(i),
          child: widget.navigationShell,
        );
      },
    );
  }

  /// Map branch index → mobile tab (Home=0, Sessions=1, Courts=2, Tournaments=3, More=4)
  int _mobileTabIndex(int branch) {
    switch (branch) {
      case 0: return 0;
      case 1: return 1;
      case 2: return 2;
      case 4: return 3; // tournaments
      default: return 4;  // everything else → More tab highlight
    }
  }

  void _onMobileTap(int mobileTab) {
    const branchMap = [0, 1, 2, 4, 8]; // mobile tab → shell branch
    widget.navigationShell.goBranch(branchMap[mobileTab],
        initialLocation: branchMap[mobileTab] == widget.navigationShell.currentIndex);
  }
}

// ── Desktop Sidebar Shell ──────────────────────────────────────────────────────

class _DesktopShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const _DesktopShell({required this.navigationShell});

  static const _navItems = [
    (branch: 0, path: '/dashboard',    label: 'Home',         icon: Icons.home_outlined,         iconSel: Icons.home_rounded),
    (branch: 1, path: '/sessions',     label: 'Sessions',     icon: Icons.article_outlined,       iconSel: Icons.article_rounded),
    (branch: 2, path: '/courts',       label: 'Courts',       icon: Icons.sports_tennis_outlined, iconSel: Icons.sports_tennis),
    (branch: 3, path: '/reservations', label: 'Reservations', icon: Icons.calendar_month_outlined,iconSel: Icons.calendar_month),
    (branch: 4, path: '/tournaments',  label: 'Tournaments',  icon: Icons.emoji_events_outlined,  iconSel: Icons.emoji_events),
    (branch: 5, path: '/analytics',    label: 'Analytics',    icon: Icons.show_chart_outlined,    iconSel: Icons.show_chart),
    (branch: 6, path: '/expenses',     label: 'Expenses',     icon: Icons.account_balance_wallet_outlined, iconSel: Icons.account_balance_wallet),
  ];

  @override
  Widget build(BuildContext context) {
    final current = navigationShell.currentIndex;
    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 220,
            color: AppTheme.background,
            child: Column(
              children: [
                // ── Logo ──────────────────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: AppTheme.border)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryDark,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.sports_tennis,
                            color: AppTheme.primary, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('PickleDesk',
                              style: GoogleFonts.montserrat(
                                  color: AppTheme.primary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 17,
                                  height: 1)),
                          Text('Personal Tracker',
                              style: GoogleFonts.inter(
                                  color: AppTheme.text3, fontSize: 11)),
                        ],
                      ),
                    ],
                  ),
                ),

                // ── Nav items ─────────────────────────────────────────────────
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: _navItems.map((item) {
                        final isActive = current == item.branch;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: _SideNavTile(
                            label: item.label,
                            icon: isActive ? item.iconSel : item.icon,
                            isActive: isActive,
                            onTap: () => navigationShell.goBranch(item.branch,
                                initialLocation: item.branch == current),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                // ── Settings pinned at bottom ─────────────────────────────────
                Container(
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: AppTheme.border)),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: _SideNavTile(
                    label: 'Settings',
                    icon: current == 7 ? Icons.settings : Icons.settings_outlined,
                    isActive: current == 7,
                    onTap: () => navigationShell.goBranch(7,
                        initialLocation: 7 == current),
                  ),
                ),
              ],
            ),
          ),
          const VerticalDivider(thickness: 1, width: 1, color: AppTheme.border),
          Expanded(
            child: ClipRect(child: navigationShell),
          ),
        ],
      ),
    );
  }
}

class _SideNavTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;
  const _SideNavTile({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isActive
          ? AppTheme.primaryDark.withValues(alpha: 0.5)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        hoverColor: AppTheme.surface,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(icon,
                  color: isActive ? AppTheme.primary : AppTheme.text2,
                  size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(label,
                    style: GoogleFonts.inter(
                      color: isActive ? AppTheme.primary : AppTheme.text2,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    )),
              ),
              if (isActive)
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppTheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Mobile Bottom Nav Shell ────────────────────────────────────────────────────

class _MobileShell extends StatelessWidget {
  final Widget child;
  final int currentMobileIndex;
  final Function(int) onTabTap;

  const _MobileShell({
    required this.child,
    required this.currentMobileIndex,
    required this.onTabTap,
  });

  static const _tabs = [
    (label: 'Home',     icon: Icons.home_outlined,         iconSel: Icons.home_rounded),
    (label: 'Sessions', icon: Icons.article_outlined,       iconSel: Icons.article_rounded),
    (label: 'Courts',   icon: Icons.sports_tennis_outlined, iconSel: Icons.sports_tennis),
    (label: 'Tourneys', icon: Icons.emoji_events_outlined,  iconSel: Icons.emoji_events),
    (label: 'More',     icon: Icons.more_horiz_outlined,    iconSel: Icons.more_horiz),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xF51d201c),
          border: Border(top: BorderSide(color: AppTheme.border)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: List.generate(_tabs.length, (i) {
                final tab = _tabs[i];
                final isActive = currentMobileIndex == i;
                return Expanded(
                  child: InkWell(
                    onTap: () => onTabTap(i),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isActive ? tab.iconSel : tab.icon,
                          color: isActive ? AppTheme.primary : AppTheme.text2,
                          size: 22,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          tab.label,
                          style: GoogleFonts.inter(
                            color: isActive ? AppTheme.primary : AppTheme.text2,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
