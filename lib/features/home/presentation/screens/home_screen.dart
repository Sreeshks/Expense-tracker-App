import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../transactions/data/models/transaction_model.dart';
import '../../../transactions/presentation/bloc/transaction_bloc.dart';
import '../../../transactions/presentation/bloc/transaction_event.dart';
import '../../../transactions/presentation/widgets/add_transaction_sheet.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _nickname = 'User';
  bool _isScrolling = false;

  @override
  void initState() {
    super.initState();
    _loadNickname();
    context.read<DashboardBloc>().add(DashboardLoadRequested());
  }

  Future<void> _loadNickname() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nickname = prefs.getString(ApiConstants.nicknameKey) ?? 'User';
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: NotificationListener<UserScrollNotification>(
              onNotification: (notification) {
                if (notification.direction == ScrollDirection.idle) {
                  if (_isScrolling) {
                    setState(() {
                      _isScrolling = false;
                    });
                  }
                } else {
                  if (!_isScrolling) {
                    setState(() {
                      _isScrolling = true;
                    });
                  }
                }
                return false;
              },
              child: RefreshIndicator(
                color: const Color(0xFF1DB954),
                backgroundColor: AppColors.surface,
                onRefresh: () async {
                  context.read<DashboardBloc>().add(DashboardRefreshRequested());
                },
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    const SizedBox(height: 20),
                    _buildGreeting(),
                    const SizedBox(height: 20),
                    _buildSummaryCards(state),
                    const SizedBox(height: 20),
                    _buildMonthlyLimit(state),
                    const SizedBox(height: 24),
                    _buildRecentHeader(),
                    const SizedBox(height: 12),
                    if (state.status == DashboardStatus.loading)
                      _buildShimmer()
                    else
                      _buildRecentList(state.recentTransactions),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ),
          floatingActionButton: AnimatedScale(
            scale: _isScrolling ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: Container(
              margin: const EdgeInsets.only(
                bottom: 70,
              ), // Lift it up slightly above floating bottom bar
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF20DE39), Color(0xFF147721)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _showAddTransaction(context),
                  borderRadius: BorderRadius.circular(100),
                  child: const Center(
                    child: Icon(Icons.add, color: Colors.white, size: 24),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGreeting() {
    return Center(
      child: SizedBox(
        width: 343,
        child: Text(
          '👋 Welcome, $_nickname!',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600, // Semi Bold
            height: 1.5, // 150% line-height
            letterSpacing: 20 * -0.05, // -5% letter-spacing
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCards(DashboardState state) {
    return Center(
      child: SizedBox(
        width: 343,
        child: Row(
          children: [
            Expanded(
              child: _summaryCard(
                label: 'Total Income',
                amount: state.totalIncome,
                icon: Icons.arrow_downward,
                gradientStart: const Color(0xFF0F8300),
                gradientEnd: const Color(0xFF031C00),
                borderColor: const Color(0xFF0F8300),
                labelColor: const Color(0xFF1DB954),
              ),
            ),
            const SizedBox(width: 8), // gap: 8px
            Expanded(
              child: _summaryCard(
                label: 'Total Expense',
                amount: state.totalExpense,
                icon: Icons.arrow_upward,
                gradientStart: const Color(0xFFB50303),
                gradientEnd: const Color(0xFF250000),
                borderColor: const Color(0xFFB50303),
                labelColor: const Color(0xFFFF4444),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryCard({
    required String label,
    required double amount,
    required IconData icon,
    required Color gradientStart,
    required Color gradientEnd,
    required Color borderColor,
    required Color labelColor,
  }) {
    return Container(
      height: 87,
      padding: const EdgeInsets.only(top: 10, bottom: 10, left: 12, right: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [gradientStart, gradientEnd],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w400, // Regular
              color: Colors.white,
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '₹${NumberFormat('#,##,###').format(amount.round())}',
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w600, // Semi Bold
                    height: 1.5, // 150% line-height
                    letterSpacing: 24 * -0.05, // -5% letter-spacing
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyLimit(DashboardState state) {
    return Center(
      child: SizedBox(
        width: 343,
        height: 128,
        child: Container(
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
              color: Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'MONTHLY LIMIT',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.5),
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${NumberFormat('#,##,###').format(state.monthlyDebit.round())} / '
                    '₹${NumberFormat('#,##,###').format(state.monthlyLimit.round())}',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: state.budgetProgress,
                      backgroundColor: Colors.white.withValues(alpha: 0.1),
                      color: state.budgetProgress > 0.8
                          ? const Color(0xFFFF4444)
                          : const Color(0xFF1DB954),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${state.remainingPercent}% Remaining',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentHeader() {
    return Center(
      child: SizedBox(
        width: 343,
        child: Text(
          'Recent Transactions',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500, // Medium
            height: 1.5, // 150% line-height
            letterSpacing: 16 * -0.05, // -5% letter-spacing
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    return Column(
      children: List.generate(
        5,
        (i) => Container(
          height: 64,
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: AppColors.shimmer,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentList(List<TransactionModel> transactions) {
    if (transactions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Text(
            'No transactions yet.\nTap + to add one.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.4),
            ),
          ),
        ),
      );
    }

    return Column(
      children: transactions.map((txn) => _transactionTile(txn)).toList(),
    );
  }

  IconData _getCategoryIcon(String? categoryName) {
    final name = (categoryName ?? '').toLowerCase();
    if (name.contains('food') || name.contains('grocer')) {
      return Icons.shopping_bag_outlined;
    }
    if (name.contains('bill')) {
      return Icons.bolt_outlined;
    }
    if (name.contains('transport')) {
      return Icons.directions_car_outlined;
    }
    if (name.contains('shop')) {
      return Icons.storefront_outlined;
    }
    if (name.contains('fruit')) {
      return Icons.eco_outlined;
    }
    if (name.contains('water')) {
      return Icons.water_drop_outlined;
    }
    if (name.contains('rent')) {
      return Icons.home_outlined;
    }
    if (name.contains('health')) {
      return Icons.favorite_outline;
    }
    return Icons.receipt_outlined;
  }

  String _formatOrdinalDate(DateTime date) {
    final day = date.day;
    String suffix = 'th';
    if (day >= 11 && day <= 13) {
      suffix = 'th';
    } else {
      switch (day % 10) {
        case 1:
          suffix = 'st';
          break;
        case 2:
          suffix = 'nd';
          break;
        case 3:
          suffix = 'rd';
          break;
        default:
          suffix = 'th';
      }
    }
    final monthStr = DateFormat('MMM').format(date);
    final yearStr = DateFormat('yyyy').format(date);
    return '$day$suffix $monthStr $yearStr';
  }

  Widget _transactionTile(TransactionModel txn) {
    final isDebit = txn.isDebit;
    final color = isDebit ? const Color(0xFFFF4444) : const Color(0xFF1DB954);
    final prefix = isDebit ? '-' : '+';
    final dateStr = _formatOrdinalDate(txn.timestamp);

    return Center(
      child: Container(
        width: 343,
        height: 72,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.only(top: 8, bottom: 8, left: 16, right: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left part: Icon and Text Details
            Expanded(
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Icon(
                        _getCategoryIcon(txn.categoryName),
                        color: Colors.white,
                        size: 16, // icon size 16x16
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          txn.note.isEmpty ? 'Transaction' : txn.note,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600, // Semi Bold
                            height: 1.5, // 150% line-height
                            letterSpacing: 16 * -0.05, // -5% letter-spacing
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          txn.categoryName ?? 'Uncategorized',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w400, // Regular
                            height: 1.5, // 150% line-height
                            letterSpacing: 14 * -0.05, // -5% letter-spacing
                            color: const Color(0xFF8C8C8C), // #8C8C8C
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Right part: Date, Amount, and Delete icon
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      dateStr,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w400, // Regular
                        height: 1.5, // 150% line-height
                        letterSpacing: 13 * -0.05, // -5% letter-spacing
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                    Text(
                      '$prefix₹${NumberFormat('#,##,###').format(txn.amount.round())}',
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.w500, // Medium
                        height: 1.5, // 150% line-height
                        letterSpacing: 22 * -0.05, // -5% letter-spacing
                        color: color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {
                    context.read<TransactionBloc>().add(
                      TransactionDeleted(txn.id),
                    );
                    context.read<DashboardBloc>().add(
                      DashboardRefreshRequested(),
                    );
                  },
                  child: const Icon(
                    Icons.delete,
                    color: Color(0xFFE50000), // #E50000
                    size: 20,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddTransaction(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const AddTransactionSheet(),
    );
  }
}
