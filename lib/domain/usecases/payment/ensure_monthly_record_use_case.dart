import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_teacher_wallet/domain/repositories/payment_repository.dart';
import 'package:my_teacher_wallet/domain/repositories/repository_provider.dart';

final ensureMonthlyRecordsUseCaseProvider =
    Provider<EnsureMonthlyRecordsUseCase>((ref) {
  return EnsureMonthlyRecordsUseCase(ref.read(paymentRepoProvider));
});

class EnsureMonthlyRecordsUseCase {
  final PaymentRepository repository;
  EnsureMonthlyRecordsUseCase(this.repository);

  Future<void> execute(DateTime month) => repository.ensureMonthlyRecords(month);
}