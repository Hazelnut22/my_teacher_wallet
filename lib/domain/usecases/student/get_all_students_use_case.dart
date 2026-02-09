import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_teacher_wallet/domain/entities/student_entity.dart';
import 'package:my_teacher_wallet/domain/repositories/repository_provider.dart';
import 'package:my_teacher_wallet/domain/repositories/student_repository.dart';

final getAllStudentUseCaseProvider = Provider<GetAllStudentsUseCase>((ref) {
  return GetAllStudentsUseCase(ref.read(studentRepoProvider));
});

class GetAllStudentsUseCase {
  final StudentRepository repository;
  GetAllStudentsUseCase(this.repository);

  Future<List<StudentEntity>> execute() {
    return repository.getAllStudents();
  }
}