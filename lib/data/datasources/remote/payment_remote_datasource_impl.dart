import 'package:my_teacher_wallet/core/constant/network_constants.dart';
import 'package:my_teacher_wallet/data/datasources/remote/payment_remote_datasource.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:my_teacher_wallet/data/models/payment_record.dart';

class PaymentRemoteDatasourceImpl extends PaymentRemoteDatasource {
  final SupabaseClient client;
  PaymentRemoteDatasourceImpl(this.client);

  Map<String, dynamic>? _toRow(
    PaymentRecord p,
    String userId,
    String studentUuid,
  ) => {
    'id': p.uuid,
    'student_id': studentUuid,
    'user_id': userId,
    'month': p.month.toUtc().toIso8601String(),
    'is_paid': p.isPaid,
    'amount_paid': p.amountPaid,
    'is_excluded': p.isExcluded,
    'updated_at': p.updatedAt?.toUtc().toIso8601String(),
    'is_deleted': p.isDeleted,
  };

  @override
  Future<void> upsertOne(
    PaymentRecord record,
    String userId,
    String studentUuid,
  ) async {
    final row = _toRow(record, userId, studentUuid);
    if (row == null) return;
    await client
        .from('payment_records')
        .upsert(row, onConflict: 'id')
        .timeout(NetworkConstants.requestTimeout);
  }

  @override
  Future<void> upsertManyWithStudentUuids(
    List<MapEntry<PaymentRecord, String>> recordsWithStudentUuid,
    String userId,
  ) async {
    if (recordsWithStudentUuid.isEmpty) return;
    final rows = recordsWithStudentUuid
        .map((e) => _toRow(e.key, userId, e.value))
        .whereType<Map<String, dynamic>>()
        .toList();
    if (rows.isEmpty) return;
    await client
        .from('payment_records')
        .upsert(rows, onConflict: 'id')
        .timeout(NetworkConstants.requestTimeout);
  }

  @override
  Future<List<Map<String, dynamic>>> fetchAll(
    String userId, {
    DateTime? since,
  }) async {
    var query = client.from('payment_records').select().eq('user_id', userId);
    if (since != null) {
      query = query.gt('updated_at', since.toUtc().toIso8601String());
    }
    return await query.timeout(NetworkConstants.requestTimeout);
  }

  @override
  Future<void> deleteAllForUser(String userId) async {
    await client
        .from('payment_records')
        .delete()
        .eq('user_id', userId)
        .timeout(NetworkConstants.requestTimeout);
  }
}
