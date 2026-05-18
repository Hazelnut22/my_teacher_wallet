import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_teacher_wallet/domain/repositories/payment_repository.dart';
import 'package:my_teacher_wallet/domain/repositories/repository_provider.dart';

final togglePaymentUseCaseProvider = Provider<TogglePaymentUseCase>((ref) {
  return TogglePaymentUseCase(ref.read(paymentRepoProvider));
});

class TogglePaymentUseCase {
  final PaymentRepository repository;
  TogglePaymentUseCase(this.repository);

  Future<void> execute(int paymentId, bool isPaid, double monthlyFee) =>
      repository.togglePayment(paymentId, isPaid, monthlyFee);
}