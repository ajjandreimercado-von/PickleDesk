import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/dashboard/dashboard_screen.dart';
import '../features/sessions/sessions_screen.dart';
import '../features/sessions/add_session_screen.dart';
import '../features/courts/courts_screen.dart';
import '../features/courts/add_court_screen.dart';
import '../features/tournaments/tournaments_screen.dart';
import '../features/expenses/expenses_screen.dart';
import '../features/reservations/reservations_screen.dart';
import '../features/analytics/analytics_screen.dart';
import '../features/reports/reports_screen.dart';
import '../features/onboarding/splash_screen.dart';
import '../shared/widgets/app_scaffold.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    navigatorKey: _rootNavigatorKey,
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return AppScaffold(child: child);
        },
        routes: [
          GoRoute(
            path: '/dashboard',
            name: 'dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/sessions',
            name: 'sessions',
            builder: (context, state) => const SessionsScreen(),
          ),
          GoRoute(
            path: '/courts',
            name: 'courts',
            builder: (context, state) => const CourtsScreen(),
          ),
          GoRoute(
            path: '/tournaments',
            name: 'tournaments',
            builder: (context, state) => const TournamentsScreen(),
          ),
          GoRoute(
            path: '/expenses',
            name: 'expenses',
            builder: (context, state) => const ExpensesScreen(),
          ),
          GoRoute(
            path: '/reservations',
            name: 'reservations',
            builder: (context, state) => const ReservationsScreen(),
          ),
          GoRoute(
            path: '/analytics',
            name: 'analytics',
            builder: (context, state) => const AnalyticsScreen(),
          ),
          GoRoute(
            path: '/reports',
            name: 'reports',
            builder: (context, state) => const ReportsScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/add-court',
        name: 'add-court',
        builder: (context, state) => const AddCourtScreen(),
      ),
      GoRoute(
        path: '/add-session',
        name: 'add-session',
        builder: (context, state) => const AddSessionScreen(),
      ),
    ],
  );
});
