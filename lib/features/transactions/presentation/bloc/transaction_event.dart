import 'package:equatable/equatable.dart';

abstract class TransactionEvent extends Equatable {
  const TransactionEvent();
  @override
  List<Object?> get props => [];
}

class TransactionsLoadRequested extends TransactionEvent {}

class TransactionAdded extends TransactionEvent {
  final double amount;
  final String note;
  final String type;
  final String categoryId;

  const TransactionAdded({
    required this.amount,
    required this.note,
    required this.type,
    required this.categoryId,
  });

  @override
  List<Object?> get props => [amount, note, type, categoryId];
}

class TransactionDeleted extends TransactionEvent {
  final String id;
  const TransactionDeleted(this.id);
  @override
  List<Object?> get props => [id];
}

class TransactionsReset extends TransactionEvent {}
