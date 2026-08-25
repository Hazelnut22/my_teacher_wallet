import 'package:my_teacher_wallet/data/models/payment_record.dart';
import 'package:my_teacher_wallet/data/models/student.dart';

abstract class StudentLocalDatasource {
  Future<Student> insert(Student student);
  Future<void> update(Student student);
  Future<(Student, List<PaymentRecord>)?> softDelete(int id);
  Future<List<Student>> getAllActive();
  Future<Student?> getById(int id);
  Future<Student?> getByUuid(String uuid);
  Future<List<Student>> getUpdatedSince(DateTime? since);
  Future<void> upsertFromRemote(Student incoming);
}