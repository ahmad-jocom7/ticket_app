import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ticket_app/ui/home_screen.dart';

import '../ui/dashboard_home_screen.dart';

class MainController extends GetxController {
  static MainController get to => Get.isRegistered<MainController>()
      ? Get.find<MainController>()
      : Get.put(MainController());

  int selected = 0;

  void onTap(int value) {
    selected = value;
    update();
  }

  final List<Widget> screen = [DashboardHomeScreen(), HomeScreen()];
}
