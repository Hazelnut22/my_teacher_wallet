import 'package:my_teacher_wallet/domain/entities/payment_record_entity.dart';

abstract class PaymentRepository {
  Future<void> addPaymentRecord(PaymentRecordEntity newRecord, int studentId);
  Future<List<PaymentRecordEntity>> getAllPayments();
  Future<List<PaymentRecordEntity>> getPaymentsByMonth(int year, int month);
  Future<void> updatePayment(PaymentRecordEntity payment);
  Future<void> deletePayment(int paymentId);

  /// Ensures every student has a PaymentRecord for the given month.
  /// Does NOT back-fill — only call for current month or forward.
  Future<void> ensureMonthlyRecords(DateTime month);

  /// Toggle isPaid for a specific payment record.
  /// Sets amountPaid = studentMonthlyFee if isPaid, else 0.
  Future<void> togglePayment(int paymentId, bool isPaid, double monthlyFee);

  /// Toggle excluded status for a student in a specific month.
  /// When excluded, isPaid is reset to false and amountPaid to 0.
  Future<void> toggleExcluded(int paymentId, bool isExcluded);
}