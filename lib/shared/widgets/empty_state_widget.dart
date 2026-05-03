import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

class EmptyStateWidget extends StatelessWidget {
  final String locale;
  final String? title;
  final String? message;
  final IconData icon;

  const EmptyStateWidget({
    super.key,
    required this.locale,
    this.title,
    this.message,
    this.icon = Icons.search_off_rounded,
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
                color: AppConstants.colorCard,
                shape: BoxShape.circle,
                border: Border.all(color: AppConstants.colorBorder),
              ),
              child: Icon(
                icon,
                size: 48,
                color: AppConstants.colorBodyText,
              ),
            ),
            const SizedBox(height: AppConstants.spacingLg),
            Text(
              title ?? (isAr ? 'لا توجد نتائج' : 'No Results Found'),
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
                      ? 'لم نتمكن من العثور على أي بيانات مطابقة.'
                      : 'We couldn\'t find any matching data.'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppConstants.colorBodyText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
