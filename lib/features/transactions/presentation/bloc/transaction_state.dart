import 'package:equatable/equatable.dart';
import '../../data/models/transaction_model.dart';

enum TransactionStatus { initial, loading, loaded, error }

class TransactionState extends Equatable {
  final TransactionStatus status;
  final List<TransactionModel> transactions;
  final String? errorMessage;

  const TransactionState({
    this.status = TransactionStatus.initial,
    this.transactions = const [],
    this.errorMessage,
  });

  TransactionState copyWith({
    TransactionStatus? status,
    List<TransactionModel>? transactions,
    String? errorMessage,
  }) {
    return TransactionState(
      status: status ?? this.status,
      transactions: transactions ?? this.transactions,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, transactions, errorMessage];
}
