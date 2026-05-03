import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/rate_limiter.dart';
import '../../../shared/widgets/app_buttons.dart';

class ContactScreen extends ConsumerStatefulWidget {
  const ContactScreen({super.key});
  @override
  ConsumerState<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends ConsumerState<ContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  bool _isSubmitting = false;
  bool _isSuccess = false;

  // Client-side rate limiter: one submission per 30 seconds
  final _rateLimiter = RateLimiter(cooldown: const Duration(seconds: 30));

  @override
  void initState() {
    super.initState();
    // ── Restore draft from persistence ────────────────────────────────────
    // Runs synchronously — SharedPreferences is pre-warmed in main().
    final draft = ref.read(appPersistenceProvider).contactDraft;
    _nameCtrl.text    = draft['name']    ?? '';
    _emailCtrl.text   = draft['email']   ?? '';
    _messageCtrl.text = draft['message'] ?? '';

    // ── Auto-save on every keystroke ──────────────────────────────────────
    _nameCtrl.addListener(
        () => ref.read(appPersistenceProvider).saveContactField('name', _nameCtrl.text));
    _emailCtrl.addListener(
        () => ref.read(appPersistenceProvider).saveContactField('email', _emailCtrl.text));
    _messageCtrl.addListener(
        () => ref.read(appPersistenceProvider).saveContactField('message', _messageCtrl.text));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // Client-side rate limit check
    if (!_rateLimiter.canSubmit) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please wait ${_rateLimiter.secondsRemaining}s before sending again.',
          ),
          backgroundColor: Colors.orange.shade800,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await ref.read(visaRepositoryProvider).submitContactMessage(
            name: _nameCtrl.text.trim(),
            email: _emailCtrl.text.trim(),
            message: _messageCtrl.text.trim(),
          );
      _rateLimiter.recordSubmission();
      // Draft is fulfilled — clear it from persistence.
      ref.read(appPersistenceProvider).clearContactDraft();
      if (mounted) setState(() { _isSubmitting = false; _isSuccess = true; });
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red.shade800,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider).languageCode;
    final isAr = locale == 'ar';

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
              isAr ? 'تواصل معنا' : 'Contact',
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.spacingLg),
              child: Column(
                crossAxisAlignment: isAr
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  // Header
                  Text(
                    isAr ? 'ابدأ رحلتك السيادية' : 'Initialize Contact',
                    style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.8),
                  ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.05),

                  const SizedBox(height: 8),

                  Text(
                    isAr
                        ? 'تواصل مع فريق الخبراء لدينا للحصول على استشارة مخصصة.'
                        : 'Reach our expert advisory team for a personalized consultation.',
                    style: const TextStyle(
                        fontSize: 14,
                        color: AppConstants.colorBodyText,
                        height: 1.6),
                  ).animate(delay: 80.ms).fadeIn(duration: 500.ms),

                  const SizedBox(height: AppConstants.spacingXl),

                  // Contact info cards
                  _ContactInfoCard(
                    icon: Icons.mail_outline_rounded,
                    label: isAr ? 'البريد الإلكتروني' : 'Email',
                    value: AppConstants.contactEmail,
                    color: AppConstants.colorAccent,
                    onTap: () async {
                      final uri = Uri.parse('mailto:${AppConstants.contactEmail}');
                      if (await canLaunchUrl(uri)) launchUrl(uri);
                    },
                  ).animate(delay: 120.ms).fadeIn(duration: 400.ms),

                  const SizedBox(height: AppConstants.spacingMd),

                  _ContactInfoCard(
                    icon: Icons.phone_outlined,
                    label: isAr ? 'الهاتف' : 'Phone',
                    value: AppConstants.contactPhone,
                    color: AppConstants.colorEmerald,
                    onTap: () async {
                      final uri = Uri.parse('tel:${AppConstants.contactPhone}');
                      if (await canLaunchUrl(uri)) launchUrl(uri);
                    },
                  ).animate(delay: 180.ms).fadeIn(duration: 400.ms),

                  const SizedBox(height: AppConstants.spacingMd),

                  _ContactInfoCard(
                    icon: Icons.location_on_outlined,
                    label: isAr ? 'العنوان' : 'Location',
                    value: isAr
                        ? AppConstants.contactLocationAr
                        : AppConstants.contactLocation,
                    color: AppConstants.colorIndigo,
                    onTap: () async {
                      final mapsUri = Uri.parse(
                          'https://www.google.com/maps/search/?api=1&query='
                          '${Uri.encodeComponent(AppConstants.contactLocation)}');
                      if (await canLaunchUrl(mapsUri)) {
                        launchUrl(mapsUri, mode: LaunchMode.externalApplication);
                      }
                    },
                  ).animate(delay: 240.ms).fadeIn(duration: 400.ms),

                  const SizedBox(height: AppConstants.spacingXl),

                  // Divider
                  Container(
                    width: double.infinity,
                    height: 1,
                    color: AppConstants.colorBorder,
                  ),

                  const SizedBox(height: AppConstants.spacingXl),

                  if (_isSuccess)
                    _SuccessState(isAr: isAr).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.95, 0.95))
                  else
                    _ContactForm(
                      formKey: _formKey,
                      nameCtrl: _nameCtrl,
                      emailCtrl: _emailCtrl,
                      messageCtrl: _messageCtrl,
                      isSubmitting: _isSubmitting,
                      isAr: isAr,
                      onSubmit: _submit,
                    ).animate(delay: 250.ms).fadeIn(duration: 500.ms),

                  const SizedBox(height: AppConstants.spacingHuge),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactInfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback onTap;

  const _ContactInfoCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        decoration: BoxDecoration(
          color: AppConstants.colorCard,
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
          border: Border.all(color: AppConstants.colorBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          fontSize: 11,
                          color: AppConstants.colorBodyText,
                          letterSpacing: 1.2,
                          fontFamily: 'monospace')),
                  const SizedBox(height: 2),
                  Text(value,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white),
                      textDirection: TextDirection.ltr),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: AppConstants.colorBodyText),
          ],
        ),
      ),
    );
  }
}

class _ContactForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController messageCtrl;
  final bool isSubmitting;
  final bool isAr;
  final VoidCallback onSubmit;

  const _ContactForm({
    required this.formKey,
    required this.nameCtrl,
    required this.emailCtrl,
    required this.messageCtrl,
    required this.isSubmitting,
    required this.isAr,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            isAr ? 'أرسل رسالة مباشرة' : 'Send a Direct Message',
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white),
          ),
          const SizedBox(height: AppConstants.spacingMd),
          TextFormField(
            controller: nameCtrl,
            maxLength: 100,
            style: const TextStyle(color: Colors.white),
            validator: (v) => v == null || v.trim().isEmpty ? (isAr ? 'مطلوب' : 'Required') : null,
            decoration: InputDecoration(
              labelText: isAr ? 'الاسم' : 'Name',
              prefixIcon: const Icon(Icons.person_outline_rounded,
                  size: 18, color: AppConstants.colorBodyText),
            ),
          ),
          const SizedBox(height: AppConstants.spacingMd),
          TextFormField(
            controller: emailCtrl,
            maxLength: 320,
            keyboardType: TextInputType.emailAddress,
            textDirection: TextDirection.ltr,
            style: const TextStyle(color: Colors.white),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return isAr ? 'مطلوب' : 'Required';
              final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
              if (!emailRegex.hasMatch(v.trim())) {
                return isAr ? 'بريد إلكتروني غير صالح' : 'Invalid email';
              }
              return null;
            },
            decoration: InputDecoration(
              labelText: isAr ? 'البريد الإلكتروني' : 'Email',
              prefixIcon: const Icon(Icons.mail_outline_rounded,
                  size: 18, color: AppConstants.colorBodyText),
            ),
          ),
          const SizedBox(height: AppConstants.spacingMd),
          TextFormField(
            controller: messageCtrl,
            maxLines: 4,
            maxLength: 2000,
            style: const TextStyle(color: Colors.white),
            validator: (v) => v == null || v.trim().isEmpty ? (isAr ? 'مطلوب' : 'Required') : null,
            decoration: InputDecoration(
              labelText: isAr ? 'الرسالة' : 'Message',
              prefixIcon: const Icon(Icons.chat_bubble_outline_rounded,
                  size: 18, color: AppConstants.colorBodyText),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: AppConstants.spacingXl),
          PrimaryButton(
            label: isAr ? 'إرسال الرسالة' : 'Send Message',
            isLoading: isSubmitting,
            icon: Icons.send_rounded,
            iconTrailing: true,
            onPressed: onSubmit,
          ),
        ],
      ),
    );
  }
}

class _SuccessState extends StatelessWidget {
  final bool isAr;
  const _SuccessState({required this.isAr});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: AppConstants.colorEmerald.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_rounded,
                size: 32, color: AppConstants.colorEmerald),
          ),
          const SizedBox(height: 16),
          Text(
            isAr ? 'تم إرسال رسالتك!' : 'Message Sent!',
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            isAr ? 'سنرد عليك قريباً.' : 'We\'ll get back to you shortly.',
            style: const TextStyle(
                fontSize: 13, color: AppConstants.colorBodyText),
          ),
        ],
      ),
    );
  }
}
