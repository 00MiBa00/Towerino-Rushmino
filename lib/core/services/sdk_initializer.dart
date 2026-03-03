import 'dart:async';
import 'dart:io' show Platform;
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../../app/clear_app.dart';
import '../../firebase_options.dart';
import '../app_config.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_messaging_service.dart';
import '../screens/no_internet_connection.dart';
import 'push_request_control.dart';
import '../screens/push_request_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../screens/webview_screen.dart';

class SdkInitializer {
  static BuildContext? _context;
  static AppsflyerSdk? _appsflyerSdk;

  // Runtime storage for variables during app execution
  static final Map<String, dynamic> _runtimeStorage = {};
  static Map<String, dynamic> _convrtsion = {};

  // Getters for quick access to common variables
  static String? receivedUrl;
  static String? pushURL;
  static String? get conversionData =>
      _runtimeStorage['conversionData'] as String?;
  static Map<String, dynamic>? get serverResponse =>
      _runtimeStorage['serverResponse'] as Map<String, dynamic>?;
  static String? get apnsToken => _runtimeStorage['apnsToken'] as String?;
  static SharedPreferences? prefs;

  static PushRequestData? pushRequestData;

  static String deep_link_sub1 = "";
  static String deep_link_value = "";

  /// Saves _runtimeStorage contents as a JSON string
  static String saveRuntimeStorage() {
    try {
      return json.encode(_runtimeStorage);
    } catch (e) {
      //  print('Error saving _runtimeStorage: $e');
      return '{}';
    }
  }

  /// Loads JSON string into _runtimeStorage (overwrites old values)
  static void loadRuntimeStorage(String jsonString) {
    try {
      Map<String, dynamic> map = json.decode(jsonString);
      _runtimeStorage
        ..clear()
        ..addAll(map);
    } catch (e) {
      // print('Error loading _runtimeStorage: $e');
    }
  }

  // Storage helper methods
  static void setValue(String key, dynamic value) {
    _runtimeStorage[key] = value;
    saveRuntimeStorageToDevice();
  }

  static Future<void> saveRuntimeStorageToDevice() async {
    try {
      final jsonString = saveRuntimeStorage();
      await prefs!.setString('runtimeStorage', jsonString);
      //  print("save data $jsonString");
    } catch (e) {
      if (kDebugMode) {
        print('Error saving runtimeStorage on device: $e');
      }
    }
  }

  static Future<void> loadRuntimeStorageToDevice() async {
    try {
      final json = prefs?.getString('runtimeStorage');
      if (json != null && json.isNotEmpty) {
        loadRuntimeStorage(json);
        if (kDebugMode) {
          print('runtimeStorage loaded successfully');
        }
      } else {
        if (kDebugMode) {
          print('runtimeStorage is empty (first launch)');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading runtimeStorage on device: $e');
      }
    }
  }

  static dynamic getValue(String key) {
    return _runtimeStorage[key];
  }

  static bool hasValue(String key) {
    return _runtimeStorage.containsKey(key);
  }

  static void clearStorage() {
    _runtimeStorage.clear();
  }

  static Map<String, dynamic> getAllValues() {
    return Map.from(_runtimeStorage);
  }

  static void showApp(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const ClearApp()),
      (route) => false,
    );
  }

  static void showWeb(BuildContext context) {
    if (kDebugMode) {
      print('3 showWeb');
    }
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const WebViewScreen()),
      (route) => false,
    );
  }

  static const MethodChannel _channel = MethodChannel(
    'com.yourapp/native_methods',
  );

  static Future<void> callSwiftMethod() async {
    try {
      await _channel.invokeMethod('callSwiftMethod');
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print("Failed to call Swift method: '${e.message}'");
      }
    }
  }

  /// Requests App Tracking Transparency permission (iOS 14+).
  /// Must be called after the first Flutter frame is drawn.
  static Future<void> _requestATT() async {
    try {
      final status =
          await AppTrackingTransparency.requestTrackingAuthorization();
      if (kDebugMode) {
        print('ATT status: $status');
      }
    } catch (e) {
      if (kDebugMode) {
        print('ATT error: $e');
      }
    }
  }

  static Future<void> initAll(BuildContext context) async {
    var isNotInternet =
        await NoInternetConnectionScreen.checkInternetConnection();

    // print('isNotInternet =' + isNotInternet.toString());
    if (!isNotInternet) {
      NoInternetConnectionScreen.showIfNoInternet(context);
      return;
    }
    prefs = await SharedPreferences.getInstance();
    await loadRuntimeStorageToDevice();

    if (hasValue("pushRequestData")) {
      pushRequestData = PushRequestData.fromJson(getValue("pushRequestData"));
    } else {
      pushRequestData = PushRequestData();
      //print("new PushRequestData");
    }
    _context = context;

    var isFirstStart = !hasValue("isFirstStart");
    if (!isFirstStart) {
      var isOrganic = getValue("Organic");
      if (!isOrganic) {
        Map<String, dynamic> conversion = getValue("conversionData");
        if (kDebugMode) {
          print(conversion);
        }
        receivedUrl = await makeConversion(conversion);
        if (PushRequestControl.shouldShowPushRequest(pushRequestData!)) {
          Navigator.pushAndRemoveUntil(
            _context!,
            MaterialPageRoute(builder: (context) => const PushRequestScreen()),
            (route) => false,
          );
        } else {
          final initialMessage =
              await FirebaseMessaging.instance.getInitialMessage();
          if (initialMessage != null) {
            _onMessageOpenedApp(initialMessage);
          }
          FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);
          FirebaseMessaging.onBackgroundMessage(
            _firebaseMessagingBackgroundHandler,
          );
          showWeb(context);
        }
      } else {
        showApp(context);
      }
      return;
    }

    // First launch: start AppsFlyer to get conversion data and navigate.
    initAppsFlyer();
  }

  static Future<void> _firebaseMessagingBackgroundHandler(
    RemoteMessage message,
  ) async {
    print("push url" + message.data['url']);
    SdkInitializer.pushURL = message.data['url'];
  }

  static void _onMessageOpenedApp(RemoteMessage message) {
    if (kDebugMode) {
      print(
        '1 Notification caused the app to open: ${message.data.toString()}',
      );
    }
    SdkInitializer.pushURL = message.data['url'];
    EventBus.instance.fire(message.data['url']);
    // TODO: Add navigation or specific handling based on message data
  }

  static Future<String> makeConversion(
    Map<String, dynamic> conversionMap, {
    String? apnsToken,
    bool isLoad = true,
  }) async {
    conversionMap.addEntries([
      MapEntry("store_id", "id" + AppConfig.appsFlyerAppId),
      MapEntry("bundle_id", AppConfig.bundleId),
      MapEntry("locale", AppConfig.locale),
      MapEntry("os", AppConfig.os),
      MapEntry("firebase_project_id", DefaultFirebaseOptions.ios.projectId),
    ]);

    if (apnsToken != null) {
      conversionMap.addEntries([MapEntry("push_token", apnsToken)]);
    }
    //print(conversionMap);
    var result = await sendPostRequest(
      body: conversionMap,
      url: AppConfig.endpoint + "/config.php",
    );

    // if (isLoad) {
    //   onEndRequest(result);
    // }
    if (result == null) return "";
    setValue('serverResponse', result);

    if (!result.containsKey("url")) return "";

    return result['url'];
  }

  static void onEndRequest(String? url) {
    if (url == null || url == "") {
      if (kDebugMode) {
        print('not url');
      }
      setValue("Organic", true);
      setValue("isFirstStart", true);

      showApp(_context!);

      return;
    }
    setValue("Organic", false);
    setValue("isFirstStart", true);

    // Save full server response
    setValue('serverResponse', url);

    //print(mapToJsonString(map));

    // print("url: " + url);

    // Save received URL to storage
    receivedUrl = url;
    setValue('urlReceivedAt', DateTime.now().toIso8601String());
    if (kDebugMode) {
      print('url');
    }

    if (PushRequestControl.shouldShowPushRequest(pushRequestData!)) {
      if (kDebugMode) {
        print('url1');
      }
      Navigator.pushAndRemoveUntil(
        _context!,
        MaterialPageRoute(builder: (context) => const PushRequestScreen()),
        (route) => false,
      );
    } else {
      if (kDebugMode) {
        print('url2');
      }
      Navigator.push(
        _context!,
        MaterialPageRoute(builder: (context) => const WebViewScreen()),
      );
    }
  }

  static bool isHasConversion = false;
  static void initAppsFlyer() {
    final AppsFlyerOptions options = AppsFlyerOptions(
      afDevKey: AppConfig.appsFlyerDevKey,
      appId: AppConfig.appsFlyerAppId,
      showDebug: true,
      timeToWaitForATTUserAuthorization: 15,
      manualStart: true,
    );
    _appsflyerSdk = AppsflyerSdk(options);
    // App open attribution callback
    if (kDebugMode) {
      print('add af');
    }
    _appsflyerSdk!.onAppOpenAttribution((res) {
      if (kDebugMode) {
        print("onAppOpenAttribution res: $res");
      }
    });
    _appsflyerSdk!.setOneLinkCustomDomain(['']);
    // Deep linking callback
    _appsflyerSdk!.onDeepLinking((DeepLinkResult dp) {
      switch (dp.status) {
        case Status.FOUND:
          if (kDebugMode) {
            print(dp.deepLink?.toString());
          }
          if (kDebugMode) {
            print("onDeepLinking res: $dp");
          }

          var map = dp.deepLink!.clickEvent;
          //_convrtsion.addEntries(map as Iterable<MapEntry<String, dynamic>>);
          _convrtsion.addAll(map);
          if (kDebugMode) {
            print(
              'deep_link_value=$deep_link_value deep_link_sub1=$deep_link_sub1|',
            );
          }
          break;
        case Status.NOT_FOUND:
          if (kDebugMode) {
            print("deep link not found");
          }
          break;
        case Status.ERROR:
          if (kDebugMode) {
            print("deep link error: ${dp.error}");
          }
          break;
        case Status.PARSE_ERROR:
          if (kDebugMode) {
            print("deep link status parsing error");
          }
          break;
      }
      if (kDebugMode) {
        print("onDeepLinking res: $dp");
      }
    });

    _appsflyerSdk
        ?.initSdk(
      registerConversionDataCallback: true,
      registerOnAppOpenAttributionCallback: true,
      registerOnDeepLinkingCallback: true,
    )
        .then((value) {
      if (kDebugMode) {
        print('_appsflyerSdk initSdk');
      }

      // _appsflyerSdk!
      //     .onDeepLinking((DeepLinkResult dl) => (DeepLinkResult dl) {

      //     });
      _appsflyerSdk?.onInstallConversionData((res) {
        if (isHasConversion) return;
        isHasConversion = true;
        _appsflyerSdk?.getAppsFlyerUID().then((value) async {
          if (value == null) return;
          Map<String, dynamic> conversionMap = res["payload"];

          if (kDebugMode) {
            print("start load conversion 1");
          }
          if (kDebugMode) {
            print("af_sub2: ${conversionMap['af_sub1']}");
          }

          if (kDebugMode) {
            print(_convrtsion);
          }
          if (kDebugMode) {
            print("start load conversion 2");
          }

          if (kDebugMode) {
            print(conversionMap);
          }

          if (kDebugMode) {
            print("start load conversion 3");
          }

          for (var entry in conversionMap.entries) {
            //if (_convrtsion.containsKey(entry.key)) continue;
            if (entry.value != '') {
              _convrtsion[entry.key] = entry.value;

              if (kDebugMode) {
                print(
                  '|${entry.key} - ${entry.value} |${_convrtsion[entry.key]}',
                );
              }
            }
          }

          // _convrtsion.addAll(conversionMap);
          // _convrtsion
          //     .addEntries(conversionMap as Iterable<MapEntry<String, dynamic>>);
          if (_convrtsion != null) {
            _convrtsion.addEntries([MapEntry("af_id", value)]);

            setValue('conversionData', _convrtsion);
            var url = await makeConversion(_convrtsion);
            if (kDebugMode) {
              print("url -" + url);
            }
            onEndRequest(url);
          }
        });

        // if (res is Map<dynamic, dynamic>) {
        //    Map<String, dynamic>? conversionMap =(res as Map<dynamic, dynamic>)["asd"];
        // }
      });
      // Starting the SDK with optional success and error callbacks
      _appsflyerSdk?.startSDK(
        onSuccess: () {
          if (kDebugMode) {
            print("AppsFlyer SDK initialized successfully.");
          }
        },
        onError: (int errorCode, String errorMessage) {
          if (kDebugMode) {
            print(options.afDevKey + " " + options.appId);
          }
          if (kDebugMode) {
            print(
              "Error initializing AppsFlyer SDK: Code $errorCode - $errorMessage",
            );
          }
        },
      );
    });
    // Initialization of the AppsFlyer SDK

    // Starting the SDK with optional success and error callbacks
    // AppsFlyerOptions appsFlyerOptions = AppsFlyerOptions(
    //   afDevKey: 'zvxjwZLB7ErfKkprZ9BueZ',
    //   appId: AppConfig.appsFlyerAppId,
    // ); // Optional field

    // _appsflyerSdk = AppsflyerSdk(appsFlyerOptions);
    // _appsflyerSdk!.startSDK(
    //   onSuccess: () {
    //     print("AppsFlyer SDK initialized successfully.");
    //   },
    //   onError: (int errorCode, String errorMessage) {
    //     print(
    //       "Error initializing AppsFlyer SDK: Code $errorCode - $errorMessage",
    //     );
    //   },
    // );
  }

  /// Requests APNS token via FirebaseMessaging
  static Future<String?> requestAPNSToken() async {
    try {
      // Request push notification permission (required on iOS)
      await FirebaseMessaging.instance.requestPermission();

      // Ensure FCM token is obtained (triggers APNS token on iOS)
      var token = await FirebaseMessaging.instance.getAPNSToken();
      if (kDebugMode) {
        print("first token");
      }
      if (kDebugMode) {
        print(token);
      }
      if (kDebugMode) {
        print(DefaultFirebaseOptions.currentPlatform.projectId);
      }
      String? apnsToken;
      int retries = 10;
      // Wait for APNS token to become available
      for (int i = 0; i < retries; i++) {
        apnsToken = await FirebaseMessaging.instance.getAPNSToken();
        if (apnsToken != null && apnsToken.isNotEmpty) {
          if (kDebugMode) {
            print('APNS token received: $apnsToken');
          }
          return apnsToken;
        }
        await Future.delayed(const Duration(milliseconds: 500));
      }
      if (kDebugMode) {
        print('APNS token not received (timeout)');
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting APNS token: $e');
      }
      return null;
    }
  }

  static bool isIOSSimulator() {
    return false;
    if (!Platform.isIOS) return false;

    // Check simulator environment variables
    return Platform.environment.containsKey('SIMULATOR_DEVICE_NAME') ||
        Platform.environment.containsKey('SIMULATOR_HOST_HOME') ||
        Platform.environment.containsKey('SIMULATOR_UDID');
  }

  static Future<void> pushRequest(BuildContext context) async {
    await Firebase.initializeApp();

    // User tapped "Yes" on our custom screen — now request ATT first,
    // then the system push notification permission.
    await _requestATT();

    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    if (kDebugMode) {
      print('Push permission status: ${settings.authorizationStatus}');
    }

    var token = await FirebaseMessagingService.InitPushAndGetToken();
    if (token == null) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const WebViewScreen()),
        (route) => false,
      );
      return;
    }

    PushRequestControl.acceptPushRequest(pushRequestData!);

    setValue("pushRequestData", pushRequestData?.toJson());
    _convrtsion = SdkInitializer.getValue('conversionData');
    if (_convrtsion is Map<String, dynamic>) {
      if (kDebugMode) {
        print("makeConversion 2");
      }
      var url = await SdkInitializer.secondMakeConversion(
        _convrtsion,
        apnsToken: token,
        isLoad: false,
      );
      setValue(url, "receivedUrl");
      if (kDebugMode) {
        print("pushRequest ");
      }
      _runtimeStorage['receivedUrl'] = url;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const WebViewScreen()),
        (route) => false,
      );
    }
  }

  static Future<String> secondMakeConversion(
    Map<String, dynamic> conversionMap, {
    String? apnsToken,
    bool isLoad = true,
  }) async {
    conversionMap.addEntries([MapEntry("push_token", apnsToken)]);

    if (kDebugMode) {
      print(conversionMap["firebase_project_id"]);
    }

    if (kDebugMode) {
      print("with token " + conversionMap.toString());
    }
    setValue("", conversionMap);
    var result = await sendPostRequest(
      body: conversionMap,
      url: AppConfig.endpoint + "/config.php",
    );

    // if (isLoad) {
    //   onEndRequest(result);
    // }
    if (result == null) return "";
    setValue('serverResponse', result);
    if (!result.containsKey("url")) return "";
    return result['url'];
  }

  static void pushRequestDecline() {
    PushRequestControl.declinePushRequest(pushRequestData!);
    setValue("pushRequestData", pushRequestData?.toJson());
  }
}

Map<String, dynamic> parseJsonFromString(String jsonString) {
  if (kDebugMode) {
    print("1 " + jsonString);
  }
  String cleanedString = jsonString.trim();
  if (kDebugMode) {
    print("2 " + cleanedString);
  }
  // Parse JSON string into Map
  Map<String, dynamic> jsonMap = jsonDecode(cleanedString);

  // print("3 " + jsonMap.length.toString());
  return jsonMap;
}

String mapToJsonString(Map<String, dynamic> map) {
  try {
    // Convert Map to JSON string with formatting
    String jsonString = json.encode(map);
    return jsonString;
  } catch (e) {
    if (kDebugMode) {
      print('Error converting to JSON: $e');
    }
    return '{}';
  }
}

Future<Map<String, dynamic>?> sendPostRequest({
  required String url,
  required Map<String, dynamic> body,
  Map<String, String>? headers,
  Duration timeout = const Duration(seconds: 30),
}) async {
  if (kDebugMode) {
    print(body);
  }
  try {
    // Prepare headers
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      ...?headers,
    };

    // Send POST request
    http.Response response = await http
        .post(Uri.parse(url), headers: requestHeaders, body: json.encode(body))
        .timeout(timeout);

    // Check response status
    if (response.statusCode >= 200 && response.statusCode < 300) {
      // Success response
      Map<String, dynamic> result = json.decode(response.body);
      return result;
    } else {
      // HTTP error
      if (kDebugMode) {
        print('HTTP Error: ${response.statusCode} - ${response.body}');
      }
      return null;
    }
  } catch (e) {
    if (kDebugMode) {
      print('Request error: $e');
    }
    return null;
  }
}

class EventBus {
  // Event controller
  final _controller = StreamController<dynamic>.broadcast();

  // Singleton instance
  static final EventBus instance = EventBus();

  // Private constructor (if you want to prevent instantiation)
  // EventBus._(); // or just don't declare a public constructor

  // Event stream
  Stream<dynamic> get events => _controller.stream;

  // Emit event
  void fire(dynamic event) {
    print(event);
    _controller.add(event);
  }

  // Dispose
  void dispose() {
    _controller.close();
  }
}
