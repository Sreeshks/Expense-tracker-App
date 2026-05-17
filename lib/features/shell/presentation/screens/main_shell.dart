import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../home/presentation/screens/home_screen.dart';
import '../../../sync/presentation/bloc/sync_bloc.dart';
import '../../../sync/presentation/bloc/sync_state.dart';
import '../../../transactions/presentation/screens/transactions_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final _screens = const [HomeScreen(), TransactionsScreen(), ProfileScreen()];

  @override
  Widget build(BuildContext context) {
    return BlocListener<SyncBloc, SyncState>(
      listener: (context, state) {
        if (state.status == SyncStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Sync completed!', style: GoogleFonts.inter()),
              backgroundColor: const Color(0xFF1DB954),
              duration: const Duration(seconds: 2),
            ),
          );
        } else if (state.status == SyncStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Sync failed: ${state.errorMessage}',
                style: GoogleFonts.inter(),
              ),
              backgroundColor: const Color(0xFFFF4444),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: IndexedStack(index: _currentIndex, children: _screens),
        bottomNavigationBar: _buildGNav(),
      ),
    );
  }

  Widget _buildGNav() {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 12,
          bottom: bottomPadding + 12,
        ),
        child: GNav(
          gap: 8,
          activeColor: Colors.white,
          iconSize: 22,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          duration: const Duration(milliseconds: 300),
          tabBackgroundColor: const Color(0xFF312ECB),
          color: Colors.white.withValues(alpha: 0.45),
          tabs: [
            GButton(
              icon: Icons.circle,
              leading: Image.asset(
                'assets/icons/ChartPieSlice.png',
                width: 22,
                height: 22,
                color: _currentIndex == 0
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.45),
              ),
              text: ' Dashboard',
              textStyle: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            GButton(
              icon: Icons.circle,
              leading: Image.asset(
                'assets/icons/ArrowsCounterClockwise.png',
                width: 22,
                height: 22,
                color: _currentIndex == 1
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.45),
              ),
              text: ' Transactions',
              textStyle: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            GButton(
              icon: Icons.circle,
              leading: Image.asset(
                'assets/icons/UserCircleGear.png',
                width: 22,
                height: 22,
                color: _currentIndex == 2
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.45),
              ),
              text: ' Account',
              textStyle: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
          selectedIndex: _currentIndex,
          onTabChange: (index) {
            setState(() => _currentIndex = index);
          },
        ),
      ),
    );
  }
}
