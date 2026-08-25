import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:my_teacher_wallet/domain/repositories/repository_provider.dart';
import 'package:my_teacher_wallet/domain/usecases/auth/register_with_email_use_case.dart';
import 'package:my_teacher_wallet/domain/usecases/auth/sign_in_with_email_use_case.dart';
import 'package:my_teacher_wallet/domain/usecases/auth/sign_in_with_google_use_case.dart';
import 'package:my_teacher_wallet/domain/usecases/auth/sign_out_use_case.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:my_teacher_wallet/core/services/shared_preference_service.dart';
import 'package:my_teacher_wallet/data/database_provider.dart';
import 'package:my_teacher_wallet/ui/screens/auth/providers/auth_state.dart';

class AuthNotifier extends Notifier<UserAuthState> {
  StreamSubscription? _authSub;

  @override
  UserAuthState build() {
    final repo = ref.read(authRepositoryProvider);

    _authSub?.cancel();
    _authSub = repo.onAuthStateChange.listen((authState) {
      final session = authState.session;
      if (session != null) {
        state = UserAuthAuthenticated(session.user);
      } else if (state is! UserAuthLoading && state is! UserAuthError) {
        state = const UserAuthUnauthenticated();
      }
    });

    ref.onDispose(() => _authSub?.cancel());

    final currentUser = repo.currentUser;
    if (currentUser != null) {
      return UserAuthAuthenticated(currentUser);
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
      final user = await ref
          .read(signInWithEmailUseCaseProvider)
          .execute(email: email, password: password)
          .timeout(const Duration(seconds: 15));

      if (user != null) {
        state = UserAuthAuthenticated(user);
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
      final user = await ref
          .read(registerWithEmailUseCaseProvider)
          .execute(name: name, email: email, password: password)
          .timeout(const Duration(seconds: 15));

      final session = ref.read(authRepositoryProvider).currentSession;

      if (session != null || state is UserAuthAuthenticated) {
        if (user != null) {
          state = UserAuthAuthenticated(user);
        }
        debugPrint("Has session: ${session == null}");
        debugPrint("Response: ${user?.email}");
      } else {
        // Session is null -> Email confirmation required
        state = const UserAuthError(
          'Registration successful! Please check your email to confirm your account.',
        );
      }
    } on AuthException catch (e) {
      state = UserAuthError(e.message);
      debugPrint("Error: ${e.message}");
    } catch (e) {
      state = UserAuthError('Unexpected error: ${e.toString()}');
      debugPrint("Error: ${e.toString()}");
    }
  }

  // ── Google ────────────────────────────────────────────────────────────────

  Future<void> signInWithGoogle() async {
    state = const UserAuthLoading();
    try {
      final user = await ref
          .read(signInWithGoogleUseCaseProvider)
          .execute()
          .timeout(const Duration(seconds: 30));

      if (user != null) {
        state = UserAuthAuthenticated(user);
      } else {
        state = const UserAuthError('Google sign-in failed. Please try again.');
      }
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        // User dismissed the picker — not an error
        state = const UserAuthUnauthenticated();
      } else {
        state = UserAuthError('Google error: ${e.description}');
      }
    } on UnsupportedError catch (e) {
      state = UserAuthError(e.message ?? 'Platform not supported.');
    } on AuthException catch (e) {
      state = UserAuthError(e.message);
    } catch (e) {
      state = UserAuthError('Unexpected error: ${e.toString()}');
    }
  }

  // ── Sign Out ──────────────────────────────────────────────────────────────

  Future<void> signOut(WidgetRef ref) async {
    state = const UserAuthLoading();
    try {
      // 1. Sign out via use case (handles Google + Supabase)
      await ref.read(signOutUseCaseProvider).execute();

      // 2. Clear local Isar data
      final isar = ref.read(dbProvider);
      await isar.writeTxn(() async => isar.clear());

      // 3. Clear shared preferences (resets first-use date etc.)
      await SharedPreferenceService.reset();

      state = const UserAuthUnauthenticated();
    } catch (e) {
      // Force unauthenticated even on error so the user is never stuck
      state = const UserAuthUnauthenticated();
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  void clearError() {
    if (state is UserAuthError) {
      state = const UserAuthUnauthenticated();
    }
  }
}

final authProvider = NotifierProvider<AuthNotifier, UserAuthState>(() {
  return AuthNotifier();
});
