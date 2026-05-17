import 'package:equatable/equatable.dart';

class TransactionModel extends Equatable {
  final String id;
  final double amount;
  final String note;
  final String type;
  final String categoryId;
  final String? categoryName;
  final DateTime timestamp;
  final int isSynced;
  final int isDeleted;

  const TransactionModel({
    required this.id,
    required this.amount,
    required this.note,
    required this.type,
    required this.categoryId,
    this.categoryName,
    required this.timestamp,
    this.isSynced = 0,
    this.isDeleted = 0,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'amount': amount,
        'note': note,
        'type': type,
        'category_id': categoryId,
        'timestamp': timestamp.toIso8601String(),
        'is_synced': isSynced,
        'is_deleted': isDeleted,
      };

  factory TransactionModel.fromMap(Map<String, dynamic> map) =>
      TransactionModel(
        id: map['id'] as String,
        amount: (map['amount'] as num).toDouble(),
        note: map['note'] as String? ?? '',
        type: map['type'] as String,
        categoryId: map['category_id'] as String,
        categoryName: map['category_name'] as String?,
        timestamp: DateTime.parse(map['timestamp'] as String),
        isSynced: map['is_synced'] as int? ?? 0,
        isDeleted: map['is_deleted'] as int? ?? 0,
      );

  Map<String, dynamic> toApiJson() {
    final y = timestamp.year.toString().padLeft(4, '0');
    final m = timestamp.month.toString().padLeft(2, '0');
    final d = timestamp.day.toString().padLeft(2, '0');
    final hh = timestamp.hour.toString().padLeft(2, '0');
    final mm = timestamp.minute.toString().padLeft(2, '0');
    final ss = timestamp.second.toString().padLeft(2, '0');
    return {
      'id': id,
      'amount': amount,
      'note': note,
      'type': type.toLowerCase(),
      'category_id': categoryId,
      'timestamp': '$y-$m-$d $hh:$mm:$ss',
    };
  }

  bool get isDebit => type.toLowerCase() == 'debit';
  bool get isCredit => type.toLowerCase() == 'credit';

  @override
  List<Object?> get props => [
        id, amount, note, type, categoryId, categoryName,
        timestamp, isSynced, isDeleted,
      ];
}
