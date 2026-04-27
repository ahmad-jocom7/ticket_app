import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../model/auth/login_model.dart';
import '../utils/api_url.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class AuthService {
  static Future<LoginResponse?> login({
    required String username,
    required String password,
  }) async {
    final uri = Uri.parse(
      '${ApiUrl.baseUrl}${ApiUrl.login}?UserName=$username&UserPassword=$password&intPlatformType=1',
    );

    try {
      log('[GET] $uri');
      final response = await http
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 20));

      log('[Response ${response.statusCode}] => ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return LoginResponse.fromJson(data);
      }

      log('Invalid status code: ${response.statusCode}');
      String message = 'Unable to reach the login service right now.';

      try {
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic>) {
          final backendMessage = data['message']?.toString().trim() ?? '';
          if (backendMessage.isNotEmpty) {
            message = backendMessage;
          }
        }
      } catch (_) {}

      return LoginResponse(
        status: response.statusCode,
        message: message,
      );
    } on TimeoutException catch (e, stack) {
      log('Login timeout: $e');
      log('$stack');
      return LoginResponse(
        status: 0,
        message: 'The connection is taking too long. Please try again.',
      );
    } on SocketException catch (e, stack) {
      log('Login socket exception: $e');
      log('$stack');
      return LoginResponse(
        status: 0,
        message: 'Please check your internet connection and try again.',
      );
    } catch (e, stack) {
      log('Exception during login: $e');
      log('$stack');
      return LoginResponse(
        status: 0,
        message: 'Something went wrong while logging in. Please try again.',
      );
    }
  }
}
