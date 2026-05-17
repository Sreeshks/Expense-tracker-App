import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  String _phone = '';
  String _expectedOtp = '';
  bool _userExists = false;
  String? _token;

  AuthBloc({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository(),
        super(AuthInitial()) {
    on<SendOtpRequested>(_onSendOtp);
    on<VerifyOtpRequested>(_onVerifyOtp);
    on<CreateAccountRequested>(_onCreateAccount);
  }

  Future<void> _onSendOtp(
    SendOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      _phone = event.phone;
      final response = await _authRepository.sendOtp(event.phone);
      _expectedOtp = response.otp;
      _userExists = response.userExists;
      _token = response.token;

      emit(OtpSent(
        otp: response.otp,
        userExists: response.userExists,
        nickname: response.nickname,
        token: response.token,
        phone: event.phone,
      ));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onVerifyOtp(
    VerifyOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (event.enteredOtp != _expectedOtp) {
      emit(const AuthError('Invalid OTP. Please try again.'));
      return;
    }

    emit(AuthLoading());

    try {
      if (_userExists && _token != null) {
        final otpState = state;
        String nickname = 'User';
        if (otpState is OtpSent && otpState.nickname != null) {
          nickname = otpState.nickname!;
        }

        await _authRepository.saveAuthData(
          token: _token!,
          nickname: nickname,
          phone: _phone,
        );
        emit(Authenticated(nickname: nickname));
      } else {
        emit(NicknameRequired(phone: _phone, token: _token ?? ''));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onCreateAccount(
    CreateAccountRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final response = await _authRepository.createAccount(
        phone: _phone,
        nickname: event.nickname,
      );

      await _authRepository.saveAuthData(
        token: response.token,
        nickname: event.nickname,
        phone: _phone,
      );

      emit(Authenticated(nickname: event.nickname));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
