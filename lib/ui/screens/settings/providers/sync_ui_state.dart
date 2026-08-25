enum SyncStatus { idle, syncing, success, error, offline }

class SyncUiState {
  final SyncStatus status;
  final String? message;
  final DateTime? lastSyncedAt;

  const SyncUiState({this.status = SyncStatus.idle, this.message, this.lastSyncedAt});

  SyncUiState copyWith({SyncStatus? status, String? message, DateTime? lastSyncedAt}) {
    return SyncUiState(
      status: status ?? this.status,
      message: message,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }
}