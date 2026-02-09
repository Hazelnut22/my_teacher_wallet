import 'package:my_teacher_wallet/domain/entities/payment_record_entity.dart';
import 'package:my_teacher_wallet/domain/repositories/payment_repository.dart';

class UpdatePaymentUseCase {
  final PaymentRepository repository;
  UpdatePaymentUseCase(this.repository);

  Future<void> execute(PaymentRecordEntity payment) {
    return repository.updatePayment(payment);
  }
}