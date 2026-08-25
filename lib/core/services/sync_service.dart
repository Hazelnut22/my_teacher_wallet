import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:my_teacher_wallet/core/services/connectivity_service.dart';
import 'package:my_teacher_wallet/core/services/shared_preference_service.dart';
import 'package:my_teacher_wallet/data/datasources/local/payment_local_datasource.dart';
import 'package:my_teacher_wallet/data/datasources/local/student_local_datasource.dart';
import 'package:my_teacher_wallet/data/datasources/remote/payment_remote_datasource.dart';
import 'package:my_teacher_wallet/data/datasources/remote/student_remote_datasource.dart';
import 'package:my_teacher_wallet/data/models/payment_record.dart';
import 'package:my_teacher_wallet/data/models/student.dart';

class SyncResult {
  final bool success;
  final String? errorMessage;
  final int pushed;
  final int pulled;
  final DateTime? syncedAt;

  const SyncResult({
    required this.success,
    this.errorMessage,
    this.pushed = 0,
    this.pulled = 0,
    this.syncedAt,
  });

  factory SyncResult.offline() =>
      const SyncResult(success: false, errorMessage: 'No internet connection.');
  factory SyncResult.notAuthenticated() =>
      const SyncResult(success: false, errorMessage: 'You must be signed in to sync.');
  factory SyncResult.error(String message) =>
      SyncResult(success: false, errorMessage: message);
}

class SyncService {
  final StudentLocalDatasource studentLocal;
  final PaymentLocalDatasource paymentLocal;
  final StudentRemoteDatasource studentRemote;
  final PaymentRemoteDatasource paymentRemote;
  final SupabaseClient authClient;

  SyncService({
    required this.studentLocal,
    required this.paymentLocal,
    required this.studentRemote,
    required this.paymentRemote,
    required this.authClient,
  });

  Future<SyncResult> sync() async {
    if (!await ConnectivityService().hasInternet()) return SyncResult.offline();

    final userId = authClient.auth.currentUser?.id;
    if (userId == null) return SyncResult.notAuthenticated();

    try {
      final since = await SharedPreferenceService.getLastSyncedAt();

      final pushedS = await _pushStudents(userId, since);
      final pushedP = await _pushPayments(userId, since);
      final pulledS = await _pullStudents(userId, since);
      final pulledP = await _pullPayments(userId, since);

      final now = DateTime.now().toUtc();
      await SharedPreferenceService.setLastSyncedAt(now);

      return SyncResult(
        success: true,
        pushed: pushedS + pushedP,
        pulled: pulledS + pulledP,
        syncedAt: now,
      );
    } catch (e) {
      return SyncResult.error(e.toString());
    }
  }

  // ── Push ──────────────────────────────────────────────────────────────

  Future<int> _pushStudents(String userId, DateTime? since) async {
    final students = await studentLocal.getUpdatedSince(since);
    if (students.isEmpty) return 0;
    await studentRemote.upsertMany(students, userId);
    return students.length;
  }

  Future<int> _pushPayments(String userId, DateTime? since) async {
    final payments = await paymentLocal.getUpdatedSince(since);
    if (payments.isEmpty) return 0;

    final pairs = <MapEntry<PaymentRecord, String>>[];
    for (final p in payments) {
      await p.student.load();
      final studentUuid = p.student.value?.uuid;
      if (studentUuid != null) pairs.add(MapEntry(p, studentUuid));
    }
    if (pairs.isEmpty) return 0;

    await paymentRemote.upsertManyWithStudentUuids(pairs, userId);
    return pairs.length;
  }

  // ── Pull ──────────────────────────────────────────────────────────────

  Future<int> _pullStudents(String userId, DateTime? since) async {
    final rows = await studentRemote.fetchAll(userId, since: since);
    var count = 0;

    for (final row in rows) {
      await studentLocal.upsertFromRemote(Student(
        name: row['name'] as String,
        grade: row['grade'] as String,
        monthlyFee: (row['monthly_fee'] as num).toDouble(),
        uuid: row['id'] as String,
        updatedAt: DateTime.parse(row['updated_at'] as String),
        isDeleted: row['is_deleted'] as bool,
      ));
      count++;
    }
    return count;
  }

  Future<int> _pullPayments(String userId, DateTime? since) async {
    final rows = await paymentRemote.fetchAll(userId, since: since);
    var count = 0;

    for (final row in rows) {
      final studentUuid = row['student_id'] as String;
      final parent = await studentLocal.getByUuid(studentUuid);
      if (parent == null) continue; // parent not synced yet — will catch up next run

      await paymentLocal.upsertFromRemote(
        PaymentRecord(
          month: DateTime.parse(row['month'] as String),
          isPaid: row['is_paid'] as bool,
          amountPaid: (row['amount_paid'] as num).toDouble(),
          isExcluded: row['is_excluded'] as bool,
          uuid: row['id'] as String,
          updatedAt: DateTime.parse(row['updated_at'] as String),
          isDeleted: row['is_deleted'] as bool,
        ),
        parent: parent,
      );
      count++;
    }
    return count;
  }
}