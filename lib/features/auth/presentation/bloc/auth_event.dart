import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class SendOtpRequested extends AuthEvent {
  final String phone;
  const SendOtpRequested(this.phone);
  @override
  List<Object?> get props => [phone];
}

class VerifyOtpRequested extends AuthEvent {
  final String enteredOtp;
  const VerifyOtpRequested(this.enteredOtp);
  @override
  List<Object?> get props => [enteredOtp];
}

class CreateAccountRequested extends AuthEvent {
  final String nickname;
  const CreateAccountRequested(this.nickname);
  @override
  List<Object?> get props => [nickname];
}
