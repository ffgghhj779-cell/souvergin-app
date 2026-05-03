import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/home/screens/home_screen.dart';
import '../../features/visas/screens/visas_screen.dart';
import '../../features/visas/screens/visa_detail_screen.dart';
import '../../features/about/screens/about_screen.dart';
import '../../features/contact/screens/contact_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/splash/screens/splash_screen.dart';
import '../shell/main_shell.dart';
import '../providers/app_providers.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import '../services/firebase_service.dart';

// ── Locale provider – drives RTL/LTR directions and font choices ─────────────
final localeProvider = StateProvider<Locale>((ref) => const Locale('en'));

// ── Router provider ──────────────────────────────────────────────────────────
//
// HIGH-02 fix: A redirect callback now evaluates auth state on every navigation.
// The app content (home, visas, about, contact) remains publicly accessible —
// this is correct for a public-facing visa catalog that accepts anonymous leads.
//
// The redirect rules are:
//   1. /splash  → always allowed (handles its own navigation to /home)
//   2. /login   → redirects to /home if the user is already authenticated
//                 (prevents an already-logged-in admin from seeing the login form)
//   3. All other routes → publicly accessible, no auth required
//
// To gate routes behind auth in the future, add a rule here:
//   if (!isLoggedIn && protectedPaths.contains(state.matchedLocation)) return '/login';
final appRouterProvider = Provider<GoRouter>((ref) {
  // Watch auth state — the Provider recomputes when the auth stream emits,
  // which causes GoRouter to re-evaluate its redirect callback automatically.
  final authState = ref.watch(authUserProvider);

  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: false,

    // ── Auth redirect guard ─────────────────────────────────────────────────
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final onSplash = state.matchedLocation == '/splash';
      final onLogin = state.matchedLocation == '/login';

      // Splash manages its own routing internally — always allow.
      if (onSplash) return null;

      // Already authenticated → skip the login screen.
      if (isLoggedIn && onLogin) return '/home';

      // All other routes are publicly accessible.
      return null;
    },

    observers: [
      if (firebaseReady)
        FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
    ],
    routes: [
      // Splash (no shell)
      GoRoute(
        path: '/splash',
        pageBuilder: (context, state) => _buildNoTransition(
          state,
          const SplashScreen(),
        ),
      ),

      // Auth routes (no bottom bar) — slide up from bottom
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => _slideUpTransition(
          state,
          const LoginScreen(),
        ),
      ),

      // Main shell with persistent bottom nav
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) => _tabTransition(
              state,
              const HomeScreen(),
            ),
          ),
          GoRoute(
            path: '/visas',
            pageBuilder: (context, state) => _tabTransition(
              state,
              const VisasScreen(),
            ),
            routes: [
              GoRoute(
                path: ':slug',
                pageBuilder: (context, state) => _detailTransition(
                  state,
                  VisaDetailScreen(slug: state.pathParameters['slug']!),
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/about',
            pageBuilder: (context, state) => _tabTransition(
              state,
              const AboutScreen(),
            ),
          ),
          GoRoute(
            path: '/contact',
            pageBuilder: (context, state) => _tabTransition(
              state,
              const ContactScreen(),
            ),
          ),
        ],
      ),
    ],
  );
});

// ─────────────────────────────────────────────────────────────────────────────
// TRANSITION BUILDERS
// ─────────────────────────────────────────────────────────────────────────────

/// Instant transition — used for the splash screen only.
CustomTransitionPage<void> _buildNoTransition(
    GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (_, __, ___, child) => child,
    transitionDuration: Duration.zero,
  );
}

/// Tab switch transition — subtle fade + micro upward slide.
CustomTransitionPage<void> _tabTransition(
    GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 280),
    reverseTransitionDuration: const Duration(milliseconds: 220),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final enterCurve = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      final exitCurve = CurvedAnimation(
        parent: secondaryAnimation,
        curve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: Tween<double>(begin: 1.0, end: 0.0).animate(exitCurve),
        child: FadeTransition(
          opacity: enterCurve,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 0.03),
              end: Offset.zero,
            ).animate(enterCurve),
            child: child,
          ),
        ),
      );
    },
  );
}

/// Detail-view transition — confident slide up with easeOutCubic.
CustomTransitionPage<void> _detailTransition(
    GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 380),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final enterCurve = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInQuart,
      );
      final dimCurve = CurvedAnimation(
        parent: secondaryAnimation,
        curve: Curves.easeInCubic,
      );
      return Stack(
        children: [
          FadeTransition(
            opacity: Tween<double>(begin: 1.0, end: 0.85).animate(dimCurve),
            child: ScaleTransition(
              scale: Tween<double>(begin: 1.0, end: 0.97).animate(dimCurve),
              child: const SizedBox.expand(),
            ),
          ),
          SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 0.08),
              end: Offset.zero,
            ).animate(enterCurve),
            child: FadeTransition(
              opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
                ),
              ),
              child: child,
            ),
          ),
        ],
      );
    },
  );
}

/// Modal/auth slide-up transition — rises from the bottom of the screen.
CustomTransitionPage<void> _slideUpTransition(
    GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 420),
    reverseTransitionDuration: const Duration(milliseconds: 320),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curve = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.0, 1.0),
          end: Offset.zero,
        ).animate(curve),
        child: child,
      );
    },
  );
}
