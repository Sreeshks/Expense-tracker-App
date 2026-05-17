import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/transaction_model.dart';
import '../../../home/presentation/bloc/dashboard_bloc.dart';
import '../../../home/presentation/bloc/dashboard_event.dart';
import '../bloc/transaction_bloc.dart';
import '../bloc/transaction_event.dart';
import '../bloc/transaction_state.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<TransactionBloc>().add(TransactionsLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 20,
                    bottom: 16,
                  ),
                  child: Text(
                    'Transactions',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                Expanded(
                  child: state.status == TransactionStatus.loading
                      ? _buildShimmer()
                      : state.transactions.isEmpty
                      ? _buildEmpty()
                      : _buildList(state.transactions),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: 8,
      itemBuilder: (_, i) => Container(
        height: 64,
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppColors.shimmer,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 48,
            color: Colors.white.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 12),
          Text(
            'No transactions yet.',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<TransactionModel> transactions) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: transactions.length,
      itemBuilder: (context, index) => _transactionTile(transactions[index]),
    );
  }

  IconData _getCategoryIcon(String? categoryName) {
    final name = (categoryName ?? '').toLowerCase();
    if (name.contains('food') || name.contains('grocer'))
      return Icons.shopping_bag_outlined;
    if (name.contains('bill')) return Icons.bolt_outlined;
    if (name.contains('transport')) return Icons.directions_car_outlined;
    if (name.contains('shop')) return Icons.storefront_outlined;
    if (name.contains('fruit')) return Icons.eco_outlined;
    if (name.contains('water')) return Icons.water_drop_outlined;
    if (name.contains('rent')) return Icons.home_outlined;
    if (name.contains('health')) return Icons.favorite_outline;
    return Icons.receipt_outlined;
  }

  Widget _transactionTile(TransactionModel txn) {
    final isDebit = txn.isDebit;
    final color = isDebit ? const Color(0xFFFF4444) : const Color(0xFF1DB954);
    final prefix = isDebit ? '-' : '+';
    final dateStr = DateFormat('d\'th\' MMM yyyy').format(txn.timestamp);

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Category icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _getCategoryIcon(txn.categoryName),
              color: Colors.white.withValues(alpha: 0.7),
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          // Title + category
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  txn.categoryName ?? 'Uncategorized',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
          ),
          // Date
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Text(
              dateStr,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: Colors.white.withValues(alpha: 0.35),
              ),
            ),
          ),
          // Amount
          Text(
            '$prefix₹${NumberFormat('#,##,###').format(txn.amount.round())}',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(width: 8),
          // Delete button
          GestureDetector(
            onTap: () {
              context.read<TransactionBloc>().add(TransactionDeleted(txn.id));
              context.read<DashboardBloc>().add(DashboardRefreshRequested());
            },
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: const Color(0xFFFF4444).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(5),
              ),
              child: const Icon(
                Icons.delete_outline,
                color: Color(0xFFFF4444),
                size: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
