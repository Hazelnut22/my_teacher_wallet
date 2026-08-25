import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_teacher_wallet/data/database_provider.dart';
import 'package:my_teacher_wallet/data/datasources/local_datasource_provider.dart';
import 'package:my_teacher_wallet/data/datasources/remote_datasource_provider.dart';
import 'package:my_teacher_wallet/data/repositories/auth_repository_impl.dart';
import 'package:my_teacher_wallet/data/repositories/payment_repository_impl.dart';
import 'package:my_teacher_wallet/data/repositories/student_repository_impl.dart';
import 'package:my_teacher_wallet/domain/repositories/auth_repository.dart';
import 'package:my_teacher_wallet/domain/repositories/payment_repository.dart';
import 'package:my_teacher_wallet/domain/repositories/student_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final studentRepoProvider = Provider<StudentRepository>((ref) {
  final paymentRemote = ref.watch(paymentRemoteDSProvider);
  final studentLocal = ref.watch(studentLocalDSProvider);
  final studentRemote = ref.watch(studentRemoteDSProvider);
  return StudentRepositoryImpl(local: studentLocal, remote: studentRemote, paymentRemote: paymentRemote, authClient: Supabase.instance.client);
});

final paymentRepoProvider = Provider<PaymentRepository>((ref) {
  final paymentLocal = ref.watch(paymentLocalDSProvider);
  final paymentRemote = ref.watch(paymentRemoteDSProvider);
  final studentLocal = ref.watch(studentLocalDSProvider);
  return PaymentRepositoryImpl(local: paymentLocal, remote: paymentRemote, studentLocal: studentLocal, authClient: Supabase.instance.client);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(Supabase.instance.client);
});