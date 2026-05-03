import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';

/// Replicates ServicesOverview.tsx – white surface bento cards.
class ServicesSection extends StatelessWidget {
  final String locale;
  const ServicesSection({super.key, required this.locale});

  bool get isAr => locale == 'ar';

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppConstants.colorWhiteSurface,
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Text(
            isAr ? 'الخدمات الاستراتيجية' : 'Strategic Architecture',
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
              letterSpacing: -0.8,
            ),
          ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.05, end: 0),

          const SizedBox(height: 8),

          Text(
            isAr
                ? 'نقدم منظومة متكاملة من الحلول السيادية المصممة لكبار المستثمرين.'
                : 'Delivering a comprehensive sovereign ecosystem engineered for investors.',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
              height: 1.6,
            ),
          ).animate(delay: 100.ms).fadeIn(duration: 500.ms),

          const SizedBox(height: AppConstants.spacingLg),

          // Large card (Premium Residency)
          _ServiceCard(
            icon: Icons.public_rounded,
            iconColor: const Color(0xFF2563EB),
            iconBg: const Color(0xFFEFF6FF),
            title: isAr ? 'إقامة المستثمرين المتميزة' : 'Premium Residency',
            description: isAr
                ? 'مساعدة شاملة للحصول على الإقامة والجنسية عبر برامج الاستثمار.'
                : 'End-to-end framework for securing citizenship via sovereign investment programs.',
            isDark: false,
            onTap: () => context.go('/visas'),
            linkLabel: isAr ? 'اكتشف المزيد' : 'Explore Program',
          ).animate(delay: 150.ms).fadeIn(duration: 500.ms).slideY(begin: 0.05),

          const SizedBox(height: AppConstants.spacingMd),

          // Dark card (Corporate Assets)
          _ServiceCard(
            icon: Icons.trending_up_rounded,
            iconColor: const Color(0xFF818CF8),
            iconBg: const Color(0xFF1E293B),
            title: isAr ? 'الكيانات المؤسسية' : 'Corporate Assets',
            description: isAr
                ? 'تأسيس شركات دولية مع دمج قانوني كامل لتسهيل مسارات تأشيرات الأعمال.'
                : 'International company formation & direct legal integration for business visa pipelines.',
            isDark: true,
          ).animate(delay: 200.ms).fadeIn(duration: 500.ms).slideY(begin: 0.05),

          const SizedBox(height: AppConstants.spacingMd),

          // Two-column small cards
          Row(
            children: [
              Expanded(
                child: _ServiceCard(
                  icon: Icons.handshake_rounded,
                  iconColor: const Color(0xFF059669),
                  iconBg: const Color(0xFFECFDF5),
                  title: isAr ? 'إدارة الثروات' : 'Wealth Integration',
                  description: isAr
                      ? 'تأمين استثماراتك العقارية ودمجها ببرامج الهجرة.'
                      : 'Securing real estate to sovereign immigration frameworks.',
                  isDark: false,
                  compact: true,
                ).animate(delay: 250.ms).fadeIn(duration: 500.ms),
              ),
              const SizedBox(width: AppConstants.spacingMd),
              Expanded(
                child: _ServiceCard(
                  icon: Icons.shield_rounded,
                  iconColor: const Color(0xFFDC2626),
                  iconBg: const Color(0xFFFFF1F2),
                  title: isAr ? 'التدقيق السيادي' : 'Sovereign Audit',
                  description: isAr
                      ? 'مراجعة شاملة لضمان التوافق القانوني الكامل.'
                      : 'Full sovereign audit before case submission.',
                  isDark: false,
                  compact: true,
                ).animate(delay: 300.ms).fadeIn(duration: 500.ms),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String description;
  final bool isDark;
  final bool compact;
  final VoidCallback? onTap;
  final String? linkLabel;

  const _ServiceCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.description,
    required this.isDark,
    this.compact = false,
    this.onTap,
    this.linkLabel,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? const Color(0xFF0F172A) : Colors.white;
    final titleColor = isDark ? Colors.white : const Color(0xFF111827);
    final descColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280);
    final borderColor = isDark ? AppConstants.colorBorder : const Color(0xFFE5E7EB);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(compact ? 16 : 20),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppConstants.radiusXxl),
          border: Border.all(color: borderColor),
          boxShadow: isDark
              ? []
              : [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: compact ? 40 : 52,
              height: compact ? 40 : 52,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(compact ? 12 : 16),
              ),
              child: Icon(icon, color: iconColor, size: compact ? 20 : 24),
            ),
            SizedBox(height: compact ? 10 : 14),
            Text(title,
                style: TextStyle(
                  fontSize: compact ? 14 : 18,
                  fontWeight: FontWeight.w700,
                  color: titleColor,
                  letterSpacing: -0.3,
                )),
            const SizedBox(height: 6),
            Text(description,
                style: TextStyle(
                  fontSize: 12,
                  color: descColor,
                  height: 1.55,
                ),
                maxLines: compact ? 3 : 4,
                overflow: TextOverflow.ellipsis),
            if (linkLabel != null) ...[
              const SizedBox(height: 14),
              Row(
                children: [
                  Text(linkLabel!,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2563EB),
                        letterSpacing: 1.0,
                        fontFamily: 'monospace',
                      )),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward_rounded,
                      size: 14, color: Color(0xFF2563EB)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
