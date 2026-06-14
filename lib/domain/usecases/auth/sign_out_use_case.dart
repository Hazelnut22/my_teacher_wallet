import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_teacher_wallet/domain/repositories/auth_repository.dart';
import 'package:my_teacher_wallet/domain/repositories/repository_provider.dart';

final signOutUseCaseProvider = Provider<SignOutUseCase>((ref) {
  return SignOutUseCase(ref.read(authRepositoryProvider));
});
 
class SignOutUseCase {
  final AuthRepository _repository;
  SignOutUseCase(this._repository);
 
  Future<void> execute() {
    return _repository.signOut();
  }
}