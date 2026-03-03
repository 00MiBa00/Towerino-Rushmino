import 'package:flutter/foundation.dart';

class PushRequestData {
  bool? pushNotificationAccepted;
  String? pushDeclinedAt;
  bool? firstLaunch;

  void Print() {
    if (kDebugMode) {
      print(' pushNotificationAccepted=${pushNotificationAccepted} \n' +
          'pushDeclinedAt=${pushDeclinedAt}');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'pushNotificationAccepted': pushNotificationAccepted,
      'pushDeclinedAt': pushDeclinedAt,
      'firstLaunch': firstLaunch,
    };
  }

  PushRequestData(
      {this.pushNotificationAccepted, this.pushDeclinedAt, this.firstLaunch});

  factory PushRequestData.fromJson(Map<String, dynamic> json) {
    // var data = PushRequestData();
    // if (json.containsKey('firstLaunch')) {
    //   data.firstLaunch = json['firstLaunch'];
    // }
    var data = PushRequestData(
      pushNotificationAccepted: json['pushNotificationAccepted'],
      pushDeclinedAt: json['pushDeclinedAt'],
      firstLaunch: json['firstLaunch'],
    );
    data.Print();
    return data;
  }
}

class PushRequestControl {
  static bool isDebug = kDebugMode;

  static bool shouldShowPushRequest(PushRequestData data) {
    // Check whether notification consent was granted
    final pushAccepted = data.pushNotificationAccepted;
    final firstDeclinedAt = data.pushDeclinedAt;

    // If the user already granted consent, do not show the prompt
    if (pushAccepted == true) {
      if (isDebug) print("pushAccepted == true");
      return false;
    }

    // If consent was not granted and no decline was recorded, show the prompt
    if (pushAccepted == null && (firstDeclinedAt == null || firstDeclinedAt.isEmpty)) {
      if (isDebug) print("pushAccepted == null && firstDeclinedAt == null/empty");
      return true;
    }

    // If declined — check whether 3 days have passed since last decline
    final declinedAtStr = firstDeclinedAt ?? "";
    if (declinedAtStr.isNotEmpty) {
      if (isDebug) print("checking 3-day cooldown, declinedAt=$declinedAtStr");
      DateTime declinedAt;
      try {
        declinedAt = DateTime.parse(declinedAtStr);
      } catch (e) {
        if (isDebug) print("parse error — show screen");
        return true;
      }
      final daysPassed = DateTime.now().difference(declinedAt).inDays;
      if (isDebug) print("daysPassed=$daysPassed");
      return daysPassed >= 3;
    }

    // Other cases: do not show the prompt
    return false;
  }

  // Save the user's consent for push notifications
  static void acceptPushRequest(PushRequestData data) async {
    data.pushNotificationAccepted = true;
    data.pushDeclinedAt = "";
    if (isDebug) {
      print('pushNotificationAccepted \n'
              'pushNotificationAccepted=${data.pushNotificationAccepted} \n' +
          'pushDeclinedAt=${data.pushDeclinedAt}');
    }
  }

  // Save the user's decline for push notifications
  static void declinePushRequest(PushRequestData data, [DateTime? date]) {
    date ??= DateTime.now(); //.subtract(const Duration(days: 4));
    data.pushNotificationAccepted = false;
    data.pushDeclinedAt = date.toIso8601String();
    if (isDebug) {
      print('pushNotificationDecline \n' +
          'date=$date \n' +
          'pushNotificationAccepted=${data.pushNotificationAccepted} \n' +
          'pushDeclinedAt=${data.pushDeclinedAt}\n');
    }
  }
}
