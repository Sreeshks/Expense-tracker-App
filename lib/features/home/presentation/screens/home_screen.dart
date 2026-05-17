import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../transactions/data/models/transaction_model.dart';
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
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddTransaction(context),
            backgroundColor: const Color(0xFF1DB954),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        );
      },
    );
  }

  Widget _buildGreeting() {
    return Text(
      '👋 Welcome, $_nickname!',
      style: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    );
  }

  Widget _buildSummaryCards(DashboardState state) {
    return Row(
      children: [
        Expanded(
          child: _summaryCard(
            'Total Income',
            state.totalIncome,
            const Color(0xFF1DB954),
            Icons.arrow_downward,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _summaryCard(
            'Total Expense',
            state.totalExpense,
            const Color(0xFFFF4444),
            Icons.arrow_upward,
          ),
        ),
      ],
    );
  }

  Widget _summaryCard(String label, double amount, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  '₹${NumberFormat('#,##,###').format(amount.round())}',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
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
          const SizedBox(height: 8),
          Text(
            '₹${NumberFormat('#,##,###').format(state.monthlyDebit.round())} / '
            '₹${NumberFormat('#,##,###').format(state.monthlyLimit.round())}',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
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
    );
  }

  Widget _buildRecentHeader() {
    return Text(
      'Recent Transactions',
      style: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.white.withValues(alpha: 0.7),
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

  Widget _transactionTile(TransactionModel txn) {
    final isDebit = txn.isDebit;
    final color = isDebit ? const Color(0xFFFF4444) : const Color(0xFF1DB954);
    final prefix = isDebit ? '-' : '+';
    final dateStr = DateFormat('d MMM yyyy').format(txn.timestamp);

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            isDebit ? Icons.arrow_upward : Icons.arrow_downward,
            color: color,
            size: 18,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  txn.note.isEmpty ? 'Transaction' : txn.note,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  txn.categoryName ?? 'Uncategorized',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                dateStr,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.4),
                ),
              ),
              Text(
                '$prefix₹${NumberFormat('#,##,###').format(txn.amount.round())}',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ],
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
