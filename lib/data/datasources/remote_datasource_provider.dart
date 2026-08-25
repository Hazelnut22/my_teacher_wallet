import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_teacher_wallet/data/datasources/remote/payment_remote_datasource.dart';
import 'package:my_teacher_wallet/data/datasources/remote/payment_remote_datasource_impl.dart';
import 'package:my_teacher_wallet/data/datasources/remote/student_remote_datasource.dart';
import 'package:my_teacher_wallet/data/datasources/remote/student_remote_datasource_impl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final studentRemoteDSProvider = Provider<StudentRemoteDatasource>((ref) {
  return StudentRemoteDatasourceImpl(Supabase.instance.client);
});

final paymentRemoteDSProvider = Provider<PaymentRemoteDatasource>((ref) {
  return PaymentRemoteDatasourceImpl(Supabase.instance.client);
});