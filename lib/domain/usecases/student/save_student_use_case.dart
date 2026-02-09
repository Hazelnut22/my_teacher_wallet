import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_teacher_wallet/domain/entities/student_entity.dart';
import 'package:my_teacher_wallet/domain/repositories/repository_provider.dart';
import 'package:my_teacher_wallet/domain/repositories/student_repository.dart';

final saveStudentUseCaseProvider = Provider<SaveStudentUseCase>((ref) {
  return SaveStudentUseCase(ref.read(studentRepoProvider));
});

class SaveStudentUseCase {
  final StudentRepository repository;
  SaveStudentUseCase(this.repository);

  Future<void> execute(StudentEntity student) {
    return repository.saveStudent(student);
  }
}