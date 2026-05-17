import 'package:equatable/equatable.dart';

enum OnboardingStatus { initial, navigating, completed }

class OnboardingState extends Equatable {
  final int currentPage;
  final int totalPages;
  final OnboardingStatus status;

  const OnboardingState({
    this.currentPage = 0,
    this.totalPages = 3,
    this.status = OnboardingStatus.initial,
  });

  bool get isFirstPage => currentPage == 0;
  bool get isLastPage => currentPage == totalPages - 1;

  OnboardingState copyWith({
    int? currentPage,
    int? totalPages,
    OnboardingStatus? status,
  }) {
    return OnboardingState(
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [currentPage, totalPages, status];
}
