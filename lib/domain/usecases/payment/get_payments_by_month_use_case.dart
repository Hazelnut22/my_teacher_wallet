import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_teacher_wallet/domain/repositories/payment_repository.dart';
import 'package:my_teacher_wallet/domain/repositories/repository_provider.dart';
import 'package:my_teacher_wallet/domain/entities/payment_record_entity.dart';

final getPaymentsByMonthUseCaseProvider =
    Provider<GetPaymentsByMonthUseCase>((ref) {
  return GetPaymentsByMonthUseCase(ref.read(paymentRepoProvider));
});

class GetPaymentsByMonthUseCase {
  final PaymentRepository repository;
  GetPaymentsByMonthUseCase(this.repository);

  Future<List<PaymentRecordEntity>> execute(int year, int month) =>
      repository.getPaymentsByMonth(year, month);
}