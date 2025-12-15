import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ticket_app/utils/my_shared_preferences.dart';
import 'package:ticket_app/ui/splash_screen.dart';
import 'package:ticket_app/utils/theme_app.dart';

import 'controller/theme_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await mySharedPreferences.init();
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

        // 🌞 Light Theme
        theme: themeApp,

        // 🌙 Dark Theme
        darkTheme: darkThemeApp,

        // 👈 التحكم من الكنترولر
        themeMode:
        themeController.isDark.value ? ThemeMode.dark : ThemeMode.light,

        home: SplashScreen(),
      );
    });
  }
}
