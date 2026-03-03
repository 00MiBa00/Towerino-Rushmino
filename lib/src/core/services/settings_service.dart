import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _weeklyResetKey = 'weekly_reset';
  static const String _demoDataKey = 'demo_data_enabled';

  final SharedPreferences _prefs;

  SettingsService(this._prefs);

  bool get weeklyResetEnabled => _prefs.getBool(_weeklyResetKey) ?? false;

  bool get demoDataEnabled => _prefs.getBool(_demoDataKey) ?? false;

  Future<void> setWeeklyReset(bool value) async {
    await _prefs.setBool(_weeklyResetKey, value);
  }

  Future<void> setDemoDataEnabled(bool value) async {
    await _prefs.setBool(_demoDataKey, value);
  }
}
