import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/visa.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/models/app_exception.dart';
import '../../../shared/widgets/error_state_widget.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/analytics_service.dart';
import '../../../shared/widgets/shimmer_card.dart';
import '../../../shared/widgets/visa_card.dart';
import '../widgets/hero_section.dart';
import '../widgets/trust_section.dart';
import '../widgets/services_section.dart';
import '../widgets/how_it_works_section.dart';
import '../widgets/cta_section.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider).languageCode;
    final visasAsync = ref.watch(visasProvider);
    // Force immediate background load of categories to prep cache for Visas tab
    ref.listen(categoriesProvider, (_, __) {});

    // Log app start only once per session
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AnalyticsService.appOpened(locale);
    });

    return Scaffold(
      backgroundColor: AppConstants.colorBackground,
      body: RefreshIndicator(
        color: AppConstants.colorAccent,
        backgroundColor: AppConstants.colorCard,
        onRefresh: () async {
          await ref.read(visasProvider.notifier).refresh();
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          slivers: [
            // ── App Bar with logo + language toggle ──────────────────────
            _HomeAppBar(locale: locale, ref: ref),

            // ── Hero Section ─────────────────────────────────────────────
            SliverToBoxAdapter(child: RepaintBoundary(child: HomeHeroSection(locale: locale))),

          // ── Trust Stats Bar ──────────────────────────────────────────
          SliverToBoxAdapter(child: RepaintBoundary(child: TrustSection(locale: locale))),

          // ── Services Overview ────────────────────────────────────────
          SliverToBoxAdapter(child: RepaintBoundary(child: ServicesSection(locale: locale))),

          // ── How It Works ─────────────────────────────────────────────
          SliverToBoxAdapter(child: HowItWorksSection(locale: locale)),

          // ── Featured Visas ───────────────────────────────────────────
          SliverToBoxAdapter(
            child: _FeaturedVisas(locale: locale, visasAsync: visasAsync),
          ),

          // ── CTA Section ──────────────────────────────────────────────
          SliverToBoxAdapter(child: CTASection(locale: locale)),

          // Bottom padding for nav bar
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ), // CustomScrollView
      ), // RefreshIndicator
    );
  }
}

// ── App bar ───────────────────────────────────────────────────────────────────
class _HomeAppBar extends ConsumerWidget {
  final String locale;
  final WidgetRef ref;
  const _HomeAppBar({required this.locale, required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef r) {
    final strings = AppStrings.of(locale);
    return SliverAppBar(
      pinned: true,
      floating: false,
      backgroundColor: AppConstants.colorBackground.withValues(alpha: 0.92),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      toolbarHeight: 64,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          // ── Official brand logo ──────────────────────────────────────
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppConstants.radiusSm),
              boxShadow: [
                BoxShadow(
                  color: AppConstants.colorPrimary.withValues(alpha: 0.25),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            padding: const EdgeInsets.all(3),
            child: Image.asset(
              'assets/images/mylogo.png',
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              strings.appName,
              style: TextStyle(
                fontSize: strings.isAr ? 15 : 16,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsetsDirectional.only(end: AppConstants.spacingMd),
          child: GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              final newLocale = (locale == 'ar') ? 'en' : 'ar';
              ref.read(localeProvider.notifier).state = Locale(newLocale);
              AnalyticsService.languageSwitched(newLocale);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppConstants.colorCard,
                borderRadius:
                    BorderRadius.circular(AppConstants.radiusFull),
                border:
                    Border.all(color: AppConstants.colorBorder),
              ),
              child: Text(
                strings.languageToggle,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(
          color: AppConstants.colorBorder,
          height: 1.0,
        ),
      ),
    );
  }
}

// ── Featured Visas ────────────────────────────────────────────────────────────
class _FeaturedVisas extends ConsumerWidget {
  final String locale;
  final AsyncValue visasAsync;
  const _FeaturedVisas({required this.locale, required this.visasAsync});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(locale);
    return Container(
      color: const Color(0xFF0D1117),
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.homeHeaderTitle,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.8,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      strings.homeHeaderSubtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppConstants.colorBodyText,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.go('/visas');
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppConstants.colorCard,
                    borderRadius:
                        BorderRadius.circular(AppConstants.radiusFull),
                    border: Border.all(color: AppConstants.colorBorder),
                  ),
                  child: Text(
                    strings.viewAll,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppConstants.spacingLg),

          // Visas
          visasAsync.when(
            loading: () => const ShimmerList(count: 3, itemHeight: 240),
            error: (e, _) => ErrorStateWidget(
              locale: locale,
              message: e is AppException ? e.message : null,
              onRetry: () => ref.read(visasProvider.notifier).refresh(),
            ),
            data: (visas) {
              final featured = visas.take(5).toList();
              if (featured.isEmpty) {
                return EmptyStateWidget(locale: locale);
              }

              // Precache the images for instantaneous loading
              WidgetsBinding.instance.addPostFrameCallback((_) {
                for (final v in featured) {
                  precacheImage(CachedNetworkImageProvider(v.image), context);
                }
              });

              return Column(
                children: [
                  // Large featured card
                  SizedBox(
                    height: 320,
                    child: VisaCard(
                      visa: featured[0],
                      locale: locale,
                      isFeatured: true,
                      onTap: () =>
                          context.go('/visas/${featured[0].slug}'),
                    ),
                  ).animate().fadeIn(duration: 400.ms, curve: Curves.easeOut).slideY(begin: 0.05, end: 0, duration: 400.ms, curve: Curves.easeOutCubic),
                  if (featured.length > 1) ...[
                    const SizedBox(height: AppConstants.spacingMd),
                    Row(
                      children: featured.skip(1).take(2).toList().asMap().entries.map((entry) {
                        int index = entry.key;
                        Visa v = entry.value;
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsetsDirectional.only(
                              start: index == 0 ? 0 : 6,
                              end: index == 0 ? 6 : 0,
                            ),
                            child: SizedBox(
                              height: 220,
                              child: VisaCard(
                                visa: v,
                                locale: locale,
                                onTap: () =>
                                    context.go('/visas/${v.slug}'),
                              ),
                            ),
                          ),
                        ).animate(delay: Duration(milliseconds: 100 + (index * 70))).fadeIn(duration: 400.ms, curve: Curves.easeOut).slideY(begin: 0.05, end: 0, duration: 400.ms, curve: Curves.easeOutCubic);
                      }).toList(),
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
