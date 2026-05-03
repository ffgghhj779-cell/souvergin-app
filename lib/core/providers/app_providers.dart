import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../api/visa_repository.dart';
import '../models/visa.dart';
import '../models/visa_category.dart';
import '../services/app_persistence_service.dart';

// ── Raw SharedPreferences provider ───────────────────────────────────────────
// Overridden in main() with the pre-initialized instance.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in ProviderScope before use.',
  );
});

// ── Persistence service ───────────────────────────────────────────────────────
final appPersistenceProvider = Provider<AppPersistenceService>((ref) {
  return AppPersistenceService(ref.watch(sharedPreferencesProvider));
});

// ── Persisted locale ──────────────────────────────────────────────────────────
// Reads saved locale on first access. Writes back on every change.
// Replaces the old ephemeral StateProvider<Locale> that forgot its value.
class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() {
    final saved = ref.read(appPersistenceProvider).locale;
    return Locale(saved);
  }

  void setLocale(Locale locale) {
    ref.read(appPersistenceProvider).saveLocale(locale.languageCode);
    state = locale;
  }
}

final localeNotifierProvider =
    NotifierProvider<LocaleNotifier, Locale>(LocaleNotifier.new);

// ── Repository provider ───────────────────────────────────────────────────────
final visaRepositoryProvider = Provider<VisaRepository>((ref) {
  return VisaRepository(Supabase.instance.client);
});

// ── Categories ────────────────────────────────────────────────────────────────
final categoriesProvider =
    AsyncNotifierProvider<CategoriesNotifier, List<VisaCategory>>(
        CategoriesNotifier.new);

class CategoriesNotifier extends AsyncNotifier<List<VisaCategory>> {
  @override
  Future<List<VisaCategory>> build() =>
      ref.watch(visaRepositoryProvider).getCategories();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
        () => ref.read(visaRepositoryProvider).getCategories());
  }
}

// ── All visas ─────────────────────────────────────────────────────────────────
final visasProvider =
    AsyncNotifierProvider<VisasNotifier, List<Visa>>(VisasNotifier.new);

class VisasNotifier extends AsyncNotifier<List<Visa>> {
  @override
  Future<List<Visa>> build() => ref.watch(visaRepositoryProvider).getVisas();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
        () => ref.read(visaRepositoryProvider).getVisas());
  }
}

// ── Visa by slug ──────────────────────────────────────────────────────────────
final visaBySlugProvider =
    FutureProvider.family<Visa?, String>((ref, slug) async {
  return ref.watch(visaRepositoryProvider).getVisaBySlug(slug);
});

// ── Visas by category ─────────────────────────────────────────────────────────
final visasByCategoryProvider =
    FutureProvider.family<List<Visa>, String>((ref, categoryId) async {
  return ref.watch(visaRepositoryProvider).getVisasByCategory(categoryId);
});

// ── Active category filter ────────────────────────────────────────────────────
final activeCategoryFilterProvider = StateProvider<String>((ref) => 'all');

// ── Filtered visas (computed) ─────────────────────────────────────────────────
final filteredVisasProvider = Provider<AsyncValue<List<Visa>>>((ref) {
  final allVisas = ref.watch(visasProvider);
  final activeFilter = ref.watch(activeCategoryFilterProvider);
  return allVisas.whenData((visas) {
    if (activeFilter == 'all') return visas;
    return visas.where((v) => v.categoryId == activeFilter).toList();
  });
});

// ── Auth user ─────────────────────────────────────────────────────────────────
final authUserProvider = StreamProvider<User?>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange.map(
    (event) => event.session?.user,
  );
});
