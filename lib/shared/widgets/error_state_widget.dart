import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import 'app_buttons.dart';

class ErrorStateWidget extends StatelessWidget {
  final String locale;
  final VoidCallback onRetry;
  final String? message;

  const ErrorStateWidget({
    super.key,
    required this.locale,
    required this.onRetry,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    final isAr = locale == 'ar';
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingXl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppConstants.spacingLg),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: Colors.redAccent,
              ),
            ),
            const SizedBox(height: AppConstants.spacingLg),
            Text(
              isAr ? 'حدث خطأ ما' : 'Something Went Wrong',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: AppConstants.spacingSm),
            Text(
              message ??
                  (isAr
                      ? 'يرجى المحاولة مرة أخرى لاحقاً.'
                      : 'Please try again later.'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppConstants.colorBodyText,
              ),
            ),
            const SizedBox(height: AppConstants.spacingXl),
            PrimaryButton(
              label: isAr ? 'إعادة المحاولة' : 'Try Again',
              icon: Icons.refresh_rounded,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
