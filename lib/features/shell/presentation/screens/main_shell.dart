import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../home/presentation/screens/home_screen.dart';
import '../../../sync/presentation/bloc/sync_bloc.dart';
import '../../../sync/presentation/bloc/sync_event.dart';
import '../../../sync/presentation/bloc/sync_state.dart';
import '../../../transactions/presentation/screens/transactions_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../home/presentation/bloc/dashboard_bloc.dart';
import '../../../home/presentation/bloc/dashboard_event.dart';
import '../../../transactions/presentation/bloc/transaction_bloc.dart';
import '../../../transactions/presentation/bloc/transaction_event.dart';
import '../../../categories/presentation/bloc/category_bloc.dart';
import '../../../categories/presentation/bloc/category_event.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  DateTime? _lastPressedAt;

  @override
  void initState() {
    super.initState();
    // Auto sync pulled data on login
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<SyncBloc>().add(SyncRequested());
      }
    });
  }

  final _screens = const [HomeScreen(), TransactionsScreen(), ProfileScreen()];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final now = DateTime.now();
        if (_lastPressedAt == null ||
            now.difference(_lastPressedAt!) > const Duration(seconds: 2)) {
          _lastPressedAt = now;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Center(
                child: Text(
                  'Press back again to exit',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              backgroundColor: const Color(0xFF262626), // Match theme
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
                side: const BorderSide(
                  color: Color(0x4DFFFFFF), // #FFFFFF4D
                  width: 1,
                ),
              ),
              margin: const EdgeInsets.only(bottom: 100, left: 60, right: 60),
            ),
          );
        } else {
          await SystemNavigator.pop();
        }
      },
      child: BlocListener<SyncBloc, SyncState>(
        listener: (context, state) {
          if (state.status == SyncStatus.success) {
            if (context.mounted) {
              context.read<DashboardBloc>().add(DashboardRefreshRequested());
              context.read<TransactionBloc>().add(TransactionsLoadRequested());
              context.read<CategoryBloc>().add(CategoriesLoadRequested());
              // CustomSnackBar.showSuccess(context, 'Sync completed!');
            }
          } else if (state.status == SyncStatus.failure) {
            if (context.mounted) {
              // CustomSnackBar.showError(
              //   context,
              //   'Sync failed: ${state.errorMessage}',
              // );
            }
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: Stack(
            children: [
              // Screen content
              Positioned.fill(
                child: IndexedStack(index: _currentIndex, children: _screens),
              ),
              // Floating bottom nav
              Positioned(
                left: 0,
                right: 0,
                bottom: MediaQuery.of(context).padding.bottom + 20,
                child: Center(child: _buildGNav()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGNav() {
    return Container(
      width: 220,
      height: 64,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF262626), // #262626
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: const Color(0x4DFFFFFF), // #FFFFFF4D
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNavItem(0, 'assets/icons/ChartPieSlice.png'),
          _buildNavItem(1, 'assets/icons/ArrowsCounterClockwise.png'),
          _buildNavItem(2, 'assets/icons/UserCircleGear.png'),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, String assetPath) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 56,
        height: 56,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF312ECB)
              : Colors.transparent, // #312ECB
          borderRadius: BorderRadius.circular(100),
        ),
        child: Center(
          child: Image.asset(
            assetPath,
            width: 22,
            height: 22,
            color: isSelected
                ? Colors.white
                : Colors.white.withValues(alpha: 0.45),
          ),
        ),
      ),
    );
  }
}
