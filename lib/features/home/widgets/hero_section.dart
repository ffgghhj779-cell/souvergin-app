import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../shared/widgets/app_buttons.dart';

/// Replicates the web's HeroSection – dark bg, electric accents,
/// animated badge, gradient headline, two CTA buttons, fintech terminal card.
class HomeHeroSection extends StatelessWidget {
  final String locale;
  const HomeHeroSection({super.key, required this.locale});

  bool get isAr => locale == 'ar';

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(locale);
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppConstants.colorBackground,
        border: Border(
          bottom: BorderSide(color: AppConstants.colorBorder),
        ),
      ),
      child: Stack(
        children: [
          // Electric accent blobs
          PositionedDirectional(
            top: -60,
            end: -80,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  const Color(0xFF1E3A8A).withValues(alpha: 0.3),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
          PositionedDirectional(
            bottom: -40,
            start: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  AppConstants.colorEmerald.withValues(alpha: 0.12),
                  Colors.transparent,
                ]),
              ),
            ),
          ),

          // Main content
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacingLg,
              vertical: AppConstants.spacingXxl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status badge
                StatusBadge(label: strings.heroSystemStatus)
                    .animate()
                    .fadeIn(duration: 500.ms)
                    .slideY(begin: -0.2, end: 0),

                const SizedBox(height: AppConstants.spacingLg),

                // Heading
                _buildHeading(strings)
                    .animate(delay: 100.ms)
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: 0.1, end: 0),

                const SizedBox(height: AppConstants.spacingMd),

                // Subtitle
                Text(
                  strings.heroDescription,
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppConstants.colorBodyText,
                    height: 1.7,
                  ),
                )
                    .animate(delay: 200.ms)
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: 0.1, end: 0),

                const SizedBox(height: AppConstants.spacingXl),

                // CTA buttons
                _buildCTAButtons(context, strings)
                    .animate(delay: 350.ms)
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: 0.1, end: 0),

                const SizedBox(height: AppConstants.spacingXl),

                // Fintech terminal card
                _TerminalCard(locale: locale, strings: strings)
                    .animate(delay: 500.ms)
                    .fadeIn(duration: 700.ms)
                    .slideY(begin: 0.08, end: 0),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeading(AppStrings strings) {
    // Build the gradient shader at runtime — cannot be const
    final gradientShader = const LinearGradient(
      colors: [
        AppConstants.colorAccent,
        AppConstants.colorIndigo,
      ],
    ).createShader(const Rect.fromLTWH(0, 0, 300, 50));

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '${strings.heroHeadline1}${strings.isAr ? ' ' : '\n'}',
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -1.2,
              height: 1.15,
            ),
          ),
          if (strings.heroHeadline2.isNotEmpty)
            TextSpan(
              text: '${strings.heroHeadline2} ',
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -1.2,
                height: 1.15,
              ),
            ),
          TextSpan(
            text: strings.heroHeadline3,
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              letterSpacing: -1.2,
              height: 1.15,
              foreground: Paint()..shader = gradientShader,
            ),
          ),
        ],
      ),
      textAlign: TextAlign.start,
    );
  }

  Widget _buildCTAButtons(BuildContext context, AppStrings strings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: double.infinity,
          child: PrimaryButton(
            label: strings.initializeApp,
            icon: strings.isAr ? Icons.arrow_back_rounded : Icons.arrow_forward_rounded,
            iconTrailing: true,
            onPressed: () => context.go('/visas'),
          ),
        ),
        const SizedBox(height: AppConstants.spacingSm),
        SizedBox(
          width: double.infinity,
          child: GhostButton(
            label: strings.exploreFrameworks,
            onPressed: () => context.go('/about'),
          ),
        ),
      ],
    );
  }
}

/// The glassmorphic fintech "terminal" panel shown on the web's hero right side.
class _TerminalCard extends StatelessWidget {
  final String locale;
  final AppStrings strings;
  const _TerminalCard({required this.locale, required this.strings});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0B1221).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(AppConstants.radiusXxl),
        border: Border.all(color: AppConstants.colorBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Window bar ────────────────────────────────────────────────
          Container(
            height: 44,
            decoration: const BoxDecoration(
              color: Color(0xFF050B14),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppConstants.radiusXxl),
              ),
              border: Border(
                bottom: BorderSide(color: AppConstants.colorBorder),
              ),
            ),
            padding:
                const EdgeInsets.symmetric(horizontal: AppConstants.spacingMd),
            child: Row(
              children: [
                _Dot(color: Colors.red.shade400),
                const SizedBox(width: 6),
                _Dot(color: Colors.amber.shade400),
                const SizedBox(width: 6),
                _Dot(color: Colors.green.shade400),
                const Spacer(),
                const Icon(Icons.lock_rounded,
                    size: 12, color: AppConstants.colorBodyText),
                const SizedBox(width: 4),
                Text(
                  strings.encryptedConnection,
                  style: const TextStyle(
                    fontSize: 9,
                    color: AppConstants.colorBodyText,
                    letterSpacing: 1.3,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),

          // ── Data block ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(AppConstants.spacingMd),
            child: Column(
              children: [
                // Main data render block
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppConstants.spacingMd),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A1628),
                    borderRadius:
                        BorderRadius.circular(AppConstants.radiusLg),
                    border: Border.all(color: AppConstants.colorBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                'LIVE PROCESSING',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: AppConstants.colorBodyText,
                                  letterSpacing: 1.5,
                                  fontFamily: 'monospace',
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Active Matrix',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppConstants.colorEmerald
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: AppConstants.colorEmerald
                                    .withValues(alpha: 0.3),
                              ),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.bolt_rounded,
                                    size: 11,
                                    color: AppConstants.colorEmerald),
                                SizedBox(width: 3),
                                Text(
                                  '14ms',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: AppConstants.colorEmerald,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppConstants.spacingMd),
                      const _DataRow('Node_Routing', 'OPTIMIZED',
                          AppConstants.colorAccent),
                      const SizedBox(height: 8),
                      const _DataRow(
                          'Clearance_Rate', '99.998%', Colors.white),
                      const SizedBox(height: 8),
                      const _DataRow('Sys_Capacity', 'NOMINAL',
                          AppConstants.colorEmerald),
                    ],
                  ),
                ),

                const SizedBox(height: AppConstants.spacingSm),

                // Two smaller bento blocks
                const Row(
                  children: [
                    Expanded(
                      child: _SmallBentoBlock(
                        icon: Icons.public_rounded,
                        value: '50+',
                        label: 'Jurisdictions',
                        iconColor: AppConstants.colorIndigo,
                      ),
                    ),
                    SizedBox(width: AppConstants.spacingSm),
                    Expanded(
                      child: _SmallBentoBlock(
                        icon: Icons.trending_up_rounded,
                        value: '\$5B+',
                        label: 'AUM Integrated',
                        iconColor: AppConstants.colorEmerald,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DataRow extends StatelessWidget {
  final String dataKey;
  final String value;
  final Color valueColor;
  const _DataRow(this.dataKey, this.value, this.valueColor);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 8),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppConstants.colorBorder, width: 0.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(dataKey,
              style: const TextStyle(
                  fontSize: 11,
                  color: AppConstants.colorBodyText,
                  fontFamily: 'monospace')),
          Text(value,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: valueColor,
                  fontFamily: 'monospace')),
        ],
      ),
    );
  }
}

class _SmallBentoBlock extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color iconColor;
  const _SmallBentoBlock({
    required this.icon,
    required this.value,
    required this.label,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1628),
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        border: Border.all(color: AppConstants.colorBorder),
      ),
      child: Column(
        children: [
          Icon(icon, size: 26, color: iconColor),
          const SizedBox(height: 6),
          Text(value,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.5)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  fontSize: 9,
                  color: AppConstants.colorBodyText,
                  fontFamily: 'monospace',
                  letterSpacing: 0.5)),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final Color color;
  const _Dot({required this.color});
  @override
  Widget build(BuildContext context) => Container(
        width: 10,
        height: 10,
        decoration:
            BoxDecoration(color: color.withValues(alpha: 0.8), shape: BoxShape.circle),
      );
}
