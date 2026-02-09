import 'package:isar/isar.dart';
import 'package:my_teacher_wallet/data/models/student.dart';
import 'package:my_teacher_wallet/domain/entities/payment_record_entity.dart';

part 'payment_record.g.dart';

@collection
class PaymentRecord {
  Id id = Isar.autoIncrement;

  DateTime month;

  bool isPaid;

  double amountPaid;
  
  final student = IsarLink<Student>();

  PaymentRecord({
    required this.month,
    this.isPaid = false,
    this.amountPaid = 0.0,
  });

  PaymentRecordEntity toEntity() => PaymentRecordEntity(
    id: id,
    month: month,
    isPaid: isPaid,
    amountPaid: amountPaid,
  );

  factory PaymentRecord.fromEntity(PaymentRecordEntity entity) {
    return PaymentRecord(
      month: entity.month,
      isPaid: entity.isPaid,
      amountPaid: entity.amountPaid
    )..id = entity.id;
  }
}