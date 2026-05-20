import 'package:isar/isar.dart';
import 'package:my_teacher_wallet/data/models/payment_record.dart';
import 'package:my_teacher_wallet/data/models/student.dart';
import 'package:my_teacher_wallet/domain/entities/payment_record_entity.dart';
import 'package:my_teacher_wallet/domain/repositories/payment_repository.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final Isar isar;
 
  PaymentRepositoryImpl(this.isar);
 
  @override
  Future<void> addPaymentRecord(
      PaymentRecordEntity newRecord, int studentId) async {
    final student = await isar.students.get(studentId);
    if (student == null) return;
 
    final record = PaymentRecord(
      month: newRecord.month,
      isPaid: newRecord.isPaid,
      amountPaid: newRecord.amountPaid,
      isExcluded: newRecord.isExcluded,
    );
 
    await isar.writeTxn(() async {
      await isar.paymentRecords.put(record);
      student.paymentRecords.add(record);
      await student.paymentRecords.save();
    });
  }
 
  @override
  Future<List<PaymentRecordEntity>> getAllPayments() async {
    final models = await isar.paymentRecords.where().findAll();
    return models.map((m) => m.toEntity()).toList();
  }
 
  @override
  Future<List<PaymentRecordEntity>> getPaymentsByMonth(
      int year, int month) async {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 1)
        .subtract(const Duration(milliseconds: 1));
 
    final models = await isar.paymentRecords
        .where()
        .filter()
        .monthGreaterThan(start, include: true)
        .monthLessThan(end, include: true)
        .findAll();
 
    return models.map((m) => m.toEntity()).toList();
  }
 
  @override
  Future<void> updatePayment(PaymentRecordEntity payment) async {
    final existing = await isar.paymentRecords.get(payment.id);
    if (existing == null) return;
    existing.isPaid = payment.isPaid;
    existing.amountPaid = payment.amountPaid;
    existing.isExcluded = payment.isExcluded;
    await isar.writeTxn(() => isar.paymentRecords.put(existing));
  }
 
  @override
  Future<void> deletePayment(int paymentId) async {
    await isar.writeTxn(() => isar.paymentRecords.delete(paymentId));
  }
 
  @override
  Future<void> ensureMonthlyRecords(DateTime month) async {
    final monthStart = DateTime(month.year, month.month, 1);
    final students = await isar.students.where().findAll();
 
    for (final student in students) {
      await student.paymentRecords.load();
 
      final exists = student.paymentRecords.any((p) =>
          p.month.year == monthStart.year &&
          p.month.month == monthStart.month);
 
      if (!exists) {
        final record = PaymentRecord(
          month: monthStart,
          isPaid: false,
          amountPaid: 0.0,
          isExcluded: false,
        );
        await isar.writeTxn(() async {
          await isar.paymentRecords.put(record);
          student.paymentRecords.add(record);
          await student.paymentRecords.save();
        });
      }
    }
  }
 
  @override
  Future<void> togglePayment(
      int paymentId, bool isPaid, double monthlyFee) async {
    final record = await isar.paymentRecords.get(paymentId);
    if (record == null) return;
 
    await isar.writeTxn(() async {
      record.isPaid = isPaid;
      record.amountPaid = isPaid ? monthlyFee : 0.0;
      await isar.paymentRecords.put(record);
    });
  }
 
  @override
  Future<void> toggleExcluded(int paymentId, bool isExcluded) async {
    final record = await isar.paymentRecords.get(paymentId);
    if (record == null) return;
 
    await isar.writeTxn(() async {
      record.isExcluded = isExcluded;
      // Reset payment when excluding
      if (isExcluded) {
        record.isPaid = false;
        record.amountPaid = 0.0;
      }
      await isar.paymentRecords.put(record);
    });
  }
}
