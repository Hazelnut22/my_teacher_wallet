import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:my_teacher_wallet/data/database_provider.dart';
import 'package:my_teacher_wallet/data/models/payment_record.dart';
import 'package:my_teacher_wallet/data/models/student.dart';
import 'package:my_teacher_wallet/domain/entities/student_entity.dart';

/// Holds the current month's payment state for all students.
/// Map key = studentId, value = PaymentRecord model
class PaymentNotifier extends AsyncNotifier<List<StudentEntity>> {
  late Isar _isar;

  @override
  Future<List<StudentEntity>> build() async {
    _isar = ref.watch(dbProvider);
    return _loadStudentsWithCurrentMonth();
  }

  Future<List<StudentEntity>> _loadStudentsWithCurrentMonth() async {
    final now = DateTime.now();
    final students = await _isar.students.where().findAll();

    for (final student in students) {
      await student.paymentRecords.load();
      await _ensureCurrentMonthRecord(student, now);
    }

    // Reload after potential writes
    final refreshed = await _isar.students.where().findAll();
    final result = <StudentEntity>[];

    for (final student in refreshed) {
      await student.paymentRecords.load();
      result.add(_toEntityWithCurrentMonth(student, now));
    }

    return result;
  }

  /// Creates a PaymentRecord for the current month if one doesn't exist
  Future<void> _ensureCurrentMonthRecord(Student student, DateTime now) async {
    final currentMonthStart = DateTime(now.year, now.month, 1);

    final existing = student.paymentRecords.where((p) =>
        p.month.year == currentMonthStart.year &&
        p.month.month == currentMonthStart.month);

    if (existing.isEmpty) {
      final record = PaymentRecord(
        month: currentMonthStart,
        isPaid: false,
        amountPaid: 0.0,
      );
      await _isar.writeTxn(() async {
        await _isar.paymentRecords.put(record);
        student.paymentRecords.add(record);
        await student.paymentRecords.save();
      });
    }
  }

  /// Converts Student model to entity but only exposes current month payment
  StudentEntity _toEntityWithCurrentMonth(Student student, DateTime now) {
    final currentMonthPayment = student.paymentRecords.where((p) =>
        p.month.year == now.year && p.month.month == now.month);

    return StudentEntity(
      id: student.id,
      name: student.name,
      grade: student.grade,
      monthlyFee: student.monthlyFee,
      payments: currentMonthPayment.map((p) => p.toEntity()).toList(),
    );
  }

  /// Toggle paid/unpaid for the current month
  Future<void> togglePayment(int studentId, bool isPaid) async {
    final now = DateTime.now();
    final student = await _isar.students.get(studentId);
    if (student == null) return;

    await student.paymentRecords.load();

    final record = student.paymentRecords.firstWhere(
      (p) => p.month.year == now.year && p.month.month == now.month,
    );

    await _isar.writeTxn(() async {
      record.isPaid = isPaid;
      record.amountPaid = isPaid ? student.monthlyFee : 0.0;
      await _isar.paymentRecords.put(record);
    });

    state = AsyncData(await _loadStudentsWithCurrentMonth());
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(await _loadStudentsWithCurrentMonth());
  }
}

final paymentProvider =
    AsyncNotifierProvider<PaymentNotifier, List<StudentEntity>>(() {
  return PaymentNotifier();
});