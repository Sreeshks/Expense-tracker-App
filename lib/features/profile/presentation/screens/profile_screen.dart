import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/database/app_database.dart';
import '../../../categories/presentation/bloc/category_bloc.dart';
import '../../../categories/presentation/bloc/category_event.dart';
import '../../../categories/presentation/bloc/category_state.dart';
import '../../../home/presentation/bloc/dashboard_bloc.dart';
import '../../../home/presentation/bloc/dashboard_event.dart';
import '../../../transactions/presentation/bloc/transaction_bloc.dart';
import '../../../transactions/presentation/bloc/transaction_event.dart';

import '../../../sync/presentation/bloc/sync_bloc.dart';
import '../../../sync/presentation/bloc/sync_event.dart';
import '../../../sync/presentation/bloc/sync_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _categoryController = TextEditingController();
  final _limitController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _parentScrollController = ScrollController();
  String _nickname = 'User';
  double _currentLimit = 1000;
  bool _isEditingNickname = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    context.read<CategoryBloc>().add(CategoriesLoadRequested());
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nickname = prefs.getString(ApiConstants.nicknameKey) ?? 'User';
      _currentLimit = prefs.getDouble('monthly_limit') ?? 1000;
      _nicknameController.text = _nickname;
    });
  }

  Future<void> _saveLimit() async {
    final amount = double.tryParse(_limitController.text.trim());
    if (amount == null || amount <= 0) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('monthly_limit', amount);
    setState(() => _currentLimit = amount);
    _limitController.clear();

    if (mounted) {
      FocusScope.of(context).unfocus();
      // Notify DashboardBloc to update the limit display
      context.read<DashboardBloc>().add(DashboardRefreshRequested());
    }
  }

  Future<void> _saveNickname() async {
    final name = _nicknameController.text.trim();
    if (name.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(ApiConstants.nicknameKey, name);
    setState(() {
      _nickname = name;
      _isEditingNickname = false;
    });

    if (mounted) {
      context.read<DashboardBloc>().add(DashboardRefreshRequested());
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(ApiConstants.tokenKey);
    await prefs.remove(ApiConstants.nicknameKey);
    await prefs.remove(ApiConstants.phoneKey);
    await prefs.remove('monthly_limit');

    // Reset in-memory BLoC states to prevent visual leakage for different users
    if (mounted) {
      context.read<DashboardBloc>().add(DashboardReset());
      context.read<TransactionBloc>().add(TransactionsReset());
      context.read<CategoryBloc>().add(CategoriesReset());
    }

    // Clear local database
    await AppDatabase.instance.clearAllData();

    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/phone', (route) => false);
    }
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _limitController.dispose();
    _nicknameController.dispose();
    _parentScrollController.dispose();
    super.dispose();
  }

  Widget _buildSeparator() {
    return Center(
      child: Container(
        width: 375,
        height: 3,
        color: const Color(0x0DFFFFFF), // #FFFFFF0D
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          controller: _parentScrollController,
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 120),
          children: [
            const SizedBox(height: 20),

            // Profile & Settings Title
            Center(
              child: SizedBox(
                width: 343,
                child: Text(
                  'Profile & Settings',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w600, // Semi Bold
                    height: 1.5, // 150% line-height
                    letterSpacing: 20 * -0.05, // -5% letter-spacing
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // _buildSeparator(),
            // const SizedBox(height: 24),

            // --- NICKNAME ---
            _sectionLabel('NICKNAME'),
            const SizedBox(height: 8),
            Center(child: _buildNicknameRow()),
            const SizedBox(height: 24),
            _buildSeparator(),
            const SizedBox(height: 24),

            // --- ALERT LIMIT ---
            Center(child: _buildAlertLimitCard()),
            const SizedBox(height: 24),
            _buildSeparator(),
            const SizedBox(height: 24),

            // --- CATEGORIES ---
            _sectionLabel('CATEGORIES'),
            const SizedBox(height: 8),
            _buildCategoriesCard(),
            const SizedBox(height: 24),
            _buildSeparator(),
            const SizedBox(height: 24),

            // --- CLOUD SYNC ---
            _sectionLabel('CLOUD SYNC'),
            const SizedBox(height: 8),
            Center(child: _buildSyncCard()),
            const SizedBox(height: 24),
            // _buildSeparator(),
            // const SizedBox(height: 24),

            // --- LOG OUT ---
            _buildLogoutButton(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Center(
      child: SizedBox(
        width: 343,
        child: Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400, // Regular
            height: 1.5, // 150% line-height
            letterSpacing: 14 * -0.05, // -5% letter-spacing
            color: Colors.white.withValues(alpha: 0.6), // #FFFFFF99 (60%)
          ),
        ),
      ),
    );
  }

  Widget _buildNicknameRow() {
    return Container(
      width: 343,
      height: 64,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1), // #FFFFFF1A
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: _isEditingNickname
                ? TextField(
                    controller: _nicknameController,
                    autofocus: true,
                    style: const TextStyle(
                      fontFamily: 'Helvetica Neue',
                      fontWeight: FontWeight.w500,
                      fontSize: 20,
                      height: 1.0,
                      color: Colors.white,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onSubmitted: (_) => _saveNickname(),
                  )
                : Text(
                    _nickname,
                    style: const TextStyle(
                      fontFamily: 'Helvetica Neue',
                      fontWeight: FontWeight.w500,
                      fontSize: 20,
                      height: 1.0,
                      letterSpacing: 20 * -0.03, // -3% letter spacing
                      color: Colors.white,
                    ),
                  ),
          ),
          GestureDetector(
            onTap: () {
              if (_isEditingNickname) {
                _saveNickname();
              } else {
                setState(() => _isEditingNickname = true);
              }
            },
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.black, // #000000
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.white, // #FFFFFF
                  width: 1,
                ),
              ),
              child: Center(
                child: Icon(
                  _isEditingNickname ? Icons.check : Icons.edit_outlined,
                  color: Colors.white,
                  size: 16, // 16x16 icon size
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertLimitCard() {
    return Center(
      child: Container(
        width: 343,
        height: 145,
        padding: const EdgeInsets.only(
          top: 20,
          bottom: 20,
          left: 16,
          right: 16,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1), // #FFFFFF1A
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'ALERT LIMIT (₹)',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w400, // Regular
                height: 1.5, // 150% line-height
                letterSpacing: 14 * -0.05, // -5% letter-spacing
                color: Colors.white.withValues(alpha: 0.6), // Muted white
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.only(
                      top: 10,
                      bottom: 10,
                      left: 16,
                      right: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1), // #FFFFFF1A
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: TextField(
                        controller: _limitController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                        ],
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          color: Colors.white,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Amount  (₹)',
                          hintStyle: GoogleFonts.inter(
                            fontSize: 15,
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _saveLimit,
                  child: Container(
                    width: 54,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF312ECB), // #312ECB
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        'Set',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500, // Medium
                          height: 1.5,
                          letterSpacing: 14 * -0.05,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Text(
              'Current Limit: ₹${_currentLimit.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},')}',
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w400, // Regular
                height: 1.0, // 100% line-height
                letterSpacing: 15 * -0.03, // -3% letter-spacing
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesCard() {
    return Center(
      child: Container(
        width: 343,
        height: 368,
        padding: const EdgeInsets.only(
          top: 20,
          bottom: 20,
          left: 16,
          right: 16,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1), // #FFFFFF1A
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Input row
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.only(
                      top: 10,
                      bottom: 10,
                      left: 16,
                      right: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1), // #FFFFFF1A
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: TextField(
                        controller: _categoryController,
                        textCapitalization: TextCapitalization.words,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          color: Colors.white,
                        ),
                        decoration: InputDecoration(
                          hintText: 'New category Name',
                          hintStyle: GoogleFonts.inter(
                            fontSize: 15,
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {
                    final name = _categoryController.text.trim();
                    if (name.isNotEmpty) {
                      context.read<CategoryBloc>().add(CategoryAdded(name));
                      _categoryController.clear();
                      FocusScope.of(context).unfocus();
                    }
                  },
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF312ECB),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: Colors.white10, height: 1),
            const SizedBox(height: 12),
            // Dynamic Categories List with advanced scroll propagation listener
            Expanded(
              child: BlocBuilder<CategoryBloc, CategoryState>(
                builder: (context, state) {
                  if (state.categories.isEmpty) {
                    return Center(
                      child: Text(
                        'No categories added yet.',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                      ),
                    );
                  }
                  return NotificationListener<ScrollNotification>(
                    onNotification: (ScrollNotification notification) {
                      if (notification is ScrollUpdateNotification) {
                        final double delta = notification.scrollDelta ?? 0;
                        if (delta != 0 && _parentScrollController.hasClients) {
                          final double currentOffset =
                              _parentScrollController.offset;
                          final double maxParentScroll =
                              _parentScrollController.position.maxScrollExtent;
                          final double minParentScroll =
                              _parentScrollController.position.minScrollExtent;

                          // If reached bottom boundary and scrolling down, scroll parent down
                          if (notification.metrics.pixels >=
                                  notification.metrics.maxScrollExtent &&
                              delta > 0) {
                            final double newOffset = (currentOffset + delta)
                                .clamp(minParentScroll, maxParentScroll);
                            _parentScrollController.jumpTo(newOffset);
                          }
                          // If reached top boundary and scrolling up, scroll parent up
                          else if (notification.metrics.pixels <=
                                  notification.metrics.minScrollExtent &&
                              delta < 0) {
                            final double newOffset = (currentOffset + delta)
                                .clamp(minParentScroll, maxParentScroll);
                            _parentScrollController.jumpTo(newOffset);
                          }
                        }
                      }
                      return false;
                    },
                    child: ListView.separated(
                      itemCount: state.categories.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final cat = state.categories[index];
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              cat.name,
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => context.read<CategoryBloc>().add(
                                CategoryDeleted(cat.id),
                              ),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: const Color(0x26B50303), // #B5030326
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: const Color(0xFFB50303), // #B50303
                                    width: 1,
                                  ),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.delete,
                                    color: Color(0xFFB50303),
                                    size: 16, // 16x16 icon size
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncCard() {
    return BlocBuilder<SyncBloc, SyncState>(
      builder: (context, state) {
        final isSyncing = state.status == SyncStatus.syncing;
        return Container(
          width: 343,
          height: 104,
          padding: const EdgeInsets.only(
            top: 20,
            bottom: 20,
            left: 16,
            right: 16,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1), // #FFFFFF1A
              width: 1,
            ),
          ),
          child: Center(
            child: GestureDetector(
              onTap: isSyncing
                  ? null
                  : () => context.read<SyncBloc>().add(SyncRequested()),
              child: Container(
                width: 311,
                height: 64,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0x8A4340CA), // #4340CA8A
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Sync To Cloud',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w600, // Semi Bold
                              height: 1.5, // 150% line height
                              letterSpacing: 18 * -0.05, // -5% letter spacing
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Sync and update data to the backend',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w400, // Regular
                              height: 20 / 14, // 20px line height
                              letterSpacing: 14 * -0.03, // -3% letter spacing
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (isSyncing)
                      const SizedBox(
                        width: 21.86,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    else
                      Image.asset(
                        'assets/cloud.png',
                        width: 21.86,
                        height: 18,
                        color: Colors.white,
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLogoutButton() {
    return Center(
      child: GestureDetector(
        onTap: _logout,
        child: Container(
          width: 343,
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0x1AFFFFFF), // #FFFFFF1A
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Log Out',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600, // Semi Bold
                  height: 1.5, // 150% line-height
                  letterSpacing: 15 * -0.05, // -5% letter-spacing
                  color: const Color(0xFFFF2929), // #FF2929
                ),
              ),
              const SizedBox(width: 10),
              Image.asset(
                'assets/Power.png',
                width: 24,
                height: 24,
                color: const Color(0xFFFF2929), // #FF2929
              ),
            ],
          ),
        ),
      ),
    );
  }
}
