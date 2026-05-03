import 'dart:async';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'firebase_service.dart';

/// Centralized analytics service using Firebase Analytics.
/// All calls are unawaited and silently no-op when Firebase is not available,
/// so the app never crashes in environments without google-services.json.
class AnalyticsService {
  AnalyticsService._();

  /// Call when the app is initialized.
  static void appOpened(String locale) {
    if (!firebaseReady) return;
    final analytics = FirebaseAnalytics.instance;
    unawaited(analytics.logAppOpen());
    unawaited(analytics.setUserProperty(name: 'locale', value: locale));
  }

  /// Call when a user views a visa card or detail screen.
  static void visaViewed(String slug) {
    if (!firebaseReady) return;
    unawaited(FirebaseAnalytics.instance.logEvent(
      name: 'visa_viewed',
      parameters: {'slug': slug},
    ));
  }

  /// Call when the user switches languages.
  static void languageSwitched(String newLocale) {
    if (!firebaseReady) return;
    unawaited(FirebaseAnalytics.instance.logEvent(
      name: 'language_switched',
      parameters: {'new_locale': newLocale},
    ));
  }

  /// Call when a user successfully submits a lead application.
  static void leadSubmitted(String visaId) {
    if (!firebaseReady) return;
    unawaited(FirebaseAnalytics.instance.logEvent(
      name: 'lead_submitted',
      parameters: {'visa_id': visaId},
    ));
  }

  /// Call when a user taps a category filter on the visas screen.
  static void categoryFiltered(String categoryId) {
    if (!firebaseReady) return;
    unawaited(FirebaseAnalytics.instance.logEvent(
      name: 'category_filtered',
      parameters: {'category_id': categoryId},
    ));
  }
}
