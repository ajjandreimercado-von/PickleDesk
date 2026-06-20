import 'package:go_router/go_router.dart';
import '../shared/widgets/app_scaffold.dart';
import '../features/onboarding/splash_screen.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/sessions/sessions_screen.dart';
import '../features/courts/courts_screen.dart';
import '../features/reservations/reservations_screen.dart';
import '../features/tournaments/tournaments_screen.dart';
import '../features/analytics/analytics_screen.dart';
import '../features/expenses/expenses_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/more/more_screen.dart';
import '../features/courts/add_court_screen.dart';
import '../features/sessions/add_session_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/add-court',
      builder: (context, state) => const AddCourtScreen(),
    ),
    GoRoute(
      path: '/add-session',
      builder: (context, state) => const AddSessionScreen(),
    ),
    GoRoute(
      path: '/reservations',
      builder: (context, state) => const ReservationsScreen(),
    ),
    GoRoute(
      path: '/analytics',
      builder: (context, state) => const AnalyticsScreen(),
    ),
    GoRoute(
      path: '/expenses',
      builder: (context, state) => const ExpensesScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    
    // Main tabs with StatefulShellRoute for PageView swiping
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AppScaffold(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(path: '/dashboard', builder: (context, state) => const DashboardScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/sessions', builder: (context, state) => const SessionsScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/courts', builder: (context, state) => const CourtsScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/tournaments', builder: (context, state) => const TournamentsScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/more', builder: (context, state) => const MoreScreen()),
        ]),
      ],
    ),
  ],
);
