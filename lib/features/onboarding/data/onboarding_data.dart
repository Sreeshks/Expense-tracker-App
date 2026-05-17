import 'package:equatable/equatable.dart';

class OnboardingPage extends Equatable {
  final String title;
  final String subtitle;

  const OnboardingPage({
    required this.title,
    required this.subtitle,
  });

  @override
  List<Object?> get props => [title, subtitle];
}

abstract final class OnboardingData {
  static const List<OnboardingPage> pages = [
    OnboardingPage(
      title: 'Privacy by Default, With Zero\nAds or Hidden Tracking',
      subtitle: 'No ads. No trackers. No third-party analytics.',
    ),
    OnboardingPage(
      title: 'Insights That Help You Spend\nBetter Without Complexity',
      subtitle: 'See category-wise spending, recent activity.',
    ),
    OnboardingPage(
      title: 'Local-First Tracking That\nStays Fully On Your Device',
      subtitle: 'Your finances stay on your phone.',
    ),
  ];
}
