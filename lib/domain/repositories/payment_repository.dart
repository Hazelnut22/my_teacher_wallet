import 'package:my_teacher_wallet/domain/entities/payment_record_entity.dart';

abstract class PaymentRepository {
  Future<void> addPaymentRecord(PaymentRecordEntity newRecord);
  Future<List<PaymentRecordEntity>> getAllPayments();
  Future<void> updatePayment(PaymentRecordEntity payment);
  Future<void> deletePayment(int paymentId);
}