import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_teacher_wallet/core/services/sync_service.dart';
import 'package:my_teacher_wallet/data/datasources/local_datasource_provider.dart';
import 'package:my_teacher_wallet/data/datasources/remote_datasource_provider.dart';
import 'package:my_teacher_wallet/ui/screens/payment_check/providers/payment_notifier_provider.dart';
import 'package:my_teacher_wallet/ui/screens/settings/providers/sync_ui_state.dart';
import 'package:my_teacher_wallet/ui/screens/student/providers/student_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService(
    studentLocal: ref.watch(studentLocalDSProvider),
    paymentLocal: ref.watch(paymentLocalDSProvider),
    studentRemote: ref.watch(studentRemoteDSProvider),
    paymentRemote: ref.watch(paymentRemoteDSProvider),
    authClient: Supabase.instance.client,
  );
});

class SyncNotifier extends Notifier<SyncUiState> {
  @override
  SyncUiState build() => const SyncUiState();

  Future<void> syncNow() async {
    state = state.copyWith(status: SyncStatus.syncing);
    final result = await ref.read(syncServiceProvider).sync();

    if (result.success) {
      debugPrint("${result.pushed} sent, ${result.pulled} received");
      state = SyncUiState(
        status: SyncStatus.success,
        lastSyncedAt: result.syncedAt,
        message: 'Synced successfully',
      );
      ref.invalidate(studentProvider);
      ref.invalidate(paymentProvider);
    } else {
      state = state.copyWith(
        status: result.errorMessage == 'No internet connection.'
            ? SyncStatus.offline
            : SyncStatus.error,
        message: result.errorMessage,
      );
      debugPrint("Error: ${result.errorMessage}");
    }
  }
}

final syncProvider = NotifierProvider<SyncNotifier, SyncUiState>(() {
  return SyncNotifier();
});