import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../transactions/data/repositories/transaction_repository.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final TransactionRepository _transactionRepo;

  DashboardBloc({TransactionRepository? transactionRepo})
      : _transactionRepo = transactionRepo ?? TransactionRepository(),
        super(const DashboardState()) {
    on<DashboardLoadRequested>(_onLoad);
    on<DashboardRefreshRequested>(_onLoad);
    on<DashboardReset>((event, emit) => emit(const DashboardState()));
  }

  Future<void> _onLoad(
    DashboardEvent event,
    Emitter<DashboardState> emit,
  ) async {
    emit(state.copyWith(status: DashboardStatus.loading));
    try {
      final income = await _transactionRepo.getTotalByType('credit');
      final expense = await _transactionRepo.getTotalByType('debit');
      final monthlyDebit = await _transactionRepo.getMonthlyDebit();
      final recent = await _transactionRepo.getRecent(limit: 10);

      final prefs = await SharedPreferences.getInstance();
      final limit = prefs.getDouble('monthly_limit') ?? 10000.0;

      emit(state.copyWith(
        status: DashboardStatus.loaded,
        totalIncome: income,
        totalExpense: expense,
        monthlyDebit: monthlyDebit,
        monthlyLimit: limit,
        recentTransactions: recent,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: DashboardStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
}
