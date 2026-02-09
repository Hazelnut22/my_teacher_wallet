import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_teacher_wallet/data/database_provider.dart';
import 'package:my_teacher_wallet/data/repositories/payment_repository_impl.dart';
import 'package:my_teacher_wallet/data/repositories/student_repository_impl.dart';
import 'package:my_teacher_wallet/domain/repositories/payment_repository.dart';
import 'package:my_teacher_wallet/domain/repositories/student_repository.dart';

final studentRepoProvider = Provider<StudentRepository>((ref) {
  final isar = ref.watch(dbProvider);
  return StudentRepositoryImpl(isar);
});

final paymentRepoProvider = Provider<PaymentRepository>((ref) {
  final isar = ref.watch(dbProvider);
  return PaymentRepositoryImpl(isar);
});