import 'package:my_teacher_wallet/data/models/payment_record.dart';
import 'package:my_teacher_wallet/data/models/student.dart';

abstract class PaymentLocalDatasource {
  Future<PaymentRecord> insert(PaymentRecord record, {required Student student});
  Future<void> update(PaymentRecord record);
  Future<PaymentRecord?> softDelete(int id);
  Future<PaymentRecord?> getById(int id);
  Future<PaymentRecord?> getByUuid(String uuid);
  Future<List<PaymentRecord>> getAllActive() ;
  Future<List<PaymentRecord>> getByMonthRange(DateTime start, DateTime end);
  Future<List<PaymentRecord>> getUpdatedSince(DateTime? since);
  Future<void> upsertFromRemote(PaymentRecord incoming, {required Student parent});
}