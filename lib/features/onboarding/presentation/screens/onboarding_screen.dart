import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/asset_paths.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/onboarding_data.dart';
import '../bloc/onboarding_bloc.dart';
import '../bloc/onboarding_event.dart';
import '../bloc/onboarding_state.dart';
import '../widgets/page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onCompleted() {
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/phone');
  }

  void _animateToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return BlocProvider(
      create: (_) => OnboardingBloc(),
      child: BlocConsumer<OnboardingBloc, OnboardingState>(
        listenWhen: (prev, curr) =>
            prev.status != OnboardingStatus.completed &&
            curr.status == OnboardingStatus.completed,
        listener: (context, state) => _onCompleted(),
        builder: (context, state) {
          return Scaffold(
            backgroundColor: Colors.black,
            body: Stack(
              children: [
                _buildFullScreenImage(),
                _buildGradientOverlay(),
                _buildSwipeDetector(context),
                _buildSkipButton(context, state),
                _buildBottomContent(context, state, bottomPadding),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFullScreenImage() {
    return Positioned.fill(
      child: Image.asset(
        AssetPaths.walkthroughBg,
        fit: BoxFit.cover,
        width: double.infinity,
        alignment: Alignment.topCenter,
      ),
    );
  }

  Widget _buildGradientOverlay() {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.0),
              Colors.black.withValues(alpha: 0.0),
              Colors.black.withValues(alpha: 0.35),
              Colors.black,
              Colors.black,
            ],
            stops: const [0.0, 0.35, 0.55, 0.65, 1.0],
          ),
        ),
      ),
    );
  }

  Widget _buildSwipeDetector(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      bottom: MediaQuery.of(context).size.height * 0.35,
      child: PageView.builder(
        controller: _pageController,
        itemCount: OnboardingData.pages.length,
        onPageChanged: (index) {
          context.read<OnboardingBloc>().add(OnboardingPageChanged(index));
        },
        itemBuilder: (context, index) {
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildSkipButton(BuildContext context, OnboardingState state) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 12,
      right: 16,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 250),
        opacity: state.isLastPage ? 0.0 : 1.0,
        child: GestureDetector(
          onTap: state.isLastPage
              ? null
              : () => context.read<OnboardingBloc>().add(OnboardingCompleted()),
          child: Text(
            'SKIP',
            style: AppTextStyles.labelSmall.copyWith(
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomContent(
    BuildContext context,
    OnboardingState state,
    double bottomPadding,
  ) {
    final page = OnboardingData.pages[state.currentPage];

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: bottomPadding + 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            PageIndicator(
              totalPages: state.totalPages,
              currentPage: state.currentPage,
            ),
            const SizedBox(height: 24),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: SizedBox(
                width: double.infinity,
                key: ValueKey('title_${state.currentPage}'),
                child: Text(page.title, style: AppTextStyles.onboardingTitle),
              ),
            ),
            const SizedBox(height: 8),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: SizedBox(
                width: double.infinity,
                key: ValueKey('sub_${state.currentPage}'),
                child: Text(page.subtitle, style: AppTextStyles.onboardingBody),
              ),
            ),
            const SizedBox(height: 24),
            _buildBottomActions(context, state),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context, OnboardingState state) {
    return Row(
      children: [
        if (!state.isFirstPage)
          GestureDetector(
            onTap: () {
              context.read<OnboardingBloc>().add(OnboardingBackPressed());
              _animateToPage(state.currentPage - 1);
            },
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white, width: 1),
              ),
              padding: const EdgeInsets.all(12),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        if (!state.isFirstPage) const SizedBox(width: 16),
        Expanded(
          child: GestureDetector(
            onTap: () {
              if (state.isLastPage) {
                context.read<OnboardingBloc>().add(OnboardingCompleted());
              } else {
                context.read<OnboardingBloc>().add(OnboardingNextPressed());
                _animateToPage(state.currentPage + 1);
              }
            },
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF312ECB),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(10),
              alignment: Alignment.center,
              child: Text(
                state.isLastPage ? 'Get Started' : 'Next',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
