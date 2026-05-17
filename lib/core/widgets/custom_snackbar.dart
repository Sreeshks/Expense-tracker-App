import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/asset_paths.dart';

class CustomSnackBar {
  static void showError(BuildContext context, String message) {
    _show(
      context: context,
      message: message,
      backgroundColor: const Color(0xFF1F1212),
      borderColor: const Color(0xFFFF5252),
      statusColor: const Color(0xFFFF5252),
      statusIcon: Icons.error_rounded,
    );
  }

  static void showSuccess(BuildContext context, String message) {
    _show(
      context: context,
      message: message,
      backgroundColor: const Color(0xFF101F15),
      borderColor: const Color(0xFF4CAF50),
      statusColor: const Color(0xFF4CAF50),
      statusIcon: Icons.check_circle_rounded,
    );
  }

  static void showInfo(BuildContext context, String message) {
    _show(
      context: context,
      message: message,
      backgroundColor: const Color(0xFF10171F),
      borderColor: const Color(0xFF2196F3),
      statusColor: const Color(0xFF2196F3),
      statusIcon: Icons.info_rounded,
    );
  }

  static void _show({
    required BuildContext context,
    required String message,
    required Color backgroundColor,
    required Color borderColor,
    required Color statusColor,
    required IconData statusIcon,
  }) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(left: 16, right: 16, bottom: 80),
        padding: EdgeInsets.zero,
        duration: const Duration(seconds: 3),
        content: Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: borderColor.withValues(alpha: 0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                // Logo with subtle background
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: statusColor.withValues(alpha: 0.1),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.15),
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Image.asset(AssetPaths.logo, fit: BoxFit.contain),
                  ),
                ),
                const SizedBox(width: 12),
                // Message Text
                Expanded(
                  child: Text(
                    message,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 10),
                // Status Icon
                Icon(statusIcon, color: statusColor, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
