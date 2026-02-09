import 'package:my_teacher_wallet/domain/repositories/payment_repository.dart';

class DeletePaymentUseCase {
  final PaymentRepository repository;
  DeletePaymentUseCase(this.repository);

  Future<void> execute(int paymentId) {
    return repository.deletePayment(paymentId);
  }
}