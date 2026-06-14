import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_teacher_wallet/domain/repositories/auth_repository.dart';
import 'package:my_teacher_wallet/domain/repositories/repository_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final registerWithEmailUseCaseProvider =
    Provider<RegisterWithEmailUseCase>((ref) {
  return RegisterWithEmailUseCase(ref.read(authRepositoryProvider));
});
 
class RegisterWithEmailUseCase {
  final AuthRepository _repository;
  RegisterWithEmailUseCase(this._repository);
 
  /// Returns the newly created [User] on success, or null if email
  /// confirmation is required before the session is established.
  Future<User?> execute({
    required String name,
    required String email,
    required String password,
  }) {
    return _repository.registerWithEmail(
      name: name,
      email: email,
      password: password,
    );
  }
}