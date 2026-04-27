import 'dart:async';
import 'dart:ui';

import 'package:get/get.dart';
import 'package:ticket_app/ui/nav_bar_screen.dart';
import 'package:ticket_app/utils/my_shared_preferences.dart';

import '../model/auth/login_model.dart';
import '../service/auth_service.dart';

class LoginController extends GetxController {
  final isLoading = false.obs;
  final isSlowConnection = false.obs;
  final errorMessage = ''.obs;
  final statusMessage = ''.obs;

  Rx<LoginResponse?> loginResponse = Rx<LoginResponse?>(null);

  int _loginRequestId = 0;

  Future<void> login({
    required String username,
    required String password,
  }) async {
    final requestId = ++_loginRequestId;

    try {
      isLoading(true);
      isSlowConnection(false);
      errorMessage('');
      statusMessage('Signing you in...');

      Future.delayed(const Duration(seconds: 4), () {
        if (_loginRequestId == requestId && isLoading.value) {
          isSlowConnection(true);
          statusMessage(
            'The connection is slower than usual. We are still trying...',
          );
        }
      });

      final response = await AuthService.login(
        username: username,
        password: password,
      );

      if (_loginRequestId != requestId) {
        return;
      }

      if (response != null && response.status == 200 && response.user != null) {
        loginResponse.value = response;

        final user = response.user!;
        mySharedPreferences.saveUserData(user);
        mySharedPreferences.isLogin = true;
        statusMessage('');
        Get.offAll(() => NavBarScreen());
      } else {
        final message = response?.message.isNotEmpty == true
            ? response!.message
            : 'Invalid credentials, please try again.';

        errorMessage(message);
        statusMessage('');
        Get.snackbar(
          'Login Failed',
          message,
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFFFFE0E0),
          colorText: const  Color(0xFF5A0000),
        );
      }
    } catch (e) {
      if (_loginRequestId != requestId) {
        return;
      }

      errorMessage('Something went wrong while logging in.');
      statusMessage('');
      Get.snackbar(
        'Error',
        'Something went wrong while logging in.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFFFE0E0),
        colorText: const Color(0xFF5A0000),
      );
    } finally {
      if (_loginRequestId == requestId) {
        isLoading(false);
        isSlowConnection(false);
      }
    }
  }
}
