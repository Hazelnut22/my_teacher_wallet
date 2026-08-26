import 'package:supabase_flutter/supabase_flutter.dart';

extension UserDisplayName on User {
  String get displayName {
    final fullName = userMetadata?['full_name'] as String?;
    if (fullName != null && fullName.trim().isNotEmpty) return fullName.trim();

    final googleName = userMetadata?['name'] as String?;
    if (googleName != null && googleName.trim().isNotEmpty) return googleName.trim();

    if (email != null && email!.contains('@')) return email!.split('@').first;

    return 'Teacher';
  }
}