import 'package:my_teacher_wallet/data/models/student.dart';

abstract class StudentRemoteDatasource {
  Future<void> upsertOne(Student student, String userId);
  Future<void> upsertMany(List<Student> students, String userId);
  Future<List<Map<String, dynamic>>> fetchAll(String userId, {DateTime? since});
  Future<void> deleteAllForUser(String userId);
}