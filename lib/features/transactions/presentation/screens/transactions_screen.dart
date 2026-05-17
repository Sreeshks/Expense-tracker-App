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
                      fontSize: 20,
                      fontWeight: FontWeight.w600, // Semi Bold
                      height: 1.5, // 150% line-height
                      letterSpacing: 20 * -0.05, // -5% letter-spacing
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
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 120),
      itemCount: transactions.length,
      itemBuilder: (context, index) => _transactionTile(transactions[index]),
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
}
