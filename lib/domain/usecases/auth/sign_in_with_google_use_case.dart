import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_teacher_wallet/domain/repositories/auth_repository.dart';
import 'package:my_teacher_wallet/domain/repositories/repository_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final signInWithGoogleUseCaseProvider =
    Provider<SignInWithGoogleUseCase>((ref) {
  return SignInWithGoogleUseCase(ref.read(authRepositoryProvider));
});
 
class SignInWithGoogleUseCase {
  final AuthRepository _repository;
  SignInWithGoogleUseCase(this._repository);
 
  /// Returns the authenticated [User] on success.
  /// Throws [GoogleSignInException] if the user cancels or an error occurs.
  Future<User?> execute() {
    return _repository.signInWithGoogle();
  }
}