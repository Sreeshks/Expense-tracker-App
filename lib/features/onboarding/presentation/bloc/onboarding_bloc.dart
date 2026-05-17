import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'onboarding_event.dart';
import 'onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  OnboardingBloc() : super(const OnboardingState()) {
    on<OnboardingNextPressed>(_onNextPressed);
    on<OnboardingBackPressed>(_onBackPressed);
    on<OnboardingPageChanged>(_onPageChanged);
    on<OnboardingCompleted>(_onCompleted);
  }

  void _onNextPressed(
    OnboardingNextPressed event,
    Emitter<OnboardingState> emit,
  ) {
    if (state.isLastPage) {
      add(OnboardingCompleted());
      return;
    }
    emit(state.copyWith(
      currentPage: state.currentPage + 1,
      status: OnboardingStatus.navigating,
    ));
  }

  void _onBackPressed(
    OnboardingBackPressed event,
    Emitter<OnboardingState> emit,
  ) {
    if (!state.isFirstPage) {
      emit(state.copyWith(
        currentPage: state.currentPage - 1,
        status: OnboardingStatus.navigating,
      ));
    }
  }

  void _onPageChanged(
    OnboardingPageChanged event,
    Emitter<OnboardingState> emit,
  ) {
    emit(state.copyWith(
      currentPage: event.pageIndex,
      status: OnboardingStatus.navigating,
    ));
  }

  Future<void> _onCompleted(
    OnboardingCompleted event,
    Emitter<OnboardingState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    emit(state.copyWith(status: OnboardingStatus.completed));
  }
}
