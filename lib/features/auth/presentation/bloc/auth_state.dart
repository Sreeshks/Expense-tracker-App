import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class OtpSent extends AuthState {
  final String otp;
  final bool userExists;
  final String? nickname;
  final String? token;
  final String phone;

  const OtpSent({
    required this.otp,
    required this.userExists,
    this.nickname,
    this.token,
    required this.phone,
  });

  @override
  List<Object?> get props => [otp, userExists, nickname, token, phone];
}

class NicknameRequired extends AuthState {
  final String phone;
  final String token;
  const NicknameRequired({required this.phone, required this.token});
  @override
  List<Object?> get props => [phone, token];
}

class Authenticated extends AuthState {
  final String nickname;
  const Authenticated({required this.nickname});
  @override
  List<Object?> get props => [nickname];
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
  @override
  List<Object?> get props => [message];
}
