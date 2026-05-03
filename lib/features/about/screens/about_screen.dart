import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_router.dart';

class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider).languageCode;
    final isAr = locale == 'ar';

    final features = isAr
        ? [
            const _Feature(Icons.shield_rounded, 'خدمات سيادية متميزة',
                AppConstants.colorAccent),
            const _Feature(Icons.public_rounded, 'شبكة علاقات عالمية',
                AppConstants.colorIndigo),
            const _Feature(Icons.lock_rounded, 'سرية وتشفير تامة',
                AppConstants.colorEmerald),
            const _Feature(Icons.support_agent_rounded, 'استشارات مخصصة',
                AppConstants.colorAccent),
          ]
        : [
            const _Feature(Icons.shield_rounded, 'Premium Sovereign Services',
                AppConstants.colorAccent),
            const _Feature(Icons.public_rounded, 'Global Strategic Network',
                AppConstants.colorIndigo),
            const _Feature(Icons.lock_rounded, 'Absolute Confidentiality',
                AppConstants.colorEmerald),
            const _Feature(Icons.support_agent_rounded, 'Direct Advisory Access',
                AppConstants.colorAccent),
          ];

    return Scaffold(
      backgroundColor: AppConstants.colorBackground,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppConstants.colorBackground.withValues(alpha: 0.95),
            surfaceTintColor: Colors.transparent,
            toolbarHeight: 64,
            title: Text(
              isAr ? 'عن الصندوق' : 'About',
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white),
            ),
          ),

          SliverToBoxAdapter(
            child: Column(
              children: [
                // ── Hero image composite ───────────────────────────────
                Padding(
                  padding: const EdgeInsets.all(AppConstants.spacingLg),
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(AppConstants.radiusXxl),
                    child: SizedBox(
                      height: 260,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CachedNetworkImage(
                            imageUrl:
                                'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?q=80&w=1000&auto=format&fit=crop',
                            fit: BoxFit.cover,
                          ),
                          Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Color(0xCC000000),
                                ],
                              ),
                            ),
                          ),
                          // 99% success badge
                          Positioned(
                            bottom: 20,
                            right: 20,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 14),
                              decoration: BoxDecoration(
                                color: AppConstants.colorPrimary,
                                borderRadius: BorderRadius.circular(
                                    AppConstants.radiusLg),
                              ),
                              child: const Column(
                                children: [
                                  Text('99%',
                                      style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                          letterSpacing: -0.8)),
                                  Text('SUCCESS RATE',
                                      style: TextStyle(
                                          fontSize: 8,
                                          color: Colors.white70,
                                          letterSpacing: 1.5,
                                          fontFamily: 'monospace')),
                                ],
                              ),
                            ),
                          ),

                          // Licensed badge
                          Positioned(
                            bottom: 20,
                            left: 20,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.2)),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.shield_rounded,
                                      size: 16, color: Colors.white),
                                  SizedBox(width: 6),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Licensed Entity',
                                          style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white)),
                                      Text('ID: SMF-9942',
                                          style: TextStyle(
                                              fontSize: 9,
                                              color: Colors.white70,
                                              fontFamily: 'monospace')),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.05),

                // ── Institutional Profile ─────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spacingLg),
                  child: Column(
                    crossAxisAlignment: isAr
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      // Label
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppConstants.colorPrimary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(
                              AppConstants.radiusFull),
                          border: Border.all(
                              color:
                                  AppConstants.colorPrimary.withValues(alpha: 0.2)),
                        ),
                        child: Text(
                          isAr ? 'من نحن' : 'Institutional Profile',
                          style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: AppConstants.colorPrimary,
                              letterSpacing: 1.5,
                              fontFamily: 'monospace'),
                        ),
                      ).animate(delay: 100.ms).fadeIn(duration: 400.ms),

                      const SizedBox(height: 16),

                      // Heading
                      Text.rich(
                        TextSpan(children: [
                          TextSpan(
                            text: isAr
                                ? 'التميز السيادي في '
                                : 'Sovereign Excellence in ',
                            style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.8,
                                height: 1.2),
                          ),
                          TextSpan(
                            text: isAr ? 'كل ملف' : 'Every Case',
                            style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: AppConstants.colorPrimary,
                                letterSpacing: -0.8,
                                height: 1.2),
                          ),
                        ]),
                        textAlign: isAr ? TextAlign.right : TextAlign.left,
                        textDirection:
                            isAr ? TextDirection.rtl : TextDirection.ltr,
                      ).animate(delay: 150.ms).fadeIn(duration: 500.ms),

                      const SizedBox(height: 14),

                      Text(
                        isAr
                            ? 'نحن لا نقدم مجرد تأشيرات؛ بل نبني بوابات استراتيجية للمستثمرين حول العالم. منهجيتنا تعتمد على التدقيق السيادي الشامل لضمان أعلى نسب القبول.'
                            : 'We do not merely process visas; we architect strategic gateways for global investors. Our methodology relies on exhaustive sovereign audits to ensure the highest clearance rates.',
                        textAlign: isAr ? TextAlign.right : TextAlign.left,
                        style: const TextStyle(
                            fontSize: 14,
                            color: AppConstants.colorBodyText,
                            height: 1.75),
                      ).animate(delay: 200.ms).fadeIn(duration: 500.ms),

                      const SizedBox(height: AppConstants.spacingXl),

                      // Feature grid
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        mainAxisSpacing: AppConstants.spacingMd,
                        crossAxisSpacing: AppConstants.spacingMd,
                        childAspectRatio: 2.5,
                        children: features.asMap().entries.map((e) {
                          return _FeatureCard(feature: e.value)
                              .animate(
                                delay: Duration(milliseconds: 280 + e.key * 80),
                              )
                              .fadeIn(duration: 400.ms)
                              .slideY(begin: 0.05);
                        }).toList(),
                      ),

                      const SizedBox(height: AppConstants.spacingXxl),

                      // ── Legal Links ──────────────────────────────────────
                      Center(
                        child: Wrap(
                          spacing: 16,
                          runSpacing: 12,
                          alignment: WrapAlignment.center,
                          children: [
                            TextButton(
                              onPressed: () => launchUrl(Uri.parse(AppConstants.privacyPolicyUrl)),
                              child: Text(
                                isAr ? 'سياسة الخصوصية' : 'Privacy Policy',
                                style: const TextStyle(
                                  color: AppConstants.colorBodyText,
                                  fontSize: 12,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () => launchUrl(Uri.parse(AppConstants.termsUrl)),
                              child: Text(
                                isAr ? 'شروط الخدمة' : 'Terms of Service',
                                style: const TextStyle(
                                  color: AppConstants.colorBodyText,
                                  fontSize: 12,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacingXxl),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Feature {
  final IconData icon;
  final String label;
  final Color color;
  const _Feature(this.icon, this.label, this.color);
}

class _FeatureCard extends StatelessWidget {
  final _Feature feature;
  const _FeatureCard({required this.feature});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppConstants.colorCard,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        border: Border.all(color: AppConstants.colorBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: feature.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(feature.icon, size: 18, color: feature.color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              feature.label,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.2),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
