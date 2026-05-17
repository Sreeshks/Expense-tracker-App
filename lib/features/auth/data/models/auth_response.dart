import 'package:equatable/equatable.dart';

class AuthResponse extends Equatable {
  final String status;
  final String otp;
  final bool userExists;
  final String? nickname;
  final String? token;

  const AuthResponse({
    required this.status,
    required this.otp,
    required this.userExists,
    this.nickname,
    this.token,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      status: json['status'] as String,
      otp: json['otp'].toString(),
      userExists: json['user_exists'] as bool,
      nickname: json['nickname'] as String?,
      token: json['token'] as String?,
    );
  }

  @override
  List<Object?> get props => [status, otp, userExists, nickname, token];
}

class CreateAccountResponse extends Equatable {
  final String status;
  final String token;

  const CreateAccountResponse({required this.status, required this.token});

  factory CreateAccountResponse.fromJson(Map<String, dynamic> json) {
    return CreateAccountResponse(
      status: json['status'] as String,
      token: json['token'] as String,
    );
  }

  @override
  List<Object?> get props => [status, token];
}
