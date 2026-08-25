import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:my_teacher_wallet/core/services/connectivity_service.dart';
import 'package:my_teacher_wallet/data/datasources/local/payment_local_datasource.dart';
import 'package:my_teacher_wallet/data/datasources/local/student_local_datasource.dart';
import 'package:my_teacher_wallet/data/datasources/remote/payment_remote_datasource.dart';
import 'package:my_teacher_wallet/data/models/payment_record.dart';
import 'package:my_teacher_wallet/domain/entities/payment_record_entity.dart';
import 'package:my_teacher_wallet/domain/repositories/payment_repository.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentLocalDatasource local;
  final PaymentRemoteDatasource remote;
  final StudentLocalDatasource studentLocal;
  final SupabaseClient authClient;

  PaymentRepositoryImpl({
    required this.local,
    required this.remote,
    required this.studentLocal,
    required this.authClient,
  });

  String? get _userId => authClient.auth.currentUser?.id;
  final ConnectivityService connectivity = ConnectivityService();

  Future<void> _tryPush(PaymentRecord record, String? studentUuid) async {
    final userId = _userId;
    if (userId == null || studentUuid == null) return;
    if (!await connectivity.hasInternet()) return;
    try {
      await remote.upsertOne(record, userId, studentUuid);
    } catch (_) {
      // swallow — manual sync reconciles later
    }
  }

  @override
  Future<void> addPaymentRecord(PaymentRecordEntity newRecord, int studentId) async {
    final student = await studentLocal.getById(studentId);
    if (student == null) return;

    final record = PaymentRecord(
      month: newRecord.month,
      isPaid: newRecord.isPaid,
      amountPaid: newRecord.amountPaid,
      isExcluded: newRecord.isExcluded,
    );

    await local.insert(record, student: student);
    await _tryPush(record, student.uuid);
  }

  @override
  Future<List<PaymentRecordEntity>> getAllPayments() async {
    final models = await local.getAllActive();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<PaymentRecordEntity>> getPaymentsByMonth(int year, int month) async {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 1).subtract(const Duration(milliseconds: 1));
    final models = await local.getByMonthRange(start, end);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> updatePayment(PaymentRecordEntity payment) async {
    final existing = await local.getById(payment.id);
    if (existing == null) return;

    existing.isPaid = payment.isPaid;
    existing.amountPaid = payment.amountPaid;
    existing.isExcluded = payment.isExcluded;
    existing.updatedAt = DateTime.now();

    await existing.student.load();
    final studentUuid = existing.student.value?.uuid;

    await local.update(existing);
    if (studentUuid != null) await _tryPush(existing, studentUuid);
  }

  @override
  Future<void> deletePayment(int paymentId) async {
    final record = await local.softDelete(paymentId);
    if (record == null) return;

    await record.student.load();
    final studentUuid = record.student.value?.uuid;
    if (studentUuid != null) await _tryPush(record, studentUuid);
  }

  @override
  Future<void> ensureMonthlyRecords(DateTime month) async {
    final monthStart = DateTime(month.year, month.month, 1);
    final students = await studentLocal.getAllActive();

    for (final student in students) {
      await student.paymentRecords.load();

      final exists = student.paymentRecords.any((p) =>
          !p.isDeleted &&
          p.month.year == monthStart.year &&
          p.month.month == monthStart.month);

      if (!exists) {
        final record = PaymentRecord(month: monthStart);
        await local.insert(record, student: student);
        await _tryPush(record, student.uuid);
      }
    }
  }

  @override
  Future<void> togglePayment(int paymentId, bool isPaid, double monthlyFee) async {
    final record = await local.getById(paymentId);
    if (record == null) return;

    record.isPaid = isPaid;
    record.amountPaid = isPaid ? monthlyFee : 0.0;
    record.updatedAt = DateTime.now();

    await record.student.load();
    final studentUuid = record.student.value?.uuid;

    await local.update(record);
    if (studentUuid != null) await _tryPush(record, studentUuid);
  }

  @override
  Future<void> toggleExcluded(int paymentId, bool isExcluded) async {
    final record = await local.getById(paymentId);
    if (record == null) return;

    record.isExcluded = isExcluded;
    if (isExcluded) {
      record.isPaid = false;
      record.amountPaid = 0.0;
    }
    record.updatedAt = DateTime.now();

    await record.student.load();
    final studentUuid = record.student.value?.uuid;

    await local.update(record);
    if (studentUuid != null) await _tryPush(record, studentUuid);
  }
}