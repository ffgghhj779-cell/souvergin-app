import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

import '../../features/home/screens/home_screen.dart';
import '../../features/visas/screens/visas_screen.dart';
import '../../features/visas/screens/visa_detail_screen.dart';
import '../../features/about/screens/about_screen.dart';
import '../../features/contact/screens/contact_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/splash/screens/splash_screen.dart';
import '../shell/main_shell.dart';
import '../providers/app_providers.dart';
import '../services/firebase_service.dart';

// ── Locale provider alias ─────────────────────────────────────────────────────
// Kept for backward-compat so widgets that import localeProvider still compile.
// New code should use localeNotifierProvider directly.
final localeProvider = localeNotifierProvider;

// ── Router provider ───────────────────────────────────────────────────────────
//
// State restoration design:
//   • SharedPreferences is pre-warmed in main() before runApp().
//   • appPersistenceProvider reads the saved route synchronously.
//   • If a saved route exists → initialLocation = saved route (skip splash).
//   • If no saved route (first launch) → initialLocation = '/splash'.
//   • MainShell.build() saves the current route on every navigation event.
//
// Performance design (IndexedStack):
//   • All 4 tab screens live in an IndexedStack inside MainShell.
//   • ShellRoute's `child` parameter is only used for SUB-routes (e.g. detail).
//   • Tab switching is 0ms — no unmount/mount, no network re-fetch.
final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authUserProvider);
  final persistence = ref.read(appPersistenceProvider);

  // Synchronous read — SharedPreferences is pre-warmed, zero async latency.
  final savedRoute = persistence.lastRoute;
  final isReturning = savedRoute != null && savedRoute.isNotEmpty;

  // First launch → show splash; returning user → skip splash entirely.
  final startLocation = isReturning ? savedRoute! : '/splash';

  return GoRouter(
    initialLocation: startLocation,
    debugLogDiagnostics: false,

    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final onSplash = state.matchedLocation == '/splash';
      final onLogin  = state.matchedLocation == '/login';

      if (onSplash) return null;                   // Splash manages itself
      if (isLoggedIn && onLogin) return '/home';   // Already authed → home
      return null;                                 // All public routes: allow
    },

    observers: [
      if (firebaseReady)
        FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
    ],

    routes: [
      // ── Splash (first-launch only) ────────────────────────────────────────
      GoRoute(
        path: '/splash',
        pageBuilder: (context, state) => _noTransition(state, const SplashScreen()),
      ),

      // ── Auth (modal slide-up) ─────────────────────────────────────────────
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => _slideUp(state, const LoginScreen()),
      ),

      // ── Main shell (persistent bottom nav + IndexedStack tabs) ────────────
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) => _tab(state, const HomeScreen()),
          ),
          GoRoute(
            path: '/visas',
            pageBuilder: (context, state) => _tab(state, const VisasScreen()),
            routes: [
              GoRoute(
                path: ':slug',
                pageBuilder: (context, state) => _detail(
                  state,
                  VisaDetailScreen(slug: state.pathParameters['slug']!),
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/about',
            pageBuilder: (context, state) => _tab(state, const AboutScreen()),
          ),
          GoRoute(
            path: '/contact',
            pageBuilder: (context, state) => _tab(state, const ContactScreen()),
          ),
        ],
      ),
    ],
  );
});

// ─────────────────────────────────────────────────────────────────────────────
// TRANSITION BUILDERS
// ─────────────────────────────────────────────────────────────────────────────

CustomTransitionPage<void> _noTransition(GoRouterState s, Widget child) =>
    CustomTransitionPage<void>(
      key: s.pageKey,
      child: child,
      transitionsBuilder: (_, __, ___, c) => c,
      transitionDuration: Duration.zero,
    );

CustomTransitionPage<void> _tab(GoRouterState s, Widget child) =>
    CustomTransitionPage<void>(
      key: s.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 280),
      reverseTransitionDuration: const Duration(milliseconds: 220),
      transitionsBuilder: (_, anim, secAnim, child) {
        final enter = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic, reverseCurve: Curves.easeInCubic);
        final exit  = CurvedAnimation(parent: secAnim, curve: Curves.easeInCubic);
        return FadeTransition(
          opacity: Tween<double>(begin: 1.0, end: 0.0).animate(exit),
          child: FadeTransition(
            opacity: enter,
            child: SlideTransition(
              position: Tween<Offset>(begin: const Offset(0, 0.03), end: Offset.zero).animate(enter),
              child: child,
            ),
          ),
        );
      },
    );

CustomTransitionPage<void> _detail(GoRouterState s, Widget child) =>
    CustomTransitionPage<void>(
      key: s.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 380),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (_, anim, secAnim, child) {
        final enter = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic, reverseCurve: Curves.easeInQuart);
        final dim   = CurvedAnimation(parent: secAnim, curve: Curves.easeInCubic);
        return Stack(children: [
          FadeTransition(opacity: Tween<double>(begin: 1.0, end: 0.85).animate(dim), child: const SizedBox.expand()),
          SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(enter),
            child: FadeTransition(
              opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(parent: anim, curve: const Interval(0.0, 0.5, curve: Curves.easeOut)),
              ),
              child: child,
            ),
          ),
        ]);
      },
    );

CustomTransitionPage<void> _slideUp(GoRouterState s, Widget child) =>
    CustomTransitionPage<void>(
      key: s.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 420),
      reverseTransitionDuration: const Duration(milliseconds: 320),
      transitionsBuilder: (_, anim, __, child) {
        final curve = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic, reverseCurve: Curves.easeInCubic);
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(curve),
          child: child,
        );
      },
    );
