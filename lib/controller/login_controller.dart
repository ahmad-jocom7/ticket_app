import 'dart:ui';

import 'package:get/get.dart';
import 'package:ticket_app/utils/my_shared_preferences.dart';
import 'package:ticket_app/ui/nav_bar_screen.dart';
import '../model/auth/login_model.dart';
import '../service/auth_service.dart';

class LoginController extends GetxController {
  /// ✅ حالة التحميل
  var isLoading = false.obs;

  var errorMessage = ''.obs;

  Rx<LoginResponse?> loginResponse = Rx<LoginResponse?>(null);

  /// 🔹 دالة تسجيل الدخول
  Future<void> login({
    required String username,
    required String password,
  }) async {
    try {
      isLoading(true);
      errorMessage('');

      final response = await AuthService.login(
        username: username,
        password: password,
      );

      if (response != null && response.status == 200) {
        loginResponse.value = response;

        final user = response.user;
        mySharedPreferences.saveUserData(user!);
        mySharedPreferences.isLogin = true;
        Get.offAll(() => NavBarScreen());
      } else {
        errorMessage(response?.message ?? 'Login failed');
        Get.snackbar(
          "Login Failed",
          response?.message ?? "Invalid credentials, please try again.",
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFFFFE0E0),
          colorText: const Color(0xFF5A0000),
        );
      }
    } catch (e) {
      errorMessage('Error: $e');
      Get.snackbar(
        "Error",
        "Something went wrong while logging in.",
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFFFE0E0),
        colorText: const Color(0xFF5A0000),
      );
    } finally {
      isLoading(false);
    }
  }
}
