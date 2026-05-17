import 'package:flutter/material.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/screens/nickname_screen.dart';
import '../../features/auth/presentation/screens/otp_screen.dart';
import '../../features/auth/presentation/screens/phone_input_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/shell/presentation/screens/main_shell.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return _fadeRoute(const SplashScreen(), settings);
      case '/onboarding':
        return _fadeRoute(const OnboardingScreen(), settings);
      case '/phone':
        return _fadeRoute(const PhoneInputScreen(), settings);
      case '/otp':
        final authBloc = settings.arguments as AuthBloc;
        return _fadeRoute(OtpScreen(authBloc: authBloc), settings);
      case '/nickname':
        final authBloc = settings.arguments as AuthBloc;
        return _fadeRoute(NicknameScreen(authBloc: authBloc), settings);
      case '/home':
        return _fadeRoute(const MainShell(), settings);
      default:
        return _fadeRoute(const SplashScreen(), settings);
    }
  }

  static PageRouteBuilder _fadeRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}
