import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_teacher_wallet/domain/entities/student_entity.dart';
import 'package:my_teacher_wallet/domain/repositories/repository_provider.dart';
import 'package:my_teacher_wallet/domain/repositories/student_repository.dart';

final updateStudentUseCaseProvider = Provider<UpdateStudentUseCase>((ref) {
  return UpdateStudentUseCase(ref.read(studentRepoProvider));
});

class UpdateStudentUseCase {
  final StudentRepository repository;
  UpdateStudentUseCase(this.repository);

  Future<void> execute(StudentEntity student) {
    return repository.updateStudent(student);
  }
}