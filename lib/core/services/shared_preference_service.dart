import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceService {
  static const _keyFirstUseDate = 'first_use_date';
  static const _keySwipeHintSeen = 'swipe_hint_seen';
  static const _keyLastSyncedAt = 'last_synced_at';

  /// Returns the first-use date. If not set, sets it to today and returns it.
  static Future<DateTime> getOrSetFirstUseDate() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_keyFirstUseDate);
    if (stored != null) return DateTime.parse(stored);
    final now = DateTime.now();
    final firstUse = DateTime(now.year, now.month, 1);
    await prefs.setString(_keyFirstUseDate, firstUse.toIso8601String());
    return firstUse;
  }

  /// Returns true if the swipe hint has already been shown.
  static Future<bool> hasSeenSwipeHint() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keySwipeHintSeen) ?? false;
  }

  /// Marks the swipe hint as seen.
  static Future<void> markSwipeHintSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySwipeHintSeen, true);
  }

  /// Clears all shared_preferences data (called on reset).
  static Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<DateTime?> getLastSyncedAt() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getString(_keyLastSyncedAt);
    return v != null ? DateTime.parse(v) : null;
  }

  static Future<void> setLastSyncedAt(DateTime time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastSyncedAt, time.toIso8601String());
  }
}
