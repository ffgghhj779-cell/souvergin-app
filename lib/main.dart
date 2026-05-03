import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'core/services/secure_local_storage.dart';
import 'core/services/firebase_service.dart';

/// ── 🚀 PERFORMANCE PROFILING GUIDE ─────────────────────────────────────────
/// To measure true 120 FPS performance, you MUST run in profile mode.
/// Debug mode contains assertions and logging that will throttle the engine.
///
/// Run: flutter run --profile --enable-impeller
/// Then open DevTools -> Performance tab to view the frame render chart.
/// ──────────────────────────────────────────────────────────────────────────

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Guard: Detect missing --dart-define at startup ───────────────────────
  // If SUPABASE_URL is empty the app will show a cryptic network error.
  // This assertion fires immediately in debug mode with a clear message.
  assert(
    AppConstants.supabaseUrl.isNotEmpty,
    '\n\n'
    '══════════════════════════════════════════════════════\n'
    '  SUPABASE_URL is not set!\n'
    '  Run with:\n'
    '  flutter run \\\n'
    '    --dart-define=SUPABASE_URL=https://your-project.supabase.co \\\n'
    '    --dart-define=SUPABASE_ANON_KEY=your-anon-key\n'
    '  Or press F5 in VS Code (launch.json is pre-configured).\n'
    '══════════════════════════════════════════════════════\n',
  );

  // ── Initialize Firebase & Crashlytics ──────────────────────────────────────
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

  // Lock to portrait orientation for premium mobile UX
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Status bar style – dark content on light, light on dark sections
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppConstants.colorBackground,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // ── Request highest available refresh rate (120Hz) ──────────────────────────
  // This works in tandem with the AndroidManifest RequestedDisplayModeId hint.
  // The manifest hint fires at Activity launch; this call confirms it at runtime.
  try {
    await FlutterDisplayMode.setHighRefreshRate();
  } catch (_) {
    // Device may not support multiple display modes — safe to ignore.
  }

  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
    // Tokens stored in Android Keystore / iOS Keychain, not SharedPreferences.
    authOptions: const FlutterAuthClientOptions(
      localStorage: SecureLocalStorage(),
    ),
  );

  runApp(
    const ProviderScope(
      child: SovereignMaaregApp(),
    ),
  );
}

class SovereignMaaregApp extends ConsumerWidget {
  const SovereignMaaregApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final locale = ref.watch(localeProvider);

    return HeroControllerScope(
      controller: MaterialApp.createMaterialHeroController(), // Under the hood uses MaterialRectArcTween for premium arc paths
      child: MaterialApp.router(
      title: 'Sovereign Maareg Fund',
      debugShowCheckedModeBanner: false,
      theme: locale.languageCode == 'ar' ? AppTheme.darkArabic() : AppTheme.dark(),
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
      // ── Global scroll behaviour ─────────────────────────────────────────────
      // Removes the default Android overscroll glow and enforces
      // BouncingScrollPhysics globally so every scrollable feels iOS-premium.
      scrollBehavior: const _PremiumScrollBehavior(),
      builder: (context, child) {
        // Ensure text always scales within safe bounds
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

/// Removes the Android overscroll glow indicator and enforces
/// [BouncingScrollPhysics] on every scrollable widget in the app.
/// This is the single-line fix for the "heavy, stiff" scroll feel.
class _PremiumScrollBehavior extends ScrollBehavior {
  const _PremiumScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics(
      parent: AlwaysScrollableScrollPhysics(),
    );
  }

  /// Remove the stretch/glow overscroll indicator entirely.
  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}
