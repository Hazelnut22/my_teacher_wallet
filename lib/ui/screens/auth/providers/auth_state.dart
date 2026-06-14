import 'package:supabase_flutter/supabase_flutter.dart';

sealed class UserAuthState {
  const UserAuthState();
}

class UserAuthLoading extends UserAuthState {
  const UserAuthLoading();
}

class UserAuthAuthenticated extends UserAuthState {
  final User user;
  const UserAuthAuthenticated(this.user);
}

class UserAuthUnauthenticated extends UserAuthState {
  const UserAuthUnauthenticated();
}

class UserAuthError extends UserAuthState {
  final String message;
  const UserAuthError(this.message);
}