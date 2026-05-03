import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/app_buttons.dart';

/// Replicates CTASection.tsx – deep dark bg, gradient heading, two CTA buttons.
class CTASection extends StatelessWidget {
  final String locale;
  const CTASection({super.key, required this.locale});

  bool get isAr => locale == 'ar';

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppConstants.colorBackground,
      padding: const EdgeInsets.all(AppConstants.spacingXl),
      child: Stack(
        children: [
          // Electric accents
          Positioned(
            top: -40,
            right: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  AppConstants.colorPrimary.withValues(alpha: 0.12),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  AppConstants.colorIndigo.withValues(alpha: 0.10),
                  Colors.transparent,
                ]),
              ),
            ),
          ),

          Column(
            children: [
              // Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppConstants.colorCard.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                  border: Border.all(color: AppConstants.colorBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.verified_rounded,
                        size: 14, color: AppConstants.colorAccent),
                    const SizedBox(width: 6),
                    Text(
                      isAr
                          ? 'بدء العملية السيادية'
                          : 'Initialize Sovereign Protocol',
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: AppConstants.colorAccent,
                        letterSpacing: 1.5,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 500.ms),

              const SizedBox(height: AppConstants.spacingXl),

              _buildHeading().animate(delay: 100.ms).fadeIn(duration: 600.ms).slideY(begin: 0.05),

              const SizedBox(height: AppConstants.spacingMd),

              Text(
                isAr
                    ? 'تواصل مع مستشارينا لبدء رحلتك الاستثمارية عبر أأمن حلول الهجرة السيادية في العالم.'
                    : 'Initialize communication with our elite advisory tier to begin your capital deployment across the world\'s most secure sovereign mobility frameworks.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppConstants.colorBodyText,
                  height: 1.7,
                ),
              ).animate(delay: 200.ms).fadeIn(duration: 600.ms),

              const SizedBox(height: AppConstants.spacingXl),

              // CTA Buttons
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  label: isAr
                      ? 'بدء المراحل الأولية'
                      : 'Initiate Secure Contact',
                  icon: Icons.arrow_forward_rounded,
                  iconTrailing: true,
                  onPressed: () => context.go('/contact'),
                ),
              ).animate(delay: 300.ms).fadeIn(duration: 500.ms),

              const SizedBox(height: AppConstants.spacingSm),

              SizedBox(
                width: double.infinity,
                child: GhostButton(
                  label: AppConstants.contactEmail,
                  icon: Icons.mail_outline_rounded,
                  onPressed: () async {
                    final uri = Uri.parse(
                        'mailto:${AppConstants.contactEmail}');
                    if (await canLaunchUrl(uri)) launchUrl(uri);
                  },
                ),
              ).animate(delay: 380.ms).fadeIn(duration: 500.ms),

              const SizedBox(height: AppConstants.spacingXxl),

              // Footer mono text
              const Text(
                'Encrypted Terminal // SMF Protocol v4.0.1 // Node: Riyadh-Global',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 8,
                  color: AppConstants.colorBodyText,
                  letterSpacing: 1.5,
                  fontFamily: 'monospace',
                ),
              ).animate(delay: 500.ms).fadeIn(duration: 600.ms),
            ],
          ),
        ],
      ),
    );
  }
  Widget _buildHeading() {
    final gradientShader = const LinearGradient(
      colors: [
        AppConstants.colorAccent,
        AppConstants.colorIndigo,
      ],
    ).createShader(const Rect.fromLTWH(0, 0, 280, 50));

    return Text.rich(
      TextSpan(children: [
        TextSpan(
          text: isAr ? 'جاهز لتأمين\n' : 'Ready to Secure\n',
          style: const TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -1.2,
            height: 1.15,
          ),
        ),
        TextSpan(
          text: isAr ? 'مستقبلك العالمي؟' : 'Your Global Future?',
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w800,
            letterSpacing: -1.2,
            height: 1.15,
            foreground: Paint()..shader = gradientShader,
          ),
        ),
      ]),
      textAlign: TextAlign.center,
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
    );
  }
}
