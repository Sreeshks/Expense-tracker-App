abstract final class ApiConstants {
  static const String baseUrl = 'https://appskilltest.zybotech.in';

  static const String sendOtp = '/auth/send-otp/';
  static const String createAccount = '/auth/create-account/';

  static const String getCategories = '/categories/';
  static const String addCategories = '/categories/add/';
  static const String deleteCategories = '/categories/delete/';

  static const String getTransactions = '/transactions/';
  static const String addTransactions = '/transactions/add/';
  static const String deleteTransactions = '/transactions/delete/';

  static const String tokenKey = 'auth_token';
  static const String nicknameKey = 'nickname';
  static const String phoneKey = 'phone';
  static const String onboardingCompleteKey = 'onboarding_complete';
}
