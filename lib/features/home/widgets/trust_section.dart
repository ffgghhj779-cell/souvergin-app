import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_constants.dart';

class TrustSection extends StatelessWidget {
  final String locale;
  const TrustSection({super.key, required this.locale});

  bool get isAr => locale == 'ar';

  @override
  Widget build(BuildContext context) {
    final stats = [
      _Stat(icon: Icons.people_rounded, value: '10,000+',
          label: isAr ? 'مستثمر معتمد' : 'Approved Investors',
          color: AppConstants.colorAccent),
      _Stat(icon: Icons.public_rounded, value: '50+',
          label: isAr ? 'دولة مدعومة' : 'Supported Jurisdictions',
          color: AppConstants.colorAccent),
      _Stat(icon: Icons.verified_rounded, value: '99.9%',
          label: isAr ? 'نسبة النجاح' : 'Clearance Rate',
          color: AppConstants.colorEmerald),
      _Stat(icon: Icons.account_balance_rounded, value: '\$5B+',
          label: isAr ? 'أصول مدارة' : 'Assets Integrated',
          color: AppConstants.colorIndigo),
    ];

    return Container(
      color: AppConstants.colorBackground,
      padding: const EdgeInsets.symmetric(
        vertical: AppConstants.spacingLg,
        horizontal: AppConstants.spacingLg,
      ),
      child: Column(
        children: [
          Text(
            isAr
                ? 'تم التدقيق والاعتماد عبر كبرى المؤسسات السيادية'
                : 'Audited and verified by global sovereign institutions',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              color: AppConstants.colorBodyText,
              letterSpacing: 1.5,
              fontFamily: 'monospace',
            ),
          ).animate().fadeIn(duration: 500.ms),

          const SizedBox(height: AppConstants.spacingLg),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: AppConstants.spacingMd,
            crossAxisSpacing: AppConstants.spacingMd,
            childAspectRatio: 2.4,
            children: stats.asMap().entries.map((entry) {
              return _StatCard(stat: entry.value)
                  .animate(delay: Duration(milliseconds: entry.key * 80))
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: 0.1, end: 0);
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _Stat {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  const _Stat({required this.icon, required this.value,
      required this.label, required this.color});
}

class _StatCard extends StatelessWidget {
  final _Stat stat;
  const _StatCard({required this.stat});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingMd, vertical: AppConstants.spacingSm),
      decoration: BoxDecoration(
        color: AppConstants.colorCard,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        border: Border.all(color: AppConstants.colorBorder),
      ),
      child: Row(
        children: [
          Icon(stat.icon, size: 18, color: stat.color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(stat.value,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5)),
                Text(stat.label,
                    style: const TextStyle(
                        fontSize: 9,
                        color: AppConstants.colorBodyText,
                        letterSpacing: 0.5),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
