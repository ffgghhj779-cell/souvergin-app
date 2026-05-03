import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/widgets/app_buttons.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _error = null; });
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );
      if (mounted) context.go('/home');
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider).languageCode;
    final isAr = locale == 'ar';

    return Scaffold(
      backgroundColor: AppConstants.colorBackground,
      body: Stack(
        children: [
          // Background accents
          Positioned(
            top: -80,
            right: -80,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  AppConstants.colorPrimary.withValues(alpha: 0.18),
                  Colors.transparent,
                ]),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.spacingLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppConstants.spacingXl),

                  // Logo + back
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.go('/home'),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppConstants.colorCard,
                            borderRadius: BorderRadius.circular(
                                AppConstants.radiusFull),
                            border: Border.all(color: AppConstants.colorBorder),
                          ),
                          child: const Icon(Icons.arrow_back_rounded,
                              size: 18, color: Colors.white),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppConstants.spacingXxl),

                  // Header
                  // ── Official brand logo ───────────────────────────────
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                      boxShadow: [
                        BoxShadow(
                          color: AppConstants.colorPrimary.withValues(alpha: 0.3),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Image.asset(
                      'assets/images/mylogo.png',
                      fit: BoxFit.contain,
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .scale(begin: const Offset(0.7, 0.7)),

                  const SizedBox(height: 16),

                  Text(
                    isAr ? 'تسجيل الدخول' : 'Sign In',
                    style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.8),
                  ).animate(delay: 80.ms).fadeIn(duration: 400.ms).slideY(begin: 0.05),

                  const SizedBox(height: 6),

                  Text(
                    isAr
                        ? 'ادخل إلى لوحة التحكم السيادية'
                        : 'Access your sovereign dashboard',
                    style: const TextStyle(
                        fontSize: 14,
                        color: AppConstants.colorBodyText),
                  ).animate(delay: 130.ms).fadeIn(duration: 400.ms),

                  const SizedBox(height: AppConstants.spacingXxl),

                  // Form
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          textDirection: TextDirection.ltr,
                          style: const TextStyle(color: Colors.white),
                          validator: (v) => v!.isEmpty
                              ? (isAr ? 'مطلوب' : 'Required')
                              : null,
                          decoration: InputDecoration(
                            labelText: isAr ? 'البريد الإلكتروني' : 'Email',
                            prefixIcon: const Icon(Icons.mail_outline_rounded,
                                size: 18, color: AppConstants.colorBodyText),
                          ),
                        ).animate(delay: 180.ms).fadeIn(duration: 400.ms),

                        const SizedBox(height: AppConstants.spacingMd),

                        TextFormField(
                          controller: _passwordCtrl,
                          obscureText: _obscurePassword,
                          style: const TextStyle(color: Colors.white),
                          validator: (v) => v!.isEmpty
                              ? (isAr ? 'مطلوب' : 'Required')
                              : null,
                          decoration: InputDecoration(
                            labelText: isAr ? 'كلمة المرور' : 'Password',
                            prefixIcon: const Icon(Icons.lock_outline_rounded,
                                size: 18, color: AppConstants.colorBodyText),
                            suffixIcon: GestureDetector(
                              onTap: () => setState(
                                  () => _obscurePassword = !_obscurePassword),
                              child: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                size: 18,
                                color: AppConstants.colorBodyText,
                              ),
                            ),
                          ),
                        ).animate(delay: 240.ms).fadeIn(duration: 400.ms),

                        if (_error != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(
                                  AppConstants.radiusMd),
                              border: Border.all(
                                  color: Colors.red.withValues(alpha: 0.3)),
                            ),
                            child: Text(
                              _error!,
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.redAccent),
                            ),
                          ),
                        ],

                        const SizedBox(height: AppConstants.spacingXl),

                        SizedBox(
                          width: double.infinity,
                          child: PrimaryButton(
                            label: isAr ? 'دخول' : 'Sign In',
                            isLoading: _isLoading,
                            onPressed: _signIn,
                          ),
                        ).animate(delay: 300.ms).fadeIn(duration: 400.ms),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppConstants.spacingXxl),

                  const Center(
                    child: Text(
                      'SMF SECURE LOGIN // END-TO-END ENCRYPTED',
                      style: TextStyle(
                          fontSize: 8,
                          color: AppConstants.colorBodyText,
                          letterSpacing: 2,
                          fontFamily: 'monospace'),
                    ),
                  ).animate(delay: 400.ms).fadeIn(duration: 500.ms),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
