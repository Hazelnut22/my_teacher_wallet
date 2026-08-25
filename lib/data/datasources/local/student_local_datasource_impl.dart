import 'package:isar/isar.dart';
import 'package:my_teacher_wallet/data/datasources/local/student_local_datasource.dart';
import 'package:my_teacher_wallet/data/models/payment_record.dart';
import 'package:my_teacher_wallet/data/models/student.dart';

class StudentLocalDatasourceImpl extends StudentLocalDatasource {
  final Isar isar;
  StudentLocalDatasourceImpl(this.isar);

  @override
  Future<Student> insert(Student student) async {
    await isar.writeTxn(() => isar.students.put(student));
    return student;
  }

  @override
  Future<void> update(Student student) async {
    await isar.writeTxn(() => isar.students.put(student));
  }

  /// Soft-deletes the student and cascades to their payment records.
  /// Returns the updated student + affected payments (for opportunistic push).
  @override
  Future<(Student, List<PaymentRecord>)?> softDelete(int id) async {
    Student? student;
    final payments = <PaymentRecord>[];

    await isar.writeTxn(() async {
      student = await isar.students.get(id);
      if (student == null) return;

      final now = DateTime.now();
      await student!.paymentRecords.load();
      for (final p in student!.paymentRecords) {
        p.isDeleted = true;
        p.updatedAt = now;
        await isar.paymentRecords.put(p);
        payments.add(p);
      }

      student!.isDeleted = true;
      student!.updatedAt = now;
      await isar.students.put(student!);
    });

    if (student == null) return null;
    return (student!, payments);
  }

  @override
  Future<List<Student>> getAllActive() {
    return isar.students.filter().isDeletedEqualTo(false).findAll();
  }

  @override
  Future<Student?> getById(int id) => isar.students.get(id);

  @override
  Future<Student?> getByUuid(String uuid) =>
      isar.students.filter().uuidEqualTo(uuid).findFirst();

  /// For sync push: all rows changed since [since] (or all rows if null).
  @override
  Future<List<Student>> getUpdatedSince(DateTime? since) {
    if (since == null) return isar.students.where().findAll();
    return isar.students.filter().updatedAtGreaterThan(since).findAll();
  }

  /// For sync pull: apply a remote row using last-write-wins.
  @override
  Future<void> upsertFromRemote(Student incoming) async {
    await isar.writeTxn(() async {
      final existing =
          await isar.students.filter().uuidEqualTo(incoming.uuid).findFirst();

      if (existing == null) {
        await isar.students.put(incoming);
      } else if (incoming.updatedAt!.isAfter(existing.updatedAt!)) {
        existing
          ..name = incoming.name
          ..grade = incoming.grade
          ..monthlyFee = incoming.monthlyFee
          ..updatedAt = incoming.updatedAt
          ..isDeleted = incoming.isDeleted;
        await isar.students.put(existing);
      }
    });
  }
}