import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_teacher_wallet/domain/entities/payment_record_entity.dart';
import 'package:my_teacher_wallet/domain/repositories/payment_repository.dart';
import 'package:my_teacher_wallet/domain/repositories/repository_provider.dart';

final addPaymentRecordUseCaseProvider =
    Provider<AddPaymentRecordUseCase>((ref) {
  return AddPaymentRecordUseCase(ref.read(paymentRepoProvider));
});

class AddPaymentRecordUseCase {
  final PaymentRepository repository;
  AddPaymentRecordUseCase(this.repository);

  Future<void> execute(PaymentRecordEntity record, int studentId) =>
      repository.addPaymentRecord(record, studentId);
}
