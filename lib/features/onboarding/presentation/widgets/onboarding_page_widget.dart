import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_styles.dart';

class OnboardingPageWidget extends StatelessWidget {
  final String title;
  final String subtitle;

  const OnboardingPageWidget({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: AppTextStyles.headlineMedium,
          ),
          const SizedBox(height: 12),
          Text(
            subtitle,
            style: AppTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }
}
