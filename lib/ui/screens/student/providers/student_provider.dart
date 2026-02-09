import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_teacher_wallet/domain/entities/student_entity.dart';
import 'package:my_teacher_wallet/ui/screens/student/providers/student_notifier.dart';

final studentProvider = AsyncNotifierProvider<StudentNotifier, List<StudentEntity>>(() {
  return StudentNotifier();
});