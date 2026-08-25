import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:my_teacher_wallet/core/services/connectivity_service.dart';
import 'package:my_teacher_wallet/data/datasources/local/student_local_datasource.dart';
import 'package:my_teacher_wallet/data/datasources/remote/payment_remote_datasource.dart';
import 'package:my_teacher_wallet/data/datasources/remote/student_remote_datasource.dart';
import 'package:my_teacher_wallet/data/models/student.dart';
import 'package:my_teacher_wallet/domain/entities/student_entity.dart';
import 'package:my_teacher_wallet/domain/repositories/student_repository.dart';

class StudentRepositoryImpl implements StudentRepository {
  final StudentLocalDatasource local;
  final StudentRemoteDatasource remote;
  final PaymentRemoteDatasource paymentRemote; // for cascading delete push
  final SupabaseClient authClient;

  StudentRepositoryImpl({
    required this.local,
    required this.remote,
    required this.paymentRemote,
    required this.authClient,
  });

  String? get _userId => authClient.auth.currentUser?.id;
  final ConnectivityService connectivity = ConnectivityService();

  /// Best-effort: pushes to Supabase if logged in + online, silently no-ops otherwise.
  /// Any failure here is fine — the manual Sync button will reconcile it later.
  Future<void> _tryPush(Student student) async {
    final userId = _userId;
    if (userId == null) return;
    if (!await connectivity.hasInternet()) return;
    try {
      await remote.upsertOne(student, userId);
    } catch (_) {
      // swallow — next manual sync will retry via updatedAt diff
    }
  }

  @override
  Future<void> saveStudent(StudentEntity newStudent) async {
    final model = Student.fromEntity(newStudent);
    await local.insert(model);
    await _tryPush(model);
  }

  @override
  Future<List<StudentEntity>> getAllStudents() async {
    final models = await local.getAllActive();
    final entities = <StudentEntity>[];
    for (final model in models) {
      await model.paymentRecords.load();
      entities.add(model.toEntity());
    }
    return entities;
  }

  @override
  Future<void> updateStudent(StudentEntity student) async {
    if (student.id == null) return;
    final existing = await local.getById(student.id!);
    if (existing == null) return;

    existing.name = student.name;
    existing.grade = student.grade;
    existing.monthlyFee = student.monthlyFee;
    existing.updatedAt = DateTime.now();

    await local.update(existing);
    await _tryPush(existing);
  }

  @override
  Future<void> deleteStudent(int studentId) async {
    final result = await local.softDelete(studentId);
    if (result == null) return;
    final (student, payments) = result;

    final userId = _userId;
    if (userId == null || !await connectivity.hasInternet()) return;

    try {
      await remote.upsertOne(student, userId);
      final pairs = payments.map((p) => MapEntry(p, student.uuid ?? "")).toList();
      await paymentRemote.upsertManyWithStudentUuids(pairs, userId);
    } catch (_) {
      // swallow — manual sync will pick these up via updatedAt diff
    }
  }
}