import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationLocal {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  NotificationLocal() {
    var initializationSettingsAndroid =
        new AndroidInitializationSettings("@mipmap/ic_launcher");
    var initializationSettingsIos = new IOSInitializationSettings();

    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIos);

    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> sendNow(String title, String body, String payload) async {
    var androidNotificationDetails = new AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        importance: Importance.Max, priority: Priority.High, ticker: 'ticker');
    var iosNotificationDetails = new IOSNotificationDetails();
    var details =
        NotificationDetails(androidNotificationDetails, iosNotificationDetails);
    await flutterLocalNotificationsPlugin.show(0, title, body, details,
        payload: payload);
  }

  Future<void> sendDateandTime(String title, String body, DateTime time) async {
    Map<int, Day> map = {
      0: Day.Monday,
      1: Day.Tuesday,
      2: Day.Wednesday,
      3: Day.Thursday,
      4: Day.Friday,
      5: Day.Saturday,
      6: Day.Sunday,
    };

    var androidNotificationDetails = new AndroidNotificationDetails(
        'show weekly channel id',
        'show weekly channel name',
        'show weekly description',
        importance: Importance.Max,
        priority: Priority.High,
        ticker: 'ticker');
    var iosNotificationDetails = new IOSNotificationDetails();
    var details =
        NotificationDetails(androidNotificationDetails, iosNotificationDetails);
    await flutterLocalNotificationsPlugin.showWeeklyAtDayAndTime(
      Random().nextInt(20) + 1,
      title,
      body,
      map[time.day],
      Time(13, 1, 0),
      details,
    );
  }
}
