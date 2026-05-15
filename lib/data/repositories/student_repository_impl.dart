import 'package:isar/isar.dart';
import 'package:my_teacher_wallet/data/models/payment_record.dart';
import 'package:my_teacher_wallet/data/models/student.dart';
import 'package:my_teacher_wallet/domain/entities/student_entity.dart';
import 'package:my_teacher_wallet/domain/repositories/student_repository.dart';

class StudentRepositoryImpl implements StudentRepository {
  final Isar isar;

  StudentRepositoryImpl(this.isar);

  @override
  Future<void> deleteStudent(int studentId) async {
    await isar.writeTxn(() async {
      // Also delete all related payment records
      final student = await isar.students.get(studentId);
      if (student != null) {
        await student.paymentRecords.load();
        final paymentIds = student.paymentRecords.map((p) => p.id).toList();
        await isar.paymentRecords.deleteAll(paymentIds);
      }
      await isar.students.delete(studentId);
    });
  }

  @override
  Future<List<StudentEntity>> getAllStudents() async {
    final models = await isar.students.where().findAll();
    final entities = <StudentEntity>[];
    for (final model in models) {
      await model.paymentRecords.load();
      entities.add(model.toEntity());
    }
    return entities;
  }

  @override
  Future<void> saveStudent(StudentEntity newStudent) async {
    final model = Student.fromEntity(newStudent);
    await isar.writeTxn(() => isar.students.put(model));
  }

  @override
  Future<void> updateStudent(StudentEntity student) async {
    if (student.id == null) return;
    final existing = await isar.students.get(student.id!);
    if (existing == null) return;

    existing.name = student.name;
    existing.grade = student.grade;
    existing.monthlyFee = student.monthlyFee;

    await isar.writeTxn(() => isar.students.put(existing));
  }
}