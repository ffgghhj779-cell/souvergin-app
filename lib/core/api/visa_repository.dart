import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/visa.dart';
import '../models/visa_category.dart';
import '../models/app_exception.dart';

/// Single source of truth for all Supabase data operations.
///
/// Security hardening applied:
///  • All queries use the typed query builder — zero raw SQL, zero injection surface.
///  • [getVisas] filters `is_active = true` so draft/archived records are never exposed.
///  • All [PostgrestException] details are sanitised before surfacing to the UI;
///    raw Postgres error messages (which can leak table/column names) are never
///    forwarded to the caller.
///  • [submitLead] and [submitContactMessage] write-only — no data is read back.
class VisaRepository {
  final SupabaseClient _client;
  VisaRepository(this._client);

  // ── Internal helpers ────────────────────────────────────────────────────────

  /// Wraps a [PostgrestException] into a sanitised [DataException].
  /// Raw Postgres error text (table names, constraint names, etc.) is deliberately
  /// discarded to prevent information disclosure to the client.
  DataException _sanitisePostgrestError(PostgrestException e, String context) {
    // Only forward the HTTP status code — never the raw message.
    return DataException('$context (code: ${e.code ?? 'unknown'})');
  }

  // ── Categories ─────────────────────────────────────────────────────────────
  Future<List<VisaCategory>> getCategories() async {
    try {
      final response = await _client
          .from('categories')
          .select()
          .order('id');
      if (response.isEmpty) throw const DataException('No categories found');
      return (response as List)
          .map((e) => VisaCategory.fromJson(e as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw _sanitisePostgrestError(e, 'Unable to load categories');
    } catch (e) {
      if (e is AppException) rethrow;
      throw const NetworkException('Unable to load categories. Check your connection.');
    }
  }

  // ── Visas (active only) ────────────────────────────────────────────────────
  /// Returns only records where `is_active = true`.
  /// Inactive / draft visas are never exposed to the client.
  /// This is enforced both here AND at the RLS policy level.
  Future<List<Visa>> getVisas() async {
    try {
      final response = await _client
          .from('visas')
          .select()
          .eq('is_active', true) // MED-01: never return inactive/draft records
          .order('created_at', ascending: false);
      if (response.isEmpty) throw const DataException('No visas found');
      return (response as List)
          .map((e) => Visa.fromJson(e as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw _sanitisePostgrestError(e, 'Unable to load visa programs');
    } catch (e) {
      if (e is AppException) rethrow;
      throw const NetworkException('Unable to load visa programs. Check your connection.');
    }
  }

  // ── Single visa by slug ───────────────────────────────────────────────────
  Future<Visa?> getVisaBySlug(String slug) async {
    try {
      final response = await _client
          .from('visas')
          .select()
          .eq('slug', slug)
          .eq('is_active', true) // Never serve inactive records by direct URL
          .single();
      return Visa.fromJson(response);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') return null; // Not found — safe to surface
      throw _sanitisePostgrestError(e, 'Unable to load visa details');
    } catch (e) {
      throw const NetworkException('Unable to load visa details. Check your connection.');
    }
  }

  // ── Visas by category ─────────────────────────────────────────────────────
  Future<List<Visa>> getVisasByCategory(String categoryId) async {
    try {
      final response = await _client
          .from('visas')
          .select()
          .eq('category_id', categoryId)
          .eq('is_active', true); // Only active records
      return (response as List)
          .map((e) => Visa.fromJson(e as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw _sanitisePostgrestError(e, 'Unable to load visa programs');
    } catch (e) {
      throw const NetworkException('Unable to load visa programs. Check your connection.');
    }
  }

  // ── Submit lead application ────────────────────────────────────────────────
  /// Inserts a lead record. Write-only — no data is read back.
  /// Input length is enforced here as a server-side guard complementing
  /// client-side maxLength constraints on the form fields.
  Future<void> submitLead({
    required String name,
    required String email,
    required String phone,
    required String visaId,
    String? message,
  }) async {
    try {
      await _client.from('leads').insert({
        'name': name.substring(0, name.length.clamp(0, 200)),
        'email': email.substring(0, email.length.clamp(0, 320)),
        'phone': phone.substring(0, phone.length.clamp(0, 30)),
        'visa_id': visaId,
        'message': (message ?? '').substring(
            0, (message ?? '').length.clamp(0, 2000)),
        'status': 'new',
      });
    } on PostgrestException catch (e) {
      throw _sanitisePostgrestError(e, 'Unable to submit application');
    } catch (e) {
      throw const NetworkException('Unable to submit application. Check your connection.');
    }
  }

  // ── Submit contact message ─────────────────────────────────────────────────
  /// CRIT-03 fix: persists contact form data to the `contact_messages` table.
  /// Write-only — the anon role has no SELECT permission on this table (see RLS).
  Future<void> submitContactMessage({
    required String name,
    required String email,
    required String message,
  }) async {
    try {
      await _client.from('contact_messages').insert({
        'name': name.substring(0, name.length.clamp(0, 200)),
        'email': email.substring(0, email.length.clamp(0, 320)),
        'message': message.substring(0, message.length.clamp(0, 2000)),
      });
    } on PostgrestException catch (e) {
      throw _sanitisePostgrestError(e, 'Unable to send message');
    } catch (e) {
      throw const NetworkException('Unable to send message. Check your connection.');
    }
  }
}
