import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ticket_app/utils/color_app.dart';
import '../utils/text_style.dart';
import '../controller/main_controller.dart';
import '../widgets/exit_dialog.dart';

class NavBarScreen extends StatelessWidget {
  NavBarScreen({super.key});

  final controller = MainController.to;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MainController>(
      builder: (context) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) return;
            if (controller.selected == 1) {
              controller.onTap(0);
              return;
            }
            final shouldExit = await showExitDialog();

            if (shouldExit == true) {
              SystemNavigator.pop();
            }
          },
          child: Scaffold(
            body: controller.screen[controller.selected],
            bottomNavigationBar: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: BottomNavigationBar(
                backgroundColor: Colors.white,
                currentIndex: controller.selected,
                type: BottomNavigationBarType.fixed,
                elevation: 8,
                selectedItemColor: ColorApp.primary,
                unselectedItemColor: const Color(0xffA0A0A0),
                selectedLabelStyle: semibold12.copyWith(
                  fontSize: 13,
                  color: ColorApp.primary,
                ),
                unselectedLabelStyle: semibold12.copyWith(fontSize: 12),
                selectedIconTheme: IconThemeData(
                  color: ColorApp.primary,
                  size: 26,
                ),
                unselectedIconTheme: const IconThemeData(size: 24),
                onTap: controller.onTap,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.space_dashboard_outlined),
                    activeIcon: Icon(Icons.space_dashboard_rounded),
                    label: 'Dashboard',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.manage_accounts_outlined),
                    activeIcon: Icon(Icons.manage_accounts_rounded),
                    label: 'Menu',
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
