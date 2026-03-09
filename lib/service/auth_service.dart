import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../utils/api_url.dart';
import '../model/auth/login_model.dart';
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
      log('➡️ [GET] $uri');
      final response = await http.get(uri, headers: {
        'Accept': 'application/json',
      });

      log('✅ [Response ${response.statusCode}] => ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return LoginResponse.fromJson(data);
      } else {
        log('⚠️ Invalid status code: ${response.statusCode}');
        return null;
      }
    } catch (e, stack) {
      log('❌ Exception during login: $e');
      log('$stack');
      return null;
    }
  }
}
