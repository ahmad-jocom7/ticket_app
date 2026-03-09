import 'dart:developer';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ticket_app/service/auth_service.dart';
import 'package:ticket_app/utils/messaging_config.dart';
import 'package:ticket_app/utils/my_shared_preferences.dart';
import 'package:ticket_app/ui/splash_screen.dart';
import 'package:ticket_app/utils/theme_app.dart';

import 'controller/theme_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await mySharedPreferences.init();

  HttpOverrides.global = MyHttpOverrides();
  await T.initNotificationsAndFirebase();
  MessagingConfig.init();
  Get.put(ThemeController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();

    return Obx(() {
      return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Ticket App',
        theme: themeApp,
        darkTheme: darkThemeApp,
        themeMode: themeController.isDark.value
            ? ThemeMode.dark
            : ThemeMode.light,
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(1.1)),
            child: child!,
          );
        },
        home: SplashScreen(),
      );
    });
  }
}

class T {
  static Future<void> initNotificationsAndFirebase() async {
    await Permission.notification.isDenied.then((value) {
      if (value) {
        Permission.notification.request();
      }
    });

    try {
      await Firebase.initializeApp();

      String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
      if (apnsToken != null) {
        log('APNS Token: $apnsToken');
      } else {
        log('APNS token is null');
      }

      String? fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) {
        mySharedPreferences.deviceToken = fcmToken;
        log('FCM Token: ${mySharedPreferences.deviceToken}');
      } else {
        log('FCM token is null');
      }
    } catch (e) {
      log('Error initializing Firebase: $e');
    }
  }
}
