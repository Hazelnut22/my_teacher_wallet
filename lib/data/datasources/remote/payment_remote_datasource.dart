import 'package:my_teacher_wallet/data/models/payment_record.dart';

abstract class PaymentRemoteDatasource {
  Future<void> upsertOne(PaymentRecord record, String userId, String studentUuid);
  Future<void> upsertManyWithStudentUuids(
    List<MapEntry<PaymentRecord, String>> recordsWithStudentUuid,
    String userId,
  );
  Future<List<Map<String, dynamic>>> fetchAll(String userId, {DateTime? since});
}