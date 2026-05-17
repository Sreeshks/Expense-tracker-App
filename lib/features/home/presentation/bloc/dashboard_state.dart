import 'package:equatable/equatable.dart';
import '../../../transactions/data/models/transaction_model.dart';

enum DashboardStatus { initial, loading, loaded, error }

class DashboardState extends Equatable {
  final DashboardStatus status;
  final double totalIncome;
  final double totalExpense;
  final double monthlyDebit;
  final double monthlyLimit;
  final List<TransactionModel> recentTransactions;
  final String? errorMessage;

  const DashboardState({
    this.status = DashboardStatus.initial,
    this.totalIncome = 0,
    this.totalExpense = 0,
    this.monthlyDebit = 0,
    this.monthlyLimit = 10000,
    this.recentTransactions = const [],
    this.errorMessage,
  });

  double get remainingBudget => monthlyLimit - monthlyDebit;
  double get budgetProgress =>
      monthlyLimit > 0 ? (monthlyDebit / monthlyLimit).clamp(0.0, 1.0) : 0;
  int get remainingPercent =>
      monthlyLimit > 0 ? ((remainingBudget / monthlyLimit) * 100).round() : 100;

  DashboardState copyWith({
    DashboardStatus? status,
    double? totalIncome,
    double? totalExpense,
    double? monthlyDebit,
    double? monthlyLimit,
    List<TransactionModel>? recentTransactions,
    String? errorMessage,
  }) {
    return DashboardState(
      status: status ?? this.status,
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpense: totalExpense ?? this.totalExpense,
      monthlyDebit: monthlyDebit ?? this.monthlyDebit,
      monthlyLimit: monthlyLimit ?? this.monthlyLimit,
      recentTransactions: recentTransactions ?? this.recentTransactions,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status, totalIncome, totalExpense, monthlyDebit,
        monthlyLimit, recentTransactions, errorMessage,
      ];
}
