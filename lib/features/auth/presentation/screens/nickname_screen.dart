import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class NicknameScreen extends StatefulWidget {
  final AuthBloc authBloc;

  const NicknameScreen({super.key, required this.authBloc});

  @override
  State<NicknameScreen> createState() => _NicknameScreenState();
}

class _NicknameScreenState extends State<NicknameScreen> {
  final _nicknameController = TextEditingController();

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  bool get _isValid => _nicknameController.text.trim().length >= 2;

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: widget.authBloc,
      child: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil('/home', (route) => false);
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red.shade700,
              ),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 48),
                    Text(
                      '👋 What should we call you?',
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.w600, // Semi Bold
                        height: 1.5, // 150% line-height
                        letterSpacing: 24 * -0.05, // -5% letter-spacing
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This name stays only on your device.',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w400, // Regular
                        height: 24 / 15, // 24px line-height
                        letterSpacing: 15 * -0.04, // -4% letter-spacing
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Center(
                      child: SizedBox(
                        width: 343,
                        height: 56,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.1),
                            ),
                          ),
                          padding: const EdgeInsets.only(
                            top: 10,
                            bottom: 10,
                            left: 16,
                            right: 16,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _nicknameController,
                                  textCapitalization: TextCapitalization.words,
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Eg: Johnnnie',
                                    hintStyle: GoogleFonts.inter(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400, // Regular
                                      height: 1.0, // 100% line-height
                                      letterSpacing:
                                          15 * -0.03, // -3% letter-spacing
                                      color: Colors.white.withValues(
                                        alpha: 0.3,
                                      ),
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  onChanged: (_) => setState(() {}),
                                ),
                              ),
                              if (_isValid)
                                const Icon(
                                  Icons.check_circle,
                                  color: Color(0xFF1DB954),
                                  size: 22,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: SizedBox(
                        width: 343,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: (state is AuthLoading || !_isValid)
                              ? null
                              : () {
                                  context.read<AuthBloc>().add(
                                    CreateAccountRequested(
                                      _nicknameController.text.trim(),
                                    ),
                                  );
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF312ECB),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: const Color(
                              0xFF312ECB,
                            ).withValues(alpha: 0.3), // disabled opacity 0.3
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
                                  'Continue',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600, // Semi Bold
                                    height: 1.0, // 100% line-height
                                    letterSpacing:
                                        16 * -0.03, // -3% letter-spacing
                                  ),
                                ),
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
