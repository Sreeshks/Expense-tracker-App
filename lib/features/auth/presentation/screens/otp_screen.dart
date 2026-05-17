import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class OtpScreen extends StatefulWidget {
  final AuthBloc authBloc;

  const OtpScreen({super.key, required this.authBloc});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _pinController = TextEditingController();
  final _focusNode = FocusNode();

  Timer? _resendTimer;
  int _resendSeconds = 30;
  String _maskedPhone = '';

  @override
  void initState() {
    super.initState();
    _startResendTimer();

    final state = widget.authBloc.state;
    if (state is OtpSent) {
      final phone = state.phone;
      if (phone.length >= 4) {
        _maskedPhone =
            '${phone.substring(0, phone.length - 4)}****${phone.substring(phone.length - 2)}';
      }
      // Show OTP as a local notification
      _showOtpNotification(state.otp);
    }

    _focusNode.requestFocus();
  }

  Future<void> _showOtpNotification(String otp) async {
    await NotificationService.instance.showOtpNotification(otp: otp);
  }

  void _startResendTimer() {
    _resendSeconds = 30;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendSeconds > 0) {
        setState(() => _resendSeconds--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _pinController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 51,
      height: 64,
      textStyle: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF312ECB), width: 1.5),
      ),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF312ECB).withValues(alpha: 0.4),
        ),
      ),
    );

    return BlocProvider.value(
      value: widget.authBloc,
      child: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil('/home', (route) => false);
          } else if (state is NicknameRequired) {
            Navigator.of(
              context,
            ).pushReplacementNamed('/nickname', arguments: widget.authBloc);
          } else if (state is AuthError) {
            CustomSnackBar.showError(context, state.message);
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    // Back button
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.chevron_left,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Title
                    Text(
                      'Verify OTP',
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.w600, // Semi Bold
                        height: 1.5, // 150% line-height
                        letterSpacing: 24 * -0.05, // -5% letter-spacing
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Subtitle
                    RichText(
                      text: TextSpan(
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w400, // Regular
                          height: 24 / 15, // 24px line-height
                          letterSpacing: 15 * -0.04, // -4% letter-spacing
                          color: Colors.white.withValues(
                            alpha: 0.6,
                          ), // 60% opacity
                        ),
                        children: [
                          const TextSpan(
                            text: 'Enter the 6-Digit code sent to ',
                          ),
                          TextSpan(text: _maskedPhone),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Change Number link
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Text(
                        'Change Number',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w500, // Medium
                          height: 24 / 15, // 24px line-height
                          letterSpacing: 15 * -0.04, // -4% letter-spacing
                          color: const Color(0xFF007AFF), // #007AFF
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Pinput OTP field
                    SizedBox(
                      width: 342,
                      height: 64,
                      child: Pinput(
                        length: 6,
                        controller: _pinController,
                        focusNode: _focusNode,
                        defaultPinTheme: defaultPinTheme,
                        focusedPinTheme: focusedPinTheme,
                        submittedPinTheme: submittedPinTheme,
                        separatorBuilder: (index) => const SizedBox(width: 7.2),
                        hapticFeedbackType: HapticFeedbackType.lightImpact,
                        preFilledWidget: Text(
                          '-',
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                        ),
                        cursor: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              width: 22,
                              height: 2,
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF312ECB),
                                borderRadius: BorderRadius.circular(1),
                              ),
                            ),
                          ],
                        ),
                        onCompleted: (pin) {
                          context.read<AuthBloc>().add(VerifyOtpRequested(pin));
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Verify button
                    Center(
                      child: SizedBox(
                        width: 343,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: state is AuthLoading
                              ? null
                              : () {
                                  final otp = _pinController.text;
                                  if (otp.length == 6) {
                                    context.read<AuthBloc>().add(
                                      VerifyOtpRequested(otp),
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF312ECB),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.all(10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: state is AuthLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  'Verify',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600, // Semi Bold
                                    height: 1.0, // 100% line-height
                                    letterSpacing:
                                        16 * -0.03, // -3% letter-spacing
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Resend timer
                    _resendSeconds > 0
                        ? Text(
                            'Resend OTP in ${_resendSeconds}s',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w400, // Regular
                              height: 1.0, // 100% line-height
                              letterSpacing: 14 * -0.03, // -3% letter-spacing
                              color: Colors.white.withValues(
                                alpha: 0.6,
                              ), // #FFFFFF99 60%
                            ),
                          )
                        : GestureDetector(
                            onTap: () {
                              final blocState = widget.authBloc.state;
                              if (blocState is OtpSent) {
                                widget.authBloc.add(
                                  SendOtpRequested(blocState.phone),
                                );
                                _startResendTimer();
                              }
                            },
                            child: Text(
                              'Resend OTP',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                height: 1.0,
                                letterSpacing: 14 * -0.03,
                                color: const Color(0xFF007AFF),
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
