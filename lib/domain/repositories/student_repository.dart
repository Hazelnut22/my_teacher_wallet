import 'package:my_teacher_wallet/domain/entities/student_entity.dart';

abstract class StudentRepository {
  Future<void> saveStudent(StudentEntity newStudent);
  Future<List<StudentEntity>> getAllStudents();
  Future<void> updateStudent(StudentEntity student);
  Future<void> deleteStudent(int studentId);
}