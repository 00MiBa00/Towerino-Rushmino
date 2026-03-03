import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../firebase_options.dart';
import '../core/app_env.dart';
import '../core/services/analytics_service.dart';
import '../core/services/crashlytics_service.dart';
import '../core/services/notification_service.dart';
import '../data/datasources/task_local_datasource.dart';

class AppBootstrap {
  static Future<void> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await Hive.initFlutter();
    await Hive.openBox<String>(TaskLocalDataSource.boxName);

    await NotificationService.initialize();
    await AnalyticsService.initialize();
    await CrashlyticsService.initialize();

    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      CrashlyticsService.recordFlutterError(details);
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      CrashlyticsService.recordError(error, stack);
      return true;
    };

    AppEnvironment.load();
  }
}
