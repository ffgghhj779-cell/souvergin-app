import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    // Navigate after animation completes
    Future.delayed(const Duration(milliseconds: 2800), () {
      if (mounted) context.go('/home');
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.colorBackground,
      body: Stack(
        children: [
          // ── Electric gradient accents ──────────────────────────────────
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppConstants.colorPrimary.withValues(alpha: 0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -80,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppConstants.colorEmerald.withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ── Center content ─────────────────────────────────────────────
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Animated logo ring ──────────────────────────────────
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppConstants.colorPrimary.withValues(
                              alpha: 0.15 + _pulseController.value * 0.25,
                            ),
                            blurRadius:
                                20 + _pulseController.value * 30,
                            spreadRadius: 2 + _pulseController.value * 8,
                          ),
                        ],
                      ),
                      child: child,
                    );
                  },
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(
                        color: AppConstants.colorPrimary.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Image.asset(
                      'assets/images/mylogo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                )
                    .animate()
                    .scale(
                      begin: const Offset(0.5, 0.5),
                      end: const Offset(1, 1),
                      duration: 700.ms,
                      curve: Curves.elasticOut,
                    )
                    .fadeIn(duration: 400.ms),

                const SizedBox(height: 28),

                // ── Brand name ──────────────────────────────────────────
                const Text(
                  AppConstants.appNameEn,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.8,
                  ),
                )
                    .animate(delay: 300.ms)
                    .fadeIn(duration: 500.ms)
                    .slideY(begin: 0.2, end: 0),

                const SizedBox(height: 8),

                // ── Arabic subtitle ─────────────────────────────────────
                const Text(
                  AppConstants.appNameAr,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppConstants.colorBodyText,
                    height: 1.5,
                  ),
                )
                    .animate(delay: 500.ms)
                    .fadeIn(duration: 500.ms)
                    .slideY(begin: 0.2, end: 0),

                const SizedBox(height: 48),

                // ── Loading dots ────────────────────────────────────────
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (i) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppConstants.colorPrimary,
                          shape: BoxShape.circle,
                        ),
                      )
                          .animate(
                            delay: Duration(milliseconds: 700 + i * 150),
                            onPlay: (c) => c.repeat(reverse: true),
                          )
                          .scale(
                            begin: const Offset(0.5, 0.5),
                            end: const Offset(1.4, 1.4),
                            duration: 600.ms,
                            curve: Curves.easeInOut,
                          )
                          .then()
                          .scale(
                            end: const Offset(0.5, 0.5),
                            duration: 600.ms,
                          ),
                    );
                  }),
                ).animate(delay: 600.ms).fadeIn(duration: 400.ms),
              ],
            ),
          ),

          // ── Version tag ─────────────────────────────────────────────────
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: const Text(
              'SMF PROTOCOL v4.0.1',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 9,
                letterSpacing: 2.5,
                color: AppConstants.colorBodyText,
                fontFamily: 'monospace',
              ),
            ).animate(delay: 800.ms).fadeIn(duration: 600.ms),
          ),
        ],
      ),
    );
  }
}
