import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/router/app_router.dart';
import '../../../core/models/app_exception.dart';
import '../../../shared/widgets/app_buttons.dart';
import '../../../shared/widgets/shimmer_card.dart';
import '../../../shared/widgets/error_state_widget.dart';
import '../widgets/lead_form_sheet.dart';

class VisaDetailScreen extends ConsumerWidget {
  final String slug;
  const VisaDetailScreen({super.key, required this.slug});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider).languageCode;
    final visaAsync = ref.watch(visaBySlugProvider(slug));
    final isAr = locale == 'ar';

    return Scaffold(
      backgroundColor: AppConstants.colorBackground,
      body: visaAsync.when(
        loading: () => const _DetailSkeleton(),
        error: (e, _) => ErrorStateWidget(
          locale: locale,
          message: e is AppException ? e.message : null,
          onRetry: () => ref.invalidate(visaBySlugProvider(slug)),
        ),
        data: (visa) {
          if (visa == null) {
            return Center(
              child: Text(
                isAr ? 'البرنامج غير موجود' : 'Program not found',
                style: const TextStyle(color: AppConstants.colorBodyText),
              ),
            );
          }

          return Stack(
            children: [
              CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // ── Hero image + back button ──────────────────────────
                  SliverAppBar(
                    expandedHeight: 300,
                    pinned: true,
                    backgroundColor: AppConstants.colorBackground,
                    leading: Padding(
                      padding: const EdgeInsets.all(8),
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(
                                AppConstants.radiusFull),
                          ),
                          child: const Icon(Icons.arrow_back_rounded,
                              color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Hero tag must match visa_card.dart 'visa-hero-${visa.slug}'
                          Hero(
                            tag: 'visa-hero-${visa.slug}',
                            child: CachedNetworkImage(
                              imageUrl: visa.image,
                              fit: BoxFit.cover,
                              memCacheWidth: 800,
                              memCacheHeight: 800,
                              placeholder: (_, __) =>
                                  const ShimmerCard(height: 300),
                              errorWidget: (_, __, ___) => Container(
                                color: AppConstants.colorCard,
                              ),
                            ),
                          ),
                          // Gradient
                          Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Color(0xAA000000),
                                  AppConstants.colorBackground,
                                ],
                                stops: [0.4, 0.75, 1.0],
                              ),
                            ),
                          ),
                          // Top badge
                          const Positioned(
                            top: 90,
                            left: 20,
                            child: MonoTag(
                              label: 'Verified Route',
                              color: AppConstants.colorAccent,
                              icon: Icons.verified_rounded,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── Content ────────────────────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.spacingLg),
                      child: Column(
                        crossAxisAlignment: isAr
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          // Jurisdiction tag
                          Row(
                            mainAxisAlignment: isAr
                                ? MainAxisAlignment.end
                                : MainAxisAlignment.start,
                            children: [
                              const Icon(Icons.location_on_rounded,
                                  size: 13, color: AppConstants.colorEmerald),
                              const SizedBox(width: 4),
                              Text(
                                isAr ? 'نطاق الاختصاص' : 'Jurisdiction',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.white60,
                                  letterSpacing: 1.5,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          // Title
                          Text(
                            visa.localizedTitle(locale),
                            textAlign: isAr ? TextAlign.right : TextAlign.left,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.8,
                              height: 1.2,
                            ),
                          ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05),

                          const SizedBox(height: 16),

                          // Meta chips row
                          Wrap(
                            spacing: 10,
                            runSpacing: 8,
                            children: [
                              _MetaChip(
                                icon: Icons.schedule_rounded,
                                label: isAr ? 'المدة' : 'Duration',
                                value: visa.localizedDuration(locale),
                              ),
                              if (visa.price != null)
                                _MetaChip(
                                  icon: Icons.attach_money_rounded,
                                  label: isAr ? 'رأس المال' : 'Capital',
                                  value:
                                      '${visa.price!.toInt()} ${visa.currency}',
                                  valueColor: AppConstants.colorEmerald,
                                ),
                            ],
                          ).animate(delay: 100.ms).fadeIn(duration: 400.ms),

                          const SizedBox(height: AppConstants.spacingLg),

                          // Short description
                          Text(
                            visa.localizedDescShort(locale),
                            textAlign: isAr ? TextAlign.right : TextAlign.left,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.white70,
                              height: 1.7,
                            ),
                          ).animate(delay: 150.ms).fadeIn(duration: 400.ms),

                          const SizedBox(height: AppConstants.spacingLg),

                          // Full description
                          if (visa.localizedDescFull(locale).isNotEmpty) ...[
                            _SectionHeader(
                                label: isAr ? 'التفاصيل الكاملة' : 'Full Details'),
                            const SizedBox(height: 10),
                            Text(
                              visa.localizedDescFull(locale),
                              textAlign:
                                  isAr ? TextAlign.right : TextAlign.left,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppConstants.colorBodyText,
                                height: 1.75,
                              ),
                            ).animate(delay: 200.ms).fadeIn(duration: 400.ms),
                            const SizedBox(height: AppConstants.spacingLg),
                          ],

                          // Requirements
                          if (visa.localizedRequirements(locale).isNotEmpty) ...[
                            _SectionHeader(
                                label: isAr ? 'المستندات المطلوبة' : 'Requirements'),
                            const SizedBox(height: 12),
                            ...visa.localizedRequirements(locale).asMap().entries.map(
                              (e) => _RequirementRow(
                                index: e.key + 1,
                                label: e.value,
                                isAr: isAr,
                              ).animate(
                                delay: Duration(milliseconds: 220 + e.key * 60),
                              ).fadeIn(duration: 350.ms).slideX(begin: 0.04),
                            ),
                            const SizedBox(height: AppConstants.spacingLg),
                          ],

                          // Spacer for sticky button
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // ── Sticky Apply Button ─────────────────────────────────────
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.fromLTRB(
                    AppConstants.spacingLg,
                    AppConstants.spacingMd,
                    AppConstants.spacingLg,
                    AppConstants.spacingMd +
                        MediaQuery.of(context).padding.bottom,
                  ),
                  decoration: BoxDecoration(
                    color: AppConstants.colorBackground,
                    border: const Border(
                      top: BorderSide(color: AppConstants.colorBorder),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.4),
                        blurRadius: 20,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: PrimaryButton(
                    label: isAr ? 'تأكيد الطلب' : 'Submit Application',
                    icon: Icons.arrow_forward_rounded,
                    iconTrailing: true,
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      showLeadFormSheet(
                        context,
                        visaId: visa.id,
                        visaTitle: visa.localizedTitle(locale),
                        locale: locale,
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: AppConstants.colorBodyText,
        letterSpacing: 2,
        fontFamily: 'monospace',
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color valueColor;

  const _MetaChip({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppConstants.colorCard,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: AppConstants.colorBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppConstants.colorBodyText),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 9,
                      color: AppConstants.colorBodyText,
                      letterSpacing: 1.2,
                      fontFamily: 'monospace')),
              Text(value,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: valueColor)),
            ],
          ),
        ],
      ),
    );
  }
}

class _RequirementRow extends StatelessWidget {
  final int index;
  final String label;
  final bool isAr;

  const _RequirementRow({
    required this.index,
    required this.label,
    required this.isAr,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppConstants.colorCard,
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          border: Border.all(color: AppConstants.colorBorder),
        ),
        child: Row(
          children: isAr
              ? [
                  Expanded(
                    child: Text(label,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white70,
                            height: 1.4)),
                  ),
                  const SizedBox(width: 10),
                  Text('$index',
                      style: const TextStyle(
                          fontSize: 11,
                          color: AppConstants.colorPrimary,
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.w700)),
                ]
              : [
                  Text('$index',
                      style: const TextStyle(
                          fontSize: 11,
                          color: AppConstants.colorPrimary,
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.w700)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(label,
                        style: const TextStyle(
                            fontSize: 13, color: Colors.white70, height: 1.4)),
                  ),
                ],
        ),
      ),
    );
  }
}

class _DetailSkeleton extends StatelessWidget {
  const _DetailSkeleton();
  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        ShimmerCard(height: 300, radius: 0),
        SizedBox(height: 16),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: ShimmerList(count: 3, itemHeight: 80),
        ),
      ],
    );
  }
}
