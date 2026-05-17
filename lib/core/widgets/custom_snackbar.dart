import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/asset_paths.dart';

class CustomSnackBar {
  static void showError(BuildContext context, String message) {
    _show(
      context: context,
      message: message,
      backgroundColor: const Color(0xFF1F1212), // Dark red/burgundy tint
      borderColor: const Color(0xFFFF5252),
      statusColor: const Color(0xFFFF5252),
      statusIcon: Icons.error_rounded,
    );
  }

  static void showSuccess(BuildContext context, String message) {
    _show(
      context: context,
      message: message,
      backgroundColor: const Color(0xFF101F15), // Dark green tint
      borderColor: const Color(0xFF4CAF50),
      statusColor: const Color(0xFF4CAF50),
      statusIcon: Icons.check_circle_rounded,
    );
  }

  static void showInfo(BuildContext context, String message) {
    _show(
      context: context,
      message: message,
      backgroundColor: const Color(0xFF10171F), // Dark blue/cyan tint
      borderColor: const Color(0xFF2196F3),
      statusColor: const Color(0xFF2196F3),
      statusIcon: Icons.info_rounded,
    );
  }

  static String _cleanErrorMessage(String message) {
    var msg = message;
    
    // Clean "Sync failed: " prefix if present
    if (msg.startsWith('Sync failed: ')) {
      msg = msg.substring('Sync failed: '.length);
    }
    
    // Clean ApiException(code): message
    if (msg.contains('ApiException')) {
      final parts = msg.split(':');
      if (parts.length > 1) {
        msg = parts.sublist(1).join(':').trim();
      }
    }
    
    // Friendly text mapping
    if (msg.contains('Category not found')) {
      return 'Category was not found on cloud server.';
    }
    if (msg.contains('Transaction not found')) {
      return 'Transaction was not found on cloud server.';
    }
    if (msg.contains('SocketException') || msg.contains('Failed host lookup') || msg.contains('NetworkIsUnreachable')) {
      return 'No internet connection. Please check your network.';
    }
    if (msg.contains('HttpException') || msg.contains('connection closed')) {
      return 'Failed to reach cloud server. Please try again.';
    }
    
    return msg;
  }

  static void _show({
    required BuildContext context,
    required String message,
    required Color backgroundColor,
    required Color borderColor,
    required Color statusColor,
    required IconData statusIcon,
  }) {
    final cleanedMessage = _cleanErrorMessage(message);

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
              color: borderColor.withValues(alpha: 0.15),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: statusColor.withValues(alpha: 0.08),
                blurRadius: 16,
                spreadRadius: 2,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Stack(
              children: [
                // Glowing background spot
                Positioned(
                  right: -30,
                  top: -30,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: statusColor.withValues(alpha: 0.06),
                    ),
                  ),
                ),
                // Beautiful Colored Left Accent Bar
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 5,
                    color: statusColor,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 19, right: 14, top: 12, bottom: 12),
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
                          cleanedMessage,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
