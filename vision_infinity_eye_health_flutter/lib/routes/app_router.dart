import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/app_constants.dart';
import '../screens/home/home_screen.dart';
import '../screens/history/history_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/results/results_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: AppConstants.homeRoute,
    routes: [
      GoRoute(
        path: AppConstants.homeRoute,
        builder: (context, state) => const HomeScreen(),
        pageBuilder:
            (context, state) => CustomTransitionPage(
              child: const HomeScreen(),
              transitionsBuilder: (
                context,
                animation,
                secondaryAnimation,
                child,
              ) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
      ),
      GoRoute(
        path: AppConstants.profileRoute,
        builder: (context, state) => const ProfileScreen(),
        pageBuilder:
            (context, state) => CustomTransitionPage(
              child: const ProfileScreen(),
              transitionsBuilder: (
                context,
                animation,
                secondaryAnimation,
                child,
              ) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
      ),
      GoRoute(
        path: AppConstants.historyRoute,
        builder: (context, state) => const HistoryScreen(),
        pageBuilder:
            (context, state) => CustomTransitionPage(
              child: const HistoryScreen(),
              transitionsBuilder: (
                context,
                animation,
                secondaryAnimation,
                child,
              ) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
      ),
      GoRoute(
        path: AppConstants.resultsRoute,
        builder:
            (context, state) =>
                ResultsScreen(scanData: state.extra as Map<String, dynamic>?),
        pageBuilder:
            (context, state) => CustomTransitionPage(
              child: ResultsScreen(
                scanData: state.extra as Map<String, dynamic>?,
              ),
              transitionsBuilder: (
                context,
                animation,
                secondaryAnimation,
                child,
              ) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
      ),
    ],
    errorBuilder:
        (context, state) => Scaffold(
          body: Center(
            child: Text(
              'Page not found: ${state.error}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ),
  );
}
