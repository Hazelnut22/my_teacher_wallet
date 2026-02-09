import 'package:isar/isar.dart';
import 'package:my_teacher_wallet/data/models/student.dart';
import 'package:my_teacher_wallet/domain/entities/student_entity.dart';
import 'package:my_teacher_wallet/domain/repositories/student_repository.dart';

class StudentRepositoryImpl implements StudentRepository {
  final Isar isar;

  StudentRepositoryImpl(this.isar);
  
  @override
  Future<void> deleteStudent(int studentId) async {
    await isar.writeTxn(() => isar.students.delete(studentId));
  }

  @override
  Future<List<StudentEntity>> getAllStudents() async {
    final models = await isar.students.where().findAll();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<void> saveStudent(StudentEntity newStudent) async {
    final model = Student.fromEntity(newStudent);
    await isar.writeTxn(() => isar.students.put(model));
  }

  @override
  Future<void> updateStudent(StudentEntity student) async {
    final model = Student.fromEntity(student);
    await isar.writeTxn(() => isar.students.put(model));
  }

}