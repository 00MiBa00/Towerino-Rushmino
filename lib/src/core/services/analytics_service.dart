import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static late FirebaseAnalytics _analytics;

  static Future<void> initialize() async {
    _analytics = FirebaseAnalytics.instance;
  }

  static Future<void> logEvent(String name, {Map<String, Object>? parameters}) {
    return _analytics.logEvent(name: name, parameters: parameters);
  }
}
