import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/auth_response.dart';

class AuthRepository {
  final ApiClient _apiClient;

  AuthRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<AuthResponse> sendOtp(String phone) async {
    final response = await _apiClient.postForm(
      ApiConstants.sendOtp,
      {'phone': phone},
    );
    return AuthResponse.fromJson(response);
  }

  Future<CreateAccountResponse> createAccount({
    required String phone,
    required String nickname,
  }) async {
    final response = await _apiClient.postForm(
      ApiConstants.createAccount,
      {'phone': phone, 'nickname': nickname},
    );
    return CreateAccountResponse.fromJson(response);
  }

  Future<void> saveAuthData({
    required String token,
    required String nickname,
    required String phone,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(ApiConstants.tokenKey, token);
    await prefs.setString(ApiConstants.nicknameKey, nickname);
    await prefs.setString(ApiConstants.phoneKey, phone);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(ApiConstants.tokenKey);
  }

  Future<String?> getNickname() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(ApiConstants.nicknameKey);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(ApiConstants.tokenKey);
    await prefs.remove(ApiConstants.nicknameKey);
    await prefs.remove(ApiConstants.phoneKey);
  }
}
