import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/services/notification_service.dart';
import '../../data/repositories/transaction_repository.dart';
import 'transaction_event.dart';
import 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final TransactionRepository _repo;

  TransactionBloc({TransactionRepository? repo})
      : _repo = repo ?? TransactionRepository(),
        super(const TransactionState()) {
    on<TransactionsLoadRequested>(_onLoad);
    on<TransactionAdded>(_onAdd);
    on<TransactionDeleted>(_onDelete);
    on<TransactionsReset>((event, emit) => emit(const TransactionState()));
  }

  Future<void> _onLoad(
    TransactionsLoadRequested event,
    Emitter<TransactionState> emit,
  ) async {
    emit(state.copyWith(status: TransactionStatus.loading));
    try {
      final txns = await _repo.getAll();
      emit(state.copyWith(
        status: TransactionStatus.loaded,
        transactions: txns,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: TransactionStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onAdd(
    TransactionAdded event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      await _repo.add(
        amount: event.amount,
        note: event.note,
        type: event.type,
        categoryId: event.categoryId,
      );

      if (event.type.toLowerCase() == 'debit') {
        final monthlyTotal = await _repo.getMonthlyDebit();
        final prefs = await SharedPreferences.getInstance();
        final limit = prefs.getDouble('monthly_limit') ?? 10000.0;
        if (monthlyTotal > limit) {
          await NotificationService.instance.showBudgetAlert(
            currentTotal: monthlyTotal,
            threshold: limit,
          );
        }
      }

      final txns = await _repo.getAll();
      emit(state.copyWith(
        status: TransactionStatus.loaded,
        transactions: txns,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: TransactionStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onDelete(
    TransactionDeleted event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      await _repo.softDelete(event.id);
      final txns = await _repo.getAll();
      emit(state.copyWith(
        status: TransactionStatus.loaded,
        transactions: txns,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: TransactionStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
}
