class NetworkConstants {
  /// Timeout for a single Supabase request (one table call).
  static const Duration requestTimeout = Duration(seconds: 15);

  /// Overall budget for a full sync (push + pull, both tables).
  /// Slightly more than 2x requestTimeout since sync makes ~4 sequential calls.
  static const Duration syncTimeout = Duration(seconds: 45);
}