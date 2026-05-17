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
              child: Center(child: SizedBox(width: 230, child: _buildGNav())),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGNav() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: GNav(
          gap: 0,
          activeColor: Colors.white,
          iconSize: 22,
          padding: const EdgeInsets.all(12),
          duration: const Duration(milliseconds: 300),
          tabBackgroundColor: const Color(0xFF312ECB),
          tabBorderRadius: 24,
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
