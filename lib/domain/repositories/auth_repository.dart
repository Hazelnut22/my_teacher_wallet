import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthRepository {
  /// Returns the currently signed-in [User], or null if not authenticated.
  User? get currentUser;

  /// Returns the current session, if the user has completed authentication.
  Session? get currentSession;

  /// Stream that emits whenever the auth session changes.
  Stream<AuthState> get onAuthStateChange;

  Future<User?> signInWithEmail({
    required String email,
    required String password,
  });

  Future<User?> registerWithEmail({
    required String name,
    required String email,
    required String password,
  });

  Future<User?> signInWithGoogle();

  Future<void> signOut();
}
