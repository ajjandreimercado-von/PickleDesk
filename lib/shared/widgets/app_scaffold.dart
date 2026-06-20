import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppScaffold extends StatelessWidget {
  final Widget child;

  const AppScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 800;

        if (isDesktop) {
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: _calculateSelectedIndex(context),
                  onDestinationSelected: (int index) => _onDestinationSelected(context, index),
                  labelType: NavigationRailLabelType.all,
                  groupAlignment: 0.0,
                  destinations: const <NavigationRailDestination>[
                    NavigationRailDestination(
                      icon: Icon(Icons.dashboard_outlined),
                      selectedIcon: Icon(Icons.dashboard),
                      label: Text('Dashboard'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.sports_tennis_outlined),
                      selectedIcon: Icon(Icons.sports_tennis),
                      label: Text('Sessions'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.location_on_outlined),
                      selectedIcon: Icon(Icons.location_on),
                      label: Text('Courts'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.emoji_events_outlined),
                      selectedIcon: Icon(Icons.emoji_events),
                      label: Text('Tournaments'),
                    ),
                  ],
                ),
                const VerticalDivider(thickness: 1, width: 1, color: Color(0xFF253028)),
                Expanded(child: child),
              ],
            ),
          );
        }

        return Scaffold(
          body: child,
          bottomNavigationBar: NavigationBar(
            onDestinationSelected: (int index) => _onDestinationSelected(context, index),
            selectedIndex: _calculateSelectedIndex(context),
            destinations: const <NavigationDestination>[
              NavigationDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: 'Dashboard',
              ),
              NavigationDestination(
                icon: Icon(Icons.sports_tennis_outlined),
                selectedIcon: Icon(Icons.sports_tennis),
                label: 'Sessions',
              ),
              NavigationDestination(
                icon: Icon(Icons.location_on_outlined),
                selectedIcon: Icon(Icons.location_on),
                label: 'Courts',
              ),
              NavigationDestination(
                icon: Icon(Icons.emoji_events_outlined),
                selectedIcon: Icon(Icons.emoji_events),
                label: 'Tournaments',
              ),
            ],
          ),
        );
      },
    );
  }

  void _onDestinationSelected(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/dashboard');
        break;
      case 1:
        context.go('/sessions');
        break;
      case 2:
        context.go('/courts');
        break;
      case 3:
        context.go('/tournaments');
        break;
    }
  }

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/sessions')) {
      return 1;
    }
    if (location.startsWith('/courts')) {
      return 2;
    }
    if (location.startsWith('/tournaments')) {
      return 3;
    }
    return 0;
  }
}
