import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:my_teacher_wallet/core/services/shared_preference_service.dart';
import 'package:my_teacher_wallet/ui/screens/auth/providers/auth_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:my_teacher_wallet/data/database_provider.dart';

class AuthNotifier extends Notifier<UserAuthState> {
  late final SupabaseClient _client;

  @override
  UserAuthState build() {
    _client = Supabase.instance.client;

    // Listen to Supabase auth stream and update state reactively
    _client.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session != null) {
        state = UserAuthAuthenticated(session.user);
      } else {
        state = const UserAuthUnauthenticated();
      }
    });

    // Resolve initial state from existing session
    final session = _client.auth.currentSession;
    if (session != null) {
      return UserAuthAuthenticated(session.user);
    }
    return const UserAuthUnauthenticated();
  }

  // ── Email & Password ──────────────────────────────────────────────────────

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = const UserAuthLoading();
    try {
      final response = await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      if (response.user != null) {
        state = UserAuthAuthenticated(response.user!);
      } else {
        state = const UserAuthError('Login failed. Please try again.');
      }
    } on AuthException catch (e) {
      state = UserAuthError(e.message);
    } catch (e) {
      state = UserAuthError('Unexpected error: ${e.toString()}');
    }
  }

  Future<void> registerWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    state = const UserAuthLoading();
    try {
      final response = await _client.auth.signUp(
        email: email.trim(),
        password: password,
        data: {'full_name': name.trim()},
      );
      if (response.user != null) {
        state = UserAuthAuthenticated(response.user!);
      } else {
        // Supabase may require email confirmation
        state = const UserAuthError(
          'Registration successful! Please check your email to confirm your account.',
        );
      }
    } on AuthException catch (e) {
      state = UserAuthError(e.message);
    } catch (e) {
      state = UserAuthError('Unexpected error: ${e.toString()}');
    }
  }

  // ── Google Sign-In ────────────────────────────────────────────────────────

  Future<void> signInWithGoogle() async {
    state = const UserAuthLoading();
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn.instance;
      GoogleSignInAccount? googleUser;

      // Check if the current platform supports the direct .authenticate() method
      if (googleSignIn.supportsAuthenticate()) {
        googleUser = await googleSignIn.authenticate();
      } else {
        // Note: On Web, you should render the native Google Sign-In button
        // via GoogleSignInPlatform.instance.renderWebButton() instead of calling this method.
        state = const UserAuthError(
          'Interactive sign-in not supported directly on this platform.',
        );
        return;
      }

      // Explicitly handling user cancellation throws an exception in the latest version
      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.idToken;

      if (idToken == null || accessToken == null) {
        state = const UserAuthError('Google sign-in failed: missing tokens.');
        return;
      }

      // Pass the native tokens directly to Supabase Identity Provider
      final response = await _client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      if (response.user != null) {
        state = UserAuthAuthenticated(response.user!);
      } else {
        state = const UserAuthError('Google sign-in failed. Please try again.');
      }
    } on GoogleSignInException catch (e) {
      // Handling explicit user cancellation or platform configurations
      if (e.code == GoogleSignInExceptionCode.canceled) {
        state = const UserAuthUnauthenticated();
      } else {
        state = UserAuthError('Google Plugin Error: ${e.description}');
      }
    } on AuthException catch (e) {
      state = UserAuthError(e.message);
    } catch (e) {
      state = UserAuthError('Google sign-in error: ${e.toString()}');
    }
  }

  // ── Sign Out ──────────────────────────────────────────────────────────────

  Future<void> signOut(WidgetRef ref) async {
    state = const UserAuthLoading();
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn.instance;

      // Clear session context out of Google native SDK
      await googleSignIn.signOut();

      // Terminate Supabase session instance
      await _client.auth.signOut();

      // Clear local data storage
      final isar = ref.read(dbProvider);
      await isar.writeTxn(() async => isar.clear());
      await SharedPreferenceService.reset();

      state = const UserAuthUnauthenticated();
    } catch (e) {
      state = const UserAuthUnauthenticated();
    }
  }

  String? get currentUserId => _client.auth.currentUser?.id;

  bool get isAuthenticated => state is UserAuthAuthenticated;

  void clearError() {
    if (state is UserAuthError) {
      state = const UserAuthUnauthenticated();
    }
  }
}

final authProvider = NotifierProvider<AuthNotifier, UserAuthState>(() {
  return AuthNotifier();
});
