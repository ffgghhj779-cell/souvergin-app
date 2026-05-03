import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import 'app_buttons.dart';

class OfflineStateWidget extends StatelessWidget {
  final String locale;
  final VoidCallback onRetry;

  const OfflineStateWidget({
    super.key,
    required this.locale,
    required this.onRetry,
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
                color: Colors.orange.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                size: 48,
                color: Colors.orangeAccent,
              ),
            ),
            const SizedBox(height: AppConstants.spacingLg),
            Text(
              isAr ? 'أنت غير متصل بالإنترنت' : 'You\'re Offline',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: AppConstants.spacingSm),
            Text(
              isAr
                  ? 'يرجى التحقق من اتصالك بالإنترنت والمحاولة مرة أخرى.'
                  : 'Please check your internet connection and try again.',
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
