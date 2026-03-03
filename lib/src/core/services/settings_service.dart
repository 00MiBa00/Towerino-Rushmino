import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _weeklyResetKey = 'weekly_reset';

  final SharedPreferences _prefs;

  SettingsService(this._prefs);

  bool get weeklyResetEnabled => _prefs.getBool(_weeklyResetKey) ?? false;

  Future<void> setWeeklyReset(bool value) async {
    await _prefs.setBool(_weeklyResetKey, value);
  }
}
