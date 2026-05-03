import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/router/app_router.dart';
import '../../../core/models/app_exception.dart';
import '../../../shared/widgets/shimmer_card.dart';
import '../../../shared/widgets/visa_card.dart';
import '../../../shared/widgets/error_state_widget.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../core/services/analytics_service.dart';

class VisasScreen extends ConsumerWidget {
  const VisasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider).languageCode;
    final categoriesAsync = ref.watch(categoriesProvider);
    final filteredVisas = ref.watch(filteredVisasProvider);
    final activeFilter = ref.watch(activeCategoryFilterProvider);
    final isAr = locale == 'ar';

    return Scaffold(
      backgroundColor: AppConstants.colorBackground,
      body: RefreshIndicator(
        color: AppConstants.colorAccent,
        backgroundColor: AppConstants.colorCard,
        onRefresh: () async {
          await ref.read(categoriesProvider.notifier).refresh();
          await ref.read(visasProvider.notifier).refresh();
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          slivers: [
          // ── App Bar ──────────────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            backgroundColor:
                AppConstants.colorBackground.withValues(alpha: 0.95),
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            toolbarHeight: 64,
            title: Column(
              crossAxisAlignment: isAr
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Text(
                  isAr ? 'المسارات السيادية' : 'Sovereign Frameworks',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  isAr
                      ? 'تصفح جميع برامج التأشيرات'
                      : 'Browse all visa programs',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppConstants.colorBodyText,
                  ),
                ),
              ],
            ),
          ),

          // ── Category Filter Tabs ─────────────────────────────────────
          SliverToBoxAdapter(
            child: categoriesAsync.when(
              loading: () => const SizedBox(height: 60),
              error: (_, __) => const SizedBox.shrink(),
              data: (categories) => _CategoryTabs(
                categories: categories,
                activeFilter: activeFilter,
                locale: locale,
                onSelect: (id) {
                  HapticFeedback.selectionClick();
                  ref.read(activeCategoryFilterProvider.notifier).state = id;
                  AnalyticsService.categoryFiltered(id);
                },
              ),
            ),
          ),

          // ── Visa Grid ────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.all(AppConstants.spacingMd),
            sliver: filteredVisas.when(
              loading: () => SliverList(
                delegate: SliverChildListDelegate([
                  const ShimmerList(count: 4, itemHeight: 240),
                ]),
              ),
              error: (e, _) => SliverToBoxAdapter(
                child: ErrorStateWidget(
                  locale: locale,
                  message: e is AppException ? e.message : null,
                  onRetry: () => ref.read(visasProvider.notifier).refresh(),
                ),
              ),
              data: (visas) {
                if (visas.isEmpty) {
                  return SliverToBoxAdapter(
                    child: EmptyStateWidget(locale: locale),
                  );
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      // Cap delay at 5 items — prevents excessive
                      // wait time when scrolling into lower items.
                      final delay =
                          Duration(milliseconds: min(i, 4) * 70);
                      return Padding(
                        padding: const EdgeInsets.only(
                            bottom: AppConstants.spacingMd),
                        child: RepaintBoundary(
                          child: SizedBox(
                            height: 260,
                            child: VisaCard(
                              visa: visas[i],
                              locale: locale,
                              isFeatured: i == 0,
                              onTap: () =>
                                  context.go('/visas/${visas[i].slug}'),
                            ),
                          ),
                        ),
                      )
                          .animate(delay: delay)
                          .fadeIn(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeOut,
                          )
                          .slideY(
                            begin: 0.06,
                            end: 0,
                            duration: const Duration(milliseconds: 420),
                            curve: Curves.easeOutCubic,
                          );
                    },
                    childCount: visas.length,
                  ),
                );
              },
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ), // CustomScrollView
      ), // RefreshIndicator
    );
  }
}

class _CategoryTabs extends StatelessWidget {
  final List categories;
  final String activeFilter;
  final String locale;
  final ValueChanged<String> onSelect;

  const _CategoryTabs({
    required this.categories,
    required this.activeFilter,
    required this.locale,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final isAr = locale == 'ar';
    return Container(
      height: 56,
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppConstants.colorBorder),
        ),
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingMd,
          vertical: AppConstants.spacingSm,
        ),
        children: [
          _Tab(
            label: isAr ? 'الكل' : 'All',
            isActive: activeFilter == 'all',
            onTap: () => onSelect('all'),
          ),
          ...categories.map((cat) => _Tab(
                label: isAr ? cat.titleAr : cat.titleEn,
                isActive: activeFilter == cat.id,
                onTap: () => onSelect(cat.id),
              )),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _Tab({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: AppConstants.durationFast,
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppConstants.colorPrimary : AppConstants.colorCard,
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          border: isActive
              ? Border.all(color: AppConstants.colorPrimary)
              : Border.all(color: AppConstants.colorBorder),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            color: isActive ? Colors.white : AppConstants.colorBodyText,
          ),
        ),
      ),
    );
  }
}
