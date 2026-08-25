import 'package:isar/isar.dart';
import 'package:my_teacher_wallet/data/models/student.dart';
import 'package:my_teacher_wallet/domain/entities/payment_record_entity.dart';
import 'package:uuid/uuid.dart';

part 'payment_record.g.dart';

@collection
class PaymentRecord {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String? uuid;

  DateTime month;

  bool isPaid;

  double amountPaid;

  bool isExcluded;

  DateTime? updatedAt;

  bool isDeleted;
  
  final student = IsarLink<Student>();

  PaymentRecord({
    required this.month,
    this.isPaid = false,
    this.amountPaid = 0.0,
    this.isExcluded = false,
    String? uuid,
    DateTime? updatedAt,
    this.isDeleted = false,
  })  : uuid = uuid ?? const Uuid().v4(),
        updatedAt = updatedAt ?? DateTime.now();

  PaymentRecordEntity toEntity() => PaymentRecordEntity(
    id: id,
    month: month,
    isPaid: isPaid,
    amountPaid: amountPaid,
    isExcluded: isExcluded,
  );

  factory PaymentRecord.fromEntity(PaymentRecordEntity entity) {
    return PaymentRecord(
      month: entity.month,
      isPaid: entity.isPaid,
      amountPaid: entity.amountPaid,
      isExcluded: entity.isExcluded,
    )..id = entity.id;
  }
}