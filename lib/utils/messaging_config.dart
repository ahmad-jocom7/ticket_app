import 'dart:developer';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_app_badge_control/flutter_app_badge_control.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'my_shared_preferences.dart';

class MessagingConfig {
  static String clickAction = '';
  static AndroidNotificationChannel channel = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description: 'This channel is used for important notifications.',
    // description
    importance: Importance.max,
  );
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    await Firebase.initializeApp();
    if (Platform.isIOS) {
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
    }
    if (Platform.isAndroid) {
      mySharedPreferences.isGMS = true;
    } else {
      mySharedPreferences.isGMS = true;
    }
    log('isGMS : ${mySharedPreferences.isGMS}');
    if (mySharedPreferences.isGMS) {
      await FirebaseMessagingConfig.init();
    } else {
      await FirebaseMessagingConfig.init();
    }
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    log('Device token : ${mySharedPreferences.deviceToken}');
  }
}

class FirebaseMessagingConfig {
  static Future<void> init() async {
    mySharedPreferences.deviceToken =
        await FirebaseMessaging.instance.getToken() ?? '';
    if (await FlutterAppBadgeControl.isAppBadgeSupported()) {
      FlutterAppBadgeControl.removeBadge();
    }
    // FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    await MessagingConfig.flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(MessagingConfig.channel);
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
    var initialNotification = await FirebaseMessaging.instance
        .getInitialMessage();
    if (initialNotification != null) {
      MessagingConfig.clickAction =
          initialNotification.data['click_action'] ?? '';
    }
    onMessage();
  }

  static void onMessage() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      if (message != null) {

      }
      MessagingConfig.clickAction = message.data['click_action'] ?? '';
    });

    FirebaseMessaging.instance.getInitialMessage().then((message) async {
      if (message != null) {

      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print("📩 message.data: ${message.data}");


      RemoteNotification? notification = message.notification;
      AndroidNotification? android = notification?.android;
      AppleNotification? apple = notification?.apple;

      if (notification == null || kIsWeb) return;

      String? imageUrl =
          android?.imageUrl ?? apple?.imageUrl ?? message.data['image'];

      BigPictureStyleInformation? bigPictureStyle; // Android
      DarwinNotificationAttachment? iOSAttachment; // iOS


      final details = NotificationDetails(
        android: AndroidNotificationDetails(
          MessagingConfig.channel.id,
          MessagingConfig.channel.name,
          channelDescription: MessagingConfig.channel.description,
          styleInformation: bigPictureStyle,
          icon: '@mipmap/ic_launcher',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          attachments: iOSAttachment != null ? [iOSAttachment] : null,
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );

      await MessagingConfig.flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        details,
        payload:
            "https://www.google.com/maps/dir/${message.data["from_latlong"]}/${message.data["to_latlong"]}",
      );
    });
  }
}
