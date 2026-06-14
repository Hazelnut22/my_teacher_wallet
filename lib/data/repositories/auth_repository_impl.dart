import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:my_teacher_wallet/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient _client;

  AuthRepositoryImpl(this._client);

  @override
  User? get currentUser => _client.auth.currentUser;

  @override
  Stream<AuthState> get onAuthStateChange =>
      _client.auth.onAuthStateChange;

  // ── Email & Password ──────────────────────────────────────────────────────

  @override
  Future<User?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
    return response.user;
  }

  @override
  Future<User?> registerWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signUp(
      email: email.trim(),
      password: password,
      data: {'full_name': name.trim()},
    );
    return response.user;
  }

  // ── Google ────────────────────────────────────────────────────────────────

  @override
  Future<User?> signInWithGoogle() async {
    final googleSignIn = GoogleSignIn.instance;

    if (!googleSignIn.supportsAuthenticate()) {
      throw UnsupportedError(
        'Interactive Google Sign-In is not supported on this platform.',
      );
    }

    final googleUser = await googleSignIn.authenticate();
    final googleAuth = await googleUser.authentication;

    final idToken = googleAuth.idToken;
    final accessToken = googleAuth.idToken;

    if (idToken == null || accessToken == null) {
      throw Exception('Google sign-in failed: missing tokens.');
    }

    final response = await _client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );

    return response.user;
  }

  // ── Sign Out ──────────────────────────────────────────────────────────────

  @override
  Future<void> signOut() async {
    final googleSignIn = GoogleSignIn.instance;

    // Sign out of Google if the user was signed in via Google
    try {
      await googleSignIn.signOut();
    } catch (_) {
      // Not signed in via Google — safe to ignore
    }

    await _client.auth.signOut();
  }
}