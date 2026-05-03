import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Stores Supabase auth tokens in the platform's secure hardware-backed store
/// (Android Keystore / iOS Keychain) instead of cleartext SharedPreferences.
///
/// Pass an instance to [Supabase.initialize] via [FlutterAuthClientOptions].
class SecureLocalStorage implements LocalStorage {
  const SecureLocalStorage();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true, // AES-256 via Android Keystore (API 23+)
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  static const _key = 'supabase_session';

  @override
  Future<void> initialize() async {
    // No-op: FlutterSecureStorage initialises lazily on first read/write.
  }

  @override
  Future<String?> accessToken() async {
    try {
      final raw = await _storage.read(key: _key);
      if (raw == null) return null;
      // The stored value is the full session JSON; parse out the access token.
      return raw;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> hasAccessToken() async {
    try {
      return await _storage.containsKey(key: _key);
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> persistSession(String persistSessionString) async {
    await _storage.write(key: _key, value: persistSessionString);
  }

  @override
  Future<void> removePersistedSession() async {
    await _storage.delete(key: _key);
  }
}
