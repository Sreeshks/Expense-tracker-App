import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/sync_repository.dart';
import 'sync_event.dart';
import 'sync_state.dart';

class SyncBloc extends Bloc<SyncEvent, SyncState> {
  final SyncRepository _repo;

  SyncBloc({SyncRepository? repo})
      : _repo = repo ?? SyncRepository(),
        super(const SyncState()) {
    on<SyncRequested>(_onSync);
  }

  Future<void> _onSync(
    SyncRequested event,
    Emitter<SyncState> emit,
  ) async {
    emit(state.copyWith(status: SyncStatus.syncing));
    try {
      await _repo.syncAll();
      emit(state.copyWith(status: SyncStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: SyncStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}
