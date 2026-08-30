import 'package:my_teacher_wallet/core/constant/network_constants.dart';
import 'package:my_teacher_wallet/data/datasources/remote/student_remote_datasource.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:my_teacher_wallet/data/models/student.dart';

class StudentRemoteDatasourceImpl extends StudentRemoteDatasource {
  final SupabaseClient client;
  StudentRemoteDatasourceImpl(this.client);

  Map<String, dynamic> _toRow(Student s, String userId) => {
    'id': s.uuid,
    'user_id': userId,
    'name': s.name,
    'grade': s.grade,
    'monthly_fee': s.monthlyFee,
    'updated_at': s.updatedAt?.toUtc().toIso8601String(),
    'is_deleted': s.isDeleted,
  };

  @override
  Future<void> upsertOne(Student student, String userId) async {
    await client
        .from('students')
        .upsert(_toRow(student, userId), onConflict: 'id')
        .timeout(NetworkConstants.requestTimeout);
  }

  @override
  Future<void> upsertMany(List<Student> students, String userId) async {
    if (students.isEmpty) return;
    final rows = students.map((s) => _toRow(s, userId)).toList();
    await client
        .from('students')
        .upsert(rows, onConflict: 'id')
        .timeout(NetworkConstants.requestTimeout);
  }

  @override
  Future<List<Map<String, dynamic>>> fetchAll(
    String userId, {
    DateTime? since,
  }) async {
    var query = client.from('students').select().eq('user_id', userId);
    if (since != null) {
      query = query.gt('updated_at', since.toUtc().toIso8601String());
    }
    return await query.timeout(NetworkConstants.requestTimeout);
  }

  @override
  Future<void> deleteAllForUser(String userId) async {
    await client
        .from('students')
        .delete()
        .eq('user_id', userId)
        .timeout(NetworkConstants.requestTimeout);
  }
}
