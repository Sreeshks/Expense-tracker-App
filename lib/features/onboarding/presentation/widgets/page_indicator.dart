import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class PageIndicator extends StatelessWidget {
  final int totalPages;
  final int currentPage;

  const PageIndicator({
    super.key,
    required this.totalPages,
    required this.currentPage,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalPages, (index) {
        final isActive = index == currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: EdgeInsets.only(right: index < totalPages - 1 ? 8 : 0),
          height: 4,
          width: 109,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            color: isActive
                ? AppColors.indicatorActive
                : AppColors.indicatorInactive,
          ),
        );
      }),
    );
  }
}
