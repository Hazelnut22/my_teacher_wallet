import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_teacher_wallet/domain/repositories/payment_repository.dart';
import 'package:my_teacher_wallet/domain/repositories/repository_provider.dart';

final toggleExcludedUseCaseProvider = Provider<ToggleExcludedUseCase>((ref) {
  return ToggleExcludedUseCase(ref.read(paymentRepoProvider));
});
 
class ToggleExcludedUseCase {
  final PaymentRepository repository;
  ToggleExcludedUseCase(this.repository);
 
  Future<void> execute(int paymentId, bool isExcluded) =>
      repository.toggleExcluded(paymentId, isExcluded);
}