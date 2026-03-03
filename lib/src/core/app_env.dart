class AppEnvironment {
  static const String _envKey = 'ENV';
  static const String _defaultEnv = 'prod';

  static late String _env;

  static void load() {
    _env = const String.fromEnvironment(_envKey, defaultValue: _defaultEnv);
  }

  static bool get isDev => _env == 'dev';
  static bool get isProd => _env == 'prod';
  static String get name => _env;
}
