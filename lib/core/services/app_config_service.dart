import 'package:shared_preferences/shared_preferences.dart';

class AppConfigService {
  static const _keyFirstUseDate = 'first_use_date';

  /// Returns the first-use date. If not set, sets it to today and returns it.
  static Future<DateTime> getOrSetFirstUseDate() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_keyFirstUseDate);

    if (stored != null) {
      return DateTime.parse(stored);
    }

    final now = DateTime.now();
    final firstUse = DateTime(now.year, now.month, 1);
    await prefs.setString(_keyFirstUseDate, firstUse.toIso8601String());
    return firstUse;
  }
}