import 'package:shared_preferences/shared_preferences.dart';

/// Single source of truth for all local persistence.
///
/// Responsibilities:
///  • Last active route  (instant resume on app reopen)
///  • Locale preference  (AR / EN survives force-kill)
///  • Per-visa lead form drafts  (keyed by visa slug)
///  • Contact form draft
///
/// All reads are synchronous after [SharedPreferences.getInstance()] is
/// awaited in [main]. No async latency on the hot path.
class AppPersistenceService {
  final SharedPreferences _prefs;
  AppPersistenceService(this._prefs);

  // ── Keys ──────────────────────────────────────────────────────────────────
  static const _kLastRoute   = 'app_last_route';
  static const _kLocale      = 'app_locale';

  // ── Route ─────────────────────────────────────────────────────────────────
  String? get lastRoute => _prefs.getString(_kLastRoute);

  void saveRoute(String route) {
    // Never persist the splash itself — it is transient.
    if (route == '/splash' || route.isEmpty) return;
    _prefs.setString(_kLastRoute, route);
  }

  // ── Locale ────────────────────────────────────────────────────────────────
  String get locale => _prefs.getString(_kLocale) ?? 'en';
  void saveLocale(String code) => _prefs.setString(_kLocale, code);

  // ── Per-visa lead form drafts ──────────────────────────────────────────────
  // Keys are namespaced by visa slug so each visa has an isolated draft.
  Map<String, String> getLeadDraft(String visaSlug) => {
        'name':    _prefs.getString('lead_${visaSlug}_name')    ?? '',
        'email':   _prefs.getString('lead_${visaSlug}_email')   ?? '',
        'phone':   _prefs.getString('lead_${visaSlug}_phone')   ?? '',
        'message': _prefs.getString('lead_${visaSlug}_message') ?? '',
      };

  void saveLeadField(String visaSlug, String field, String value) =>
      _prefs.setString('lead_${visaSlug}_$field', value);

  /// Called after a successful submission to wipe the draft.
  void clearLeadDraft(String visaSlug) {
    for (final field in ['name', 'email', 'phone', 'message']) {
      _prefs.remove('lead_${visaSlug}_$field');
    }
  }

  // ── Contact form draft ────────────────────────────────────────────────────
  Map<String, String> get contactDraft => {
        'name':    _prefs.getString('contact_name')    ?? '',
        'email':   _prefs.getString('contact_email')   ?? '',
        'message': _prefs.getString('contact_message') ?? '',
      };

  void saveContactField(String field, String value) =>
      _prefs.setString('contact_$field', value);

  void clearContactDraft() {
    for (final field in ['name', 'email', 'message']) {
      _prefs.remove('contact_$field');
    }
  }
}
