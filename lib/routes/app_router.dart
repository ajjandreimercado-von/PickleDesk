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

    // All main sections inside the shell so the sidebar is always visible
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AppScaffold(navigationShell: navigationShell);
      },
      branches: [
        // 0 – Home / Dashboard
        StatefulShellBranch(routes: [
          GoRoute(
              path: '/dashboard',
              builder: (context, state) => const DashboardScreen()),
        ]),
        // 1 – Sessions
        StatefulShellBranch(routes: [
          GoRoute(
              path: '/sessions',
              builder: (context, state) => const SessionsScreen()),
        ]),
        // 2 – Courts
        StatefulShellBranch(routes: [
          GoRoute(
              path: '/courts',
              builder: (context, state) => const CourtsScreen()),
        ]),
        // 3 – Reservations
        StatefulShellBranch(routes: [
          GoRoute(
              path: '/reservations',
              builder: (context, state) => const ReservationsScreen()),
        ]),
        // 4 – Tournaments
        StatefulShellBranch(routes: [
          GoRoute(
              path: '/tournaments',
              builder: (context, state) => const TournamentsScreen()),
        ]),
        // 5 – Analytics
        StatefulShellBranch(routes: [
          GoRoute(
              path: '/analytics',
              builder: (context, state) => const AnalyticsScreen()),
        ]),
        // 6 – Expenses
        StatefulShellBranch(routes: [
          GoRoute(
              path: '/expenses',
              builder: (context, state) => const ExpensesScreen()),
        ]),
        // 7 – Settings
        StatefulShellBranch(routes: [
          GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsScreen()),
        ]),
        // 8 – More (mobile "More" tab)
        StatefulShellBranch(routes: [
          GoRoute(
              path: '/more',
              builder: (context, state) => const MoreScreen()),
        ]),
      ],
    ),
  ],
);
