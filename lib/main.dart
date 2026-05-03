import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'core/services/secure_local_storage.dart';
import 'core/services/firebase_service.dart';
import 'core/providers/app_providers.dart';

/// 🚀 PERFORMANCE PROFILING GUIDE
/// Run: flutter run --profile --enable-impeller
/// Then open DevTools → Performance tab to view the frame chart.

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  assert(
    AppConstants.supabaseUrl.isNotEmpty,
    '\n\n'
    '══════════════════════════════════════════════════════\n'
    '  SUPABASE_URL is not set!\n'
    '  Run: flutter run --dart-define-from-file=.env\n'
    '  Or press F5 in VS Code (launch.json is pre-configured).\n'
    '══════════════════════════════════════════════════════\n',
  );

  // ── SharedPreferences: awaited BEFORE runApp ──────────────────────────────
  // The pre-warmed instance is injected via ProviderScope so that
  // AppPersistenceService resolves synchronously on the very first frame.
  // This is the key to zero-latency state restoration.
  final prefs = await SharedPreferences.getInstance();

  // ── Firebase & Crashlytics ────────────────────────────────────────────────
  try {
    await Firebase.initializeApp();
    setFirebaseReady();
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  } catch (e) {
    debugPrint('Firebase init skipped (missing google-services.json?): $e');
  }

  // Portrait-only orientation lock
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppConstants.colorBackground,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Request 120Hz display mode
  try {
    await FlutterDisplayMode.setHighRefreshRate();
  } catch (_) {}

  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
    authOptions: const FlutterAuthClientOptions(
      localStorage: SecureLocalStorage(),
    ),
  );

  runApp(
    ProviderScope(
      overrides: [
        // Inject the pre-warmed SharedPreferences — all persistence reads
        // in this session are now synchronous, zero-latency.
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const SovereignMaaregApp(),
    ),
  );
}

class SovereignMaaregApp extends ConsumerWidget {
  const SovereignMaaregApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    // Watch the persisted locale notifier instead of the old ephemeral provider
    final locale = ref.watch(localeNotifierProvider);

    return HeroControllerScope(
      controller: MaterialApp.createMaterialHeroController(),
      child: MaterialApp.router(
        title: 'Sovereign Maareg Fund',
        debugShowCheckedModeBanner: false,
        theme: locale.languageCode == 'ar'
            ? AppTheme.darkArabic()
            : AppTheme.dark(),
        routerConfig: router,
        locale: locale,
        supportedLocales: const [
          Locale('en'),
          Locale('ar'),
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        scrollBehavior: const _PremiumScrollBehavior(),
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.noScaling,
            ),
            child: child!,
          );
        },
      ),
    );
  }
}

/// Removes the Android overscroll glow and enforces bouncing scroll physics.
class _PremiumScrollBehavior extends ScrollBehavior {
  const _PremiumScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics(
      parent: AlwaysScrollableScrollPhysics(),
    );
  }

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}
