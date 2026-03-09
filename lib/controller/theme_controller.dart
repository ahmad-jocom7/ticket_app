import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ticket_app/utils/my_shared_preferences.dart';

class ThemeController extends GetxController {
  final isDark = false.obs;

  @override
  void onInit() {
    isDark.value = mySharedPreferences.isDark;
    super.onInit();
  }

  void toggleTheme(bool value) {
    isDark.value = value;
    mySharedPreferences.isDark = value;
    Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
  }
}
