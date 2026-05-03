import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/services/rate_limiter.dart';
import '../../../shared/widgets/app_buttons.dart';

/// Shows as a modal bottom sheet – mirrors LeadFormModal.tsx
void showLeadFormSheet(
  BuildContext context, {
  required String visaId,
  required String visaTitle,
  required String locale,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => LeadFormSheet(
      visaId: visaId,
      visaTitle: visaTitle,
      locale: locale,
    ),
  );
}

class LeadFormSheet extends ConsumerStatefulWidget {
  final String visaId;
  final String visaTitle;
  final String locale;

  const LeadFormSheet({
    super.key,
    required this.visaId,
    required this.visaTitle,
    required this.locale,
  });

  @override
  ConsumerState<LeadFormSheet> createState() => _LeadFormSheetState();
}

class _LeadFormSheetState extends ConsumerState<LeadFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();

  bool _isSubmitting = false;
  bool _isSuccess = false;

  // Client-side rate limiter: one submission per 30 seconds
  final _rateLimiter = RateLimiter(cooldown: const Duration(seconds: 30));

  bool get isAr => widget.locale == 'ar';

  /// The draft key is the visaId — unique per visa, fully isolated.
  String get _draftKey => widget.visaId;

  @override
  void initState() {
    super.initState();
    // ── Restore per-visa draft ────────────────────────────────────────────────
    // Each visa has its own isolated draft namespace (keyed by visaId).
    // A Schengen draft never bleeds into a Dubai draft.
    final draft = ref.read(appPersistenceProvider).getLeadDraft(_draftKey);
    _nameCtrl.text    = draft['name']    ?? '';
    _emailCtrl.text   = draft['email']   ?? '';
    _phoneCtrl.text   = draft['phone']   ?? '';
    _messageCtrl.text = draft['message'] ?? '';

    // ── Auto-save on every keystroke ─────────────────────────────────────────
    _nameCtrl.addListener(
        () => ref.read(appPersistenceProvider).saveLeadField(_draftKey, 'name', _nameCtrl.text));
    _emailCtrl.addListener(
        () => ref.read(appPersistenceProvider).saveLeadField(_draftKey, 'email', _emailCtrl.text));
    _phoneCtrl.addListener(
        () => ref.read(appPersistenceProvider).saveLeadField(_draftKey, 'phone', _phoneCtrl.text));
    _messageCtrl.addListener(
        () => ref.read(appPersistenceProvider).saveLeadField(_draftKey, 'message', _messageCtrl.text));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_rateLimiter.canSubmit) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please wait ${_rateLimiter.secondsRemaining}s before submitting again.',
          ),
          backgroundColor: Colors.orange.shade800,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await ref.read(visaRepositoryProvider).submitLead(
            name: _nameCtrl.text.trim(),
            email: _emailCtrl.text.trim(),
            phone: _phoneCtrl.text.trim(),
            visaId: widget.visaId,
            message: _messageCtrl.text.trim(),
          );
      _rateLimiter.recordSubmission();
      // Draft submitted — clear this visa's isolated draft from persistence.
      ref.read(appPersistenceProvider).clearLeadDraft(_draftKey);
      AnalyticsService.leadSubmitted(widget.visaId);
      setState(() => _isSuccess = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isAr
                ? 'حدث خطأ. يرجى المحاولة مرة أخرى.'
                : 'An error occurred. Please try again.'),
            backgroundColor: Colors.red.shade800,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0D1117),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppConstants.radiusXxl),
          ),
          border: Border(
            top: BorderSide(color: AppConstants.colorBorder),
          ),
        ),
        padding: EdgeInsets.fromLTRB(
          AppConstants.spacingLg,
          AppConstants.spacingLg,
          AppConstants.spacingLg,
          AppConstants.spacingLg + bottom,
        ),
        child: _isSuccess ? _buildSuccess() : _buildForm(),
      ),
    );
  }

  Widget _buildSuccess() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 16),
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppConstants.colorEmerald.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle_rounded,
            size: 36,
            color: AppConstants.colorEmerald,
          ),
        ).animate().scale(
              begin: const Offset(0.5, 0.5),
              end: const Offset(1, 1),
              curve: Curves.elasticOut,
              duration: 700.ms,
            ),
        const SizedBox(height: 20),
        Text(
          isAr ? 'تم استلام طلبك بنجاح!' : 'Request Received Successfully!',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ).animate(delay: 200.ms).fadeIn(duration: 400.ms),
        const SizedBox(height: 10),
        Text(
          isAr
              ? 'سيتواصل معك أحد خبرائنا قريباً.'
              : 'One of our experts will contact you shortly.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 13,
            color: AppConstants.colorBodyText,
          ),
        ).animate(delay: 300.ms).fadeIn(duration: 400.ms),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          child: PrimaryButton(
            label: isAr ? 'إغلاق' : 'Close',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ).animate(delay: 400.ms).fadeIn(duration: 400.ms),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment:
              isAr ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppConstants.colorBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Header
            Text(
              isAr ? 'طلب تأشيرة' : 'Apply for Visa',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text.rich(
              TextSpan(children: [
                TextSpan(
                  text: isAr ? 'أنت تقدم على: ' : 'Applying for: ',
                  style: const TextStyle(
                      fontSize: 13, color: AppConstants.colorBodyText),
                ),
                TextSpan(
                  text: widget.visaTitle,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppConstants.colorPrimary),
                ),
              ]),
            ),

            const SizedBox(height: AppConstants.spacingLg),

            // Full name
            _FormField(
              controller: _nameCtrl,
              label: isAr ? 'الاسم الكامل' : 'Full Name',
              hint: isAr ? 'أدخل اسمك الكامل' : 'Enter your full name',
              icon: Icons.person_outline_rounded,
              maxLength: 100,
              validator: (v) => v == null || v.trim().isEmpty
                  ? (isAr ? 'مطلوب' : 'Required')
                  : null,
            ),

            const SizedBox(height: AppConstants.spacingMd),

            // Email
            _FormField(
              controller: _emailCtrl,
              label: isAr ? 'البريد الإلكتروني' : 'Email Address',
              hint: 'email@example.com',
              icon: Icons.mail_outline_rounded,
              keyboardType: TextInputType.emailAddress,
              textDirection: TextDirection.ltr,
              maxLength: 320,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return isAr ? 'مطلوب' : 'Required';
                final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                if (!emailRegex.hasMatch(v.trim())) {
                  return isAr ? 'بريد إلكتروني غير صالح' : 'Invalid email';
                }
                return null;
              },
            ),

            const SizedBox(height: AppConstants.spacingMd),

            // Phone
            _FormField(
              controller: _phoneCtrl,
              label: isAr ? 'رقم الهاتف' : 'Phone Number',
              hint: '+1 234 567 8900',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              textDirection: TextDirection.ltr,
              maxLength: 30,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return isAr ? 'مطلوب' : 'Required';
                // Simple E.164 check (allows spaces/dashes before clearing)
                final phoneRegex = RegExp(r'^\+?[1-9]\d{6,14}$');
                if (!phoneRegex.hasMatch(v.replaceAll(RegExp(r'[\s\-]'), ''))) {
                  return isAr ? 'رقم هاتف غير صالح' : 'Invalid phone number';
                }
                return null;
              },
            ),

            const SizedBox(height: AppConstants.spacingMd),

            // Message (optional)
            _FormField(
              controller: _messageCtrl,
              label: isAr
                  ? 'رسالة إضافية (اختياري)'
                  : 'Additional Message (Optional)',
              hint: isAr
                  ? 'أي تفاصيل إضافية...'
                  : 'Any additional details...',
              icon: Icons.chat_bubble_outline_rounded,
              maxLength: 2000,
              maxLines: 3,
            ),

            const SizedBox(height: AppConstants.spacingXl),

            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                label: isAr ? 'تأكيد الطلب' : 'Submit Application',
                isLoading: _isSubmitting,
                onPressed: _submit,
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType keyboardType;
  final TextDirection? textDirection;
  final int maxLines;
  final int? maxLength;
  final FormFieldValidator<String>? validator;

  const _FormField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.textDirection,
    this.maxLines = 1,
    this.maxLength,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textDirection: textDirection,
      maxLines: maxLines,
      maxLength: maxLength,
      validator: validator,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 18, color: AppConstants.colorBodyText),
      ),
    );
  }
}
