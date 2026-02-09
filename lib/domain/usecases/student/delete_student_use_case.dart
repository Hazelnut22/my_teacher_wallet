import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_teacher_wallet/domain/repositories/repository_provider.dart';
import 'package:my_teacher_wallet/domain/repositories/student_repository.dart';

final deleteStudentUseCaseProvider = Provider<DeleteStudentUseCase>((ref) {
  return DeleteStudentUseCase(ref.read(studentRepoProvider));
});

class DeleteStudentUseCase {
  final StudentRepository repository;
  DeleteStudentUseCase(this.repository);

  Future<void> execute(int studentId) {
    return repository.deleteStudent(studentId);
  }
}