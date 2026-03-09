import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ticket_app/utils/my_shared_preferences.dart';
import '../utils/color_app.dart';
import '../utils/text_style.dart'; // ✅ changed: use shared text styles
import 'login_screen.dart';
import 'nav_bar_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _controller.forward();

    Future.delayed(const Duration(seconds: 3), () {
      mySharedPreferences.isLogin == true
          ? Get.offAll(() => NavBarScreen())
          : Get.off(
            () => const LoginScreen(),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 700),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ changed: detect theme
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // ✅ changed: background from theme (supports dark/light)
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 🔹 Logo Container
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  // ✅ changed: adaptive background for logo
                  color: ColorApp.primary.withValues(
                    alpha: isDark ? 0.18 : 0.08,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Image.asset(
                  'assets/image/jocom_logo.png',
                  width: 150,
                  height: 150,
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 30),

              // 🔹 App Title
              Text(
                "JOCOM Ticketing System",
                // ✅ changed: shared text style + theme color
                style: bold20.copyWith(
                  color: ColorApp.primary,
                  letterSpacing: 0.5,
                ),
              ),

              const SizedBox(height: 40),

              // 🔹 Loading Indicator
              SizedBox(
                width: 120,
                child: LinearProgressIndicator(
                  // ✅ changed: use theme-friendly colors
                  color: ColorApp.primary,
                  backgroundColor: isDark
                      ? Colors.grey.shade700
                      : const Color(0xFFE0E0E0),
                  minHeight: 3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
