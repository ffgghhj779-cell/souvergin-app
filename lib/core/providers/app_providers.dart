import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../api/visa_repository.dart';
import '../models/visa.dart';
import '../models/visa_category.dart';

// ── Repository provider ────────────────────────────────────────────────────
final visaRepositoryProvider = Provider<VisaRepository>((ref) {
  return VisaRepository(Supabase.instance.client);
});

// ── Categories ──────────────────────────────────────────────────────────────
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

// ── All visas ────────────────────────────────────────────────────────────────
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

// ── Visa by slug ─────────────────────────────────────────────────────────────
final visaBySlugProvider =
    FutureProvider.family<Visa?, String>((ref, slug) async {
  return ref.watch(visaRepositoryProvider).getVisaBySlug(slug);
});

// ── Visas by category ─────────────────────────────────────────────────────
final visasByCategoryProvider =
    FutureProvider.family<List<Visa>, String>((ref, categoryId) async {
  return ref.watch(visaRepositoryProvider).getVisasByCategory(categoryId);
});

// ── Active category filter (Visas list tab bar) ───────────────────────────
final activeCategoryFilterProvider = StateProvider<String>((ref) => 'all');

// ── Filtered visas (computed) ─────────────────────────────────────────────
final filteredVisasProvider = Provider<AsyncValue<List<Visa>>>((ref) {
  final allVisas = ref.watch(visasProvider);
  final activeFilter = ref.watch(activeCategoryFilterProvider);

  return allVisas.whenData((visas) {
    if (activeFilter == 'all') return visas;
    return visas.where((v) => v.categoryId == activeFilter).toList();
  });
});

// ── Auth user ────────────────────────────────────────────────────────────────
final authUserProvider = StreamProvider<User?>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange.map(
    (event) => event.session?.user,
  );
});
