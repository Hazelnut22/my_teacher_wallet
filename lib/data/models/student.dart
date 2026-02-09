import 'package:isar/isar.dart';
import 'package:my_teacher_wallet/data/models/payment_record.dart';
import 'package:my_teacher_wallet/domain/entities/student_entity.dart';

part 'student.g.dart';

@collection
class Student {
  Id id = Isar.autoIncrement;

  String name;

  String grade;

  double monthlyFee;

  @Backlink(to: 'student')
  final paymentRecords = IsarLinks<PaymentRecord>();

  Student({
    required this.name,
    required this.monthlyFee,
    required this.grade,
  });

  StudentEntity toEntity() {
    return StudentEntity(
      id: id,
      name: name,
      grade: grade,
      monthlyFee: monthlyFee,
      payments: paymentRecords.map((p) => p.toEntity()).toList(),
    );
  }

  factory Student.fromEntity(StudentEntity entity) {
    return Student(
      name: entity.name,
      grade: entity.grade,
      monthlyFee: entity.monthlyFee,
    );
  }
}