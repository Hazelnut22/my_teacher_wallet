import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_teacher_wallet/domain/repositories/auth_repository.dart';
import 'package:my_teacher_wallet/domain/repositories/repository_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final signInWithEmailUseCaseProvider =
    Provider<SignInWithEmailUseCase>((ref) {
  return SignInWithEmailUseCase(ref.read(authRepositoryProvider));
});
 
class SignInWithEmailUseCase {
  final AuthRepository _repository;
  SignInWithEmailUseCase(this._repository);
 
  /// Returns the authenticated [User] on success.
  /// Throws [AuthException] or [Exception] on failure.
  Future<User?> execute({
    required String email,
    required String password,
  }) {
    return _repository.signInWithEmail(email: email, password: password);
  }
}