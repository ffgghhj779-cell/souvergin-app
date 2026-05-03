import 'package:equatable/equatable.dart';

/// Mirrors the web's `VisaCategory` type from lib/api.ts
class VisaCategory extends Equatable {
  final String id;
  final String slug;
  final String titleEn;
  final String titleAr;
  final String descEn;
  final String descAr;
  final String icon;

  const VisaCategory({
    required this.id,
    required this.slug,
    required this.titleEn,
    required this.titleAr,
    required this.descEn,
    required this.descAr,
    required this.icon,
  });

  factory VisaCategory.fromJson(Map<String, dynamic> json) => VisaCategory(
        id: (json['id'] as String?) ?? '',
        slug: (json['slug'] as String?) ?? '',
        titleEn: (json['title_en'] as String?) ?? '',
        titleAr: (json['title_ar'] as String?) ?? '',
        descEn: (json['desc_en'] as String?) ?? '',
        descAr: (json['desc_ar'] as String?) ?? '',
        icon: (json['icon'] as String?) ?? '',
      );

  String localizedTitle(String locale) =>
      locale == 'ar' ? titleAr : titleEn;

  String localizedDesc(String locale) =>
      locale == 'ar' ? descAr : descEn;

  @override
  List<Object?> get props => [id, slug];

  // ── Fallback mock ──────────────────────────────────────────────────────────
  static VisaCategory get mock => const VisaCategory(
        id: 'cat-1',
        slug: 'tourist-visas',
        titleEn: 'Tourist Visas',
        titleAr: 'تأشيرات سياحية',
        descEn: 'Explore the world with our fast-track tourist visas.',
        descAr: 'اكتشف العالم مع تأشيراتنا السياحية السريعة.',
        icon: 'Plane',
      );
}
