import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_teacher_wallet/data/database_provider.dart';
import 'package:my_teacher_wallet/data/datasources/local/payment_local_datasource.dart';
import 'package:my_teacher_wallet/data/datasources/local/payment_local_datasource_impl.dart';
import 'package:my_teacher_wallet/data/datasources/local/student_local_datasource.dart';
import 'package:my_teacher_wallet/data/datasources/local/student_local_datasource_impl.dart';

final studentLocalDSProvider = Provider<StudentLocalDatasource>((ref) {
  final isar = ref.watch(dbProvider);
  return StudentLocalDatasourceImpl(isar);
});

final paymentLocalDSProvider = Provider<PaymentLocalDatasource>((ref) {
  final isar = ref.watch(dbProvider);
  return PaymentLocalDatasourceImpl(isar);
});