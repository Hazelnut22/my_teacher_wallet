import 'package:my_teacher_wallet/domain/entities/payment_record_entity.dart';
import 'package:my_teacher_wallet/domain/repositories/payment_repository.dart';

class GetAllPaymentsUseCase {
  final PaymentRepository repository;
  GetAllPaymentsUseCase(this.repository);

  Future<List<PaymentRecordEntity>> execute() {
    return repository.getAllPayments();
  }
}