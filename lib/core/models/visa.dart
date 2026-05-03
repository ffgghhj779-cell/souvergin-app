import 'package:equatable/equatable.dart';

/// Mirrors the web's `Visa` type from lib/api.ts
class Visa extends Equatable {
  final String id;
  final String slug;
  final String categoryId;
  final String titleEn;
  final String titleAr;
  final String descShortEn;
  final String descShortAr;
  final String descFullEn;
  final String descFullAr;
  final double? price;
  final String currency;
  final String durationEn;
  final String durationAr;
  final List<String> requirementsEn;
  final List<String> requirementsAr;
  final String image;
  final bool isActive;

  const Visa({
    required this.id,
    required this.slug,
    required this.categoryId,
    required this.titleEn,
    required this.titleAr,
    required this.descShortEn,
    required this.descShortAr,
    required this.descFullEn,
    required this.descFullAr,
    this.price,
    required this.currency,
    required this.durationEn,
    required this.durationAr,
    required this.requirementsEn,
    required this.requirementsAr,
    required this.image,
    required this.isActive,
  });

  factory Visa.fromJson(Map<String, dynamic> json) => Visa(
        id: (json['id'] as String?) ?? '',
        slug: (json['slug'] as String?) ?? '',
        categoryId: (json['categoryId'] as String?) ?? '',
        titleEn: (json['title_en'] as String?) ?? '',
        titleAr: (json['title_ar'] as String?) ?? '',
        descShortEn: (json['desc_short_en'] as String?) ?? '',
        descShortAr: (json['desc_short_ar'] as String?) ?? '',
        descFullEn: (json['desc_full_en'] as String?) ?? '',
        descFullAr: (json['desc_full_ar'] as String?) ?? '',
        price: (json['price'] as num?)?.toDouble(),
        currency: (json['currency'] as String?) ?? 'USD',
        durationEn: (json['duration_en'] as String?) ?? '',
        durationAr: (json['duration_ar'] as String?) ?? '',
        requirementsEn:
            List<String>.from(json['requirements_en'] as List? ?? []),
        requirementsAr:
            List<String>.from(json['requirements_ar'] as List? ?? []),
        image: (json['image'] as String?) ?? '',
        isActive: (json['is_active'] as bool?) ?? true,
      );

  String localizedTitle(String locale) =>
      locale == 'ar' ? titleAr : titleEn;
  String localizedDescShort(String locale) =>
      locale == 'ar' ? descShortAr : descShortEn;
  String localizedDescFull(String locale) =>
      locale == 'ar' ? descFullAr : descFullEn;
  String localizedDuration(String locale) =>
      locale == 'ar' ? durationAr : durationEn;
  List<String> localizedRequirements(String locale) =>
      locale == 'ar' ? requirementsAr : requirementsEn;

  @override
  List<Object?> get props => [id, slug];

  // ── Fallback mock ─────────────────────────────────────────────────────────
  static Visa get mock => const Visa(
        id: 'visa-1',
        slug: 'dubai-premium-tourist-visa',
        categoryId: 'cat-1',
        titleEn: 'Dubai Premium Tourist Visa',
        titleAr: 'تأشيرة دبي السياحية المميزة',
        descShortEn: 'A fast-track 30-day tourist visa to the UAE.',
        descShortAr: 'تأشيرة سياحية سريعة لمدة 30 يوماً للإمارات.',
        descFullEn:
            'Experience the magic of Dubai with our hassle-free premium tourist visa. Processing takes only 48 hours.',
        descFullAr:
            'عش سحر دبي مع تأشيرتنا السياحية المميزة. تستغرق المعالجة 48 ساعة فقط.',
        price: 250,
        currency: 'USD',
        durationEn: '30 Days',
        durationAr: '30 يوم',
        requirementsEn: ['Passport copy', 'Personal photo'],
        requirementsAr: ['صورة الجواز', 'صورة شخصية'],
        image:
            'https://images.unsplash.com/photo-1512453979798-5ea266f8880c?q=80&w=1200&auto=format&fit=crop',
        isActive: true,
      );
}
