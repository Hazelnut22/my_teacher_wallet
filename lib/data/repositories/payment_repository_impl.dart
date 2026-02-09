import 'package:isar/isar.dart';
import 'package:my_teacher_wallet/data/models/payment_record.dart';
import 'package:my_teacher_wallet/domain/entities/payment_record_entity.dart';
import 'package:my_teacher_wallet/domain/repositories/payment_repository.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final Isar isar;

  PaymentRepositoryImpl(this.isar);
  
  @override
  Future<void> deletePayment(int paymentId) async {
    await isar.writeTxn(() => isar.paymentRecords.delete(paymentId));
  }

  @override
  Future<List<PaymentRecordEntity>> getAllPayments() async {
    final models = await isar.paymentRecords.where().findAll();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<void> addPaymentRecord(PaymentRecordEntity newRecord) async {
    final model = PaymentRecord.fromEntity(newRecord);
    await isar.writeTxn(() => isar.paymentRecords.put(model));
  }

  @override
  Future<void> updatePayment(PaymentRecordEntity payment) async {
    final model = PaymentRecord.fromEntity(payment);
    await isar.writeTxn(() => isar.paymentRecords.put(model));
  }

}