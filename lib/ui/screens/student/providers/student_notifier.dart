import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_teacher_wallet/domain/entities/student_entity.dart';
import 'package:my_teacher_wallet/domain/usecases/student/delete_student_use_case.dart';
import 'package:my_teacher_wallet/domain/usecases/student/get_all_students_use_case.dart';
import 'package:my_teacher_wallet/domain/usecases/student/save_student_use_case.dart';
import 'package:my_teacher_wallet/domain/usecases/student/update_student_use_case.dart';

class StudentNotifier extends AsyncNotifier<List<StudentEntity>> {
  
  @override
  Future<List<StudentEntity>> build() async {
    final getStudentsUC = ref.watch(getAllStudentUseCaseProvider);
    return getStudentsUC.execute();
  }

  Future<void> addStudent(StudentEntity student) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await ref.read(saveStudentUseCaseProvider).execute(student);
      return ref.read(getAllStudentUseCaseProvider).execute();
    });
  }

  Future<void> removeStudent(int id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(deleteStudentUseCaseProvider).execute(id);
      return ref.read(getAllStudentUseCaseProvider).execute();
    });
  }

  Future<void> updateStudent(StudentEntity student) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(updateStudentUseCaseProvider).execute(student);
      return ref.read(getAllStudentUseCaseProvider).execute();
    });
  }
}