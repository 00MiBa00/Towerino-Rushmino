import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../app_config.dart';
import '../services/sdk_initializer.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      await SdkInitializer.initAll(context);
    } catch (e) {
      if (kDebugMode) {
        print('SdkInitializer.initAll error: $e');
      }
      if (!mounted) return;
      SdkInitializer.showApp(context);
      return;
    }

    if (!mounted) return;

    // initAll вернулся без навигации — это ожидаемо только при первом запуске
    // (ждём AppsFlyer callback). Если это НЕ первый запуск — навигация не случилась
    // по какой-то причине, делаем fallback.
    final isFirstStart = !SdkInitializer.hasValue("isFirstStart");
    if (!isFirstStart) {
      if (kDebugMode) {
        print('Fallback navigation triggered on restart');
      }
      final storedUrl = SdkInitializer.getValue('receivedUrl');
      if (storedUrl is String && storedUrl.isNotEmpty) {
        SdkInitializer.receivedUrl = storedUrl;
        SdkInitializer.showWeb(context);
      } else {
        SdkInitializer.showApp(context);
      }
    }
    // Если первый запуск — ждём onEndRequest от AppsFlyer
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.width;
    final logoSize = screenHeight * 0.8; // Адаптивный размер логотипа

    return Scaffold(
      body: Container(
        decoration: AppConfig
            .splashDecoration, // const BoxDecoration(gradient: AppConfig.splashGradient),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Image.asset(
                    AppConfig.logoPath,
                    height: logoSize,
                    width: logoSize,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      color: AppConfig.spinerColor,
                      strokeWidth: 4,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Loading...',
                      style: TextStyle(
                        color: AppConfig.loadingTextColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
