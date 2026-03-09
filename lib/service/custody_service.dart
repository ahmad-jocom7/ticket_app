import 'dart:convert';
import 'dart:developer';

import 'package:ticket_app/model/custody/custody_model.dart';
import 'package:ticket_app/utils/my_shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../utils/api_url.dart';

class CustodyService {
  static Future<CustodyModel> getCustody() async {
    final uri = Uri.parse(
      '${ApiUrl.baseUrl}Custody/Get'
      '?employeeId=${mySharedPreferences.getUserData()!.employeeId}',
    );
    try {
      log('➡️ [GET] $uri');

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );
      log('✅ [Response ${response.statusCode}] => ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return CustodyModel.fromJson(data);
      } else {
        log('⚠️ [SubProduct Error] Invalid status: ${response.statusCode}');
        return CustodyModel.fromJson({});
      }
    } catch (e, stack) {
      log('❌ [SubProduct Exception] $e');
      log("$stack");
      return CustodyModel.fromJson({});
    }
  }

  static Future<bool> sendDeliveryRequest({
    required int custodyId,
    required int toEmployee,
    required String description,
  }) async {
    final uri = Uri.parse(
      '${ApiUrl.baseUrl}CustodyRequests/SendDeliveryRequest',
    );

    try {
      log('➡️ [POST] $uri');

      final response = await http.post(
        uri,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "toEmployee": toEmployee,
          "custodyId": custodyId,
          "description": description,
        }),
      );

      log('✅ [Response ${response.statusCode}] => ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['status'] == 200;
      } else {
        log(
          '⚠️ [SendDeliveryRequest Error] Invalid status: ${response.statusCode}',
        );
        return false;
      }
    } catch (e, stack) {
      log('❌ [SendDeliveryRequest Exception] $e');
      log('$stack');
      return false;
    }
  }
}
