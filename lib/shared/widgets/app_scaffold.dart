import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

/// Responsive shell — sidebar on desktop (≥900px), swipeable bottom nav on mobile
class AppScaffold extends StatefulWidget {
  final StatefulNavigationShell navigationShell;
  const AppScaffold({super.key, required this.navigationShell});

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.navigationShell.currentIndex);
  }

  @override
  void didUpdateWidget(AppScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.navigationShell.currentIndex != widget.navigationShell.currentIndex) {
      if ((_pageController.page?.round() ?? 0) != widget.navigationShell.currentIndex) {
        _pageController.jumpToPage(widget.navigationShell.currentIndex);
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    widget.navigationShell.goBranch(index, initialLocation: index == widget.navigationShell.currentIndex);
  }

  void _onTabTap(int index) {
    widget.navigationShell.goBranch(index, initialLocation: index == widget.navigationShell.currentIndex);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 900;
        return isDesktop
            ? _DesktopShell(
                navigationShell: widget.navigationShell,
                child: widget.navigationShell,
              )
            : _MobileShell(
                currentIndex: widget.navigationShell.currentIndex,
                onTabTap: _onTabTap,
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  physics: const BouncingScrollPhysics(),
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    // Force the navigation shell to render the current page branch
                    return widget.navigationShell;
                  },
                ),
              );
      },
    );
  }
}

// ── Desktop sidebar shell ─────────────────────────────────────────────────────

class _DesktopShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  final Widget child;
  const _DesktopShell({required this.navigationShell, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          _SideNav(currentPath: GoRouterState.of(context).uri.path, onNavTap: (i) => navigationShell.goBranch(i)),
          const VerticalDivider(thickness: 1, width: 1, color: AppTheme.border),
          Expanded(
            child: ClipRect(child: child),
          ),
        ],
      ),
    );
  }
}

class _SideNav extends StatelessWidget {
  final String currentPath;
  final Function(int) onNavTap;
  const _SideNav({required this.currentPath, required this.onNavTap});

  static const _navItems = [
    (path: '/dashboard',    label: 'Home',         icon: Icons.home_outlined,         iconSel: Icons.home_rounded, idx: 0),
    (path: '/sessions',     label: 'Sessions',     icon: Icons.article_outlined,       iconSel: Icons.article_rounded, idx: 1),
    (path: '/courts',       label: 'Courts',       icon: Icons.sports_tennis_outlined, iconSel: Icons.sports_tennis, idx: 2),
    (path: '/reservations', label: 'Reservations', icon: Icons.calendar_month_outlined,iconSel: Icons.calendar_month, idx: -1),
    (path: '/tournaments',  label: 'Tournaments',  icon: Icons.emoji_events_outlined,  iconSel: Icons.emoji_events, idx: 3),
    (path: '/analytics',    label: 'Analytics',    icon: Icons.show_chart_outlined,    iconSel: Icons.show_chart, idx: -1),
    (path: '/expenses',     label: 'Expenses',     icon: Icons.account_balance_wallet_outlined, iconSel: Icons.account_balance_wallet, idx: -1),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      color: AppTheme.background,
      child: Column(
        children: [
          // Logo
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
                  child: const Icon(Icons.sports_tennis, color: AppTheme.primary, size: 20),
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

          // Nav items
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: _navItems.map((item) {
                  final isActive = currentPath.startsWith(item.path);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Material(
                      color: isActive
                          ? AppTheme.primaryDark.withValues(alpha: 0.5)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        hoverColor: AppTheme.surface,
                        onTap: () {
                          if (item.idx != -1) {
                            onNavTap(item.idx);
                          } else {
                            context.go(item.path);
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          child: Row(
                            children: [
                              Icon(
                                isActive ? item.iconSel : item.icon,
                                color: isActive ? AppTheme.primary : AppTheme.text2,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  item.label,
                                  style: GoogleFonts.inter(
                                    color: isActive
                                        ? AppTheme.primary
                                        : AppTheme.text2,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
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
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Settings at bottom
          Container(
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppTheme.border)),
            ),
            padding: const EdgeInsets.all(12),
            child: _sideNavButton(
              context,
              path: '/settings',
              label: 'Settings',
              icon: Icons.settings_outlined,
              iconSel: Icons.settings,
              currentPath: currentPath,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sideNavButton(BuildContext context,
      {required String path,
      required String label,
      required IconData icon,
      required IconData iconSel,
      required String currentPath}) {
    final isActive = currentPath.startsWith(path);
    return Material(
      color: isActive
          ? AppTheme.primaryDark.withValues(alpha: 0.5)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        hoverColor: AppTheme.surface,
        onTap: () => context.go(path),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(isActive ? iconSel : icon,
                  color: isActive ? AppTheme.primary : AppTheme.text2,
                  size: 20),
              const SizedBox(width: 12),
              Text(
                label,
                style: GoogleFonts.inter(
                  color: isActive ? AppTheme.primary : AppTheme.text2,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Mobile bottom nav shell ────────────────────────────────────────────────────

class _MobileShell extends StatelessWidget {
  final Widget child;
  final int currentIndex;
  final Function(int) onTabTap;
  
  const _MobileShell({required this.child, required this.currentIndex, required this.onTabTap});

  static const _tabs = [
    (label: 'Home',     icon: Icons.home_outlined,        iconSel: Icons.home_rounded),
    (label: 'Sessions', icon: Icons.article_outlined,      iconSel: Icons.article_rounded),
    (label: 'Courts',   icon: Icons.sports_tennis_outlined, iconSel: Icons.sports_tennis),
    (label: 'Tourneys', icon: Icons.emoji_events_outlined,  iconSel: Icons.emoji_events),
    (label: 'More',     icon: Icons.more_horiz_outlined,   iconSel: Icons.more_horiz),
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
          child: SizedBox(
            height: 64,
            child: Row(
              children: List.generate(_tabs.length, (i) {
                final tab = _tabs[i];
                final isActive = currentIndex == i;
                return Expanded(
                  child: InkWell(
                    onTap: () => onTabTap(i),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
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
