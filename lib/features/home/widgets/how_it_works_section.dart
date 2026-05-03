import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_constants.dart';

/// Replicates HowItWorks.tsx – dark slate bg, 3-step pipeline cards.
class HowItWorksSection extends StatelessWidget {
  final String locale;
  const HowItWorksSection({super.key, required this.locale});

  bool get isAr => locale == 'ar';

  @override
  Widget build(BuildContext context) {
    final steps = [
      _Step(
        number: '01',
        icon: Icons.edit_document,
        iconColor: AppConstants.colorAccent,
        glowColor: AppConstants.colorAccent,
        title: isAr ? 'التهيئة المبدئية' : 'Initial Initialization',
        description: isAr
            ? 'قم بإنشاء وتشفير ملفك الاستثماري ورفع المستندات الأولية عبر بروتوكولنا الآمن.'
            : 'Create your encrypted investment profile and upload preliminary data through our secure terminal.',
      ),
      _Step(
        number: '02',
        icon: Icons.manage_search_rounded,
        iconColor: AppConstants.colorIndigo,
        glowColor: AppConstants.colorIndigo,
        title: isAr ? 'التدقيق السيادي' : 'Sovereign Audit',
        description: isAr
            ? 'يقوم خبراؤنا بالتدقيق القانوني والمالي الشامل لضمان التوافق مع المعايير الدولية.'
            : 'Our analysts run a comprehensive legal and financial audit to guarantee cross-border compliance.',
      ),
      _Step(
        number: '03',
        icon: Icons.check_circle_rounded,
        iconColor: AppConstants.colorEmerald,
        glowColor: AppConstants.colorEmerald,
        title: isAr ? 'الموافقة والإصدار' : 'Approval & Issuance',
        description: isAr
            ? 'تلقي الموافقة النهائية واستلام التأشيرة أو وثائق الإقامة رسمياً.'
            : 'Receive definitive approval and officially secure your visa or residency documentation.',
      ),
    ];

    return Container(
      color: AppConstants.colorDarkSurface,
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isAr ? 'بروتوكول التنفيذ' : 'Execution Protocol',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.8,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isAr
                          ? 'ثلاث مراحل سيادية تفصلك عن تأمين استثمارك وانتقالك العالمي.'
                          : 'A strict three-phase sovereign pipeline for your global mobility.',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppConstants.colorBodyText,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppConstants.colorCard,
                  borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                  border: Border.all(color: AppConstants.colorBorder),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock_rounded,
                        size: 11, color: AppConstants.colorEmerald),
                    const SizedBox(width: 5),
                    Text(
                      isAr ? 'مشفر' : 'ENCRYPTED',
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: AppConstants.colorEmerald,
                        letterSpacing: 1.2,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppConstants.spacingXl),

          // Step cards
          ...steps.asMap().entries.map((entry) {
            final i = entry.key;
            final step = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppConstants.spacingMd),
              child: _StepCard(step: step)
                  .animate(delay: Duration(milliseconds: i * 120))
                  .fadeIn(duration: 500.ms)
                  .slideX(begin: 0.05, end: 0),
            );
          }),
        ],
      ),
    );
  }
}

class _Step {
  final String number;
  final IconData icon;
  final Color iconColor;
  final Color glowColor;
  final String title;
  final String description;
  const _Step({
    required this.number,
    required this.icon,
    required this.iconColor,
    required this.glowColor,
    required this.title,
    required this.description,
  });
}

class _StepCard extends StatelessWidget {
  final _Step step;
  const _StepCard({required this.step});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      decoration: BoxDecoration(
        color: AppConstants.colorCard,
        borderRadius: BorderRadius.circular(AppConstants.radiusXxl),
        border: Border.all(color: AppConstants.colorBorder),
        boxShadow: [
          BoxShadow(
            color: step.glowColor.withValues(alpha: 0.06),
            blurRadius: 20,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppConstants.colorDarkSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppConstants.colorBorder),
            ),
            child: Icon(step.icon, size: 22, color: step.iconColor),
          ),
          const SizedBox(width: AppConstants.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  step.description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppConstants.colorBodyText,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          // Step number
          Text(
            step.number,
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w900,
              color: AppConstants.colorBorder,
              fontFamily: 'monospace',
              letterSpacing: -2,
            ),
          ),
        ],
      ),
    );
  }
}
