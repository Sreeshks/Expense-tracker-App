import 'package:equatable/equatable.dart';

enum SyncStatus { initial, syncing, success, failure }

class SyncState extends Equatable {
  final SyncStatus status;
  final String? errorMessage;

  const SyncState({this.status = SyncStatus.initial, this.errorMessage});

  SyncState copyWith({SyncStatus? status, String? errorMessage}) {
    return SyncState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage];
}
