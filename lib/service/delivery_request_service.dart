import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

import '../model/delivery_request/request_model.dart';
import '../utils/api_url.dart';
import '../utils/my_shared_preferences.dart';

class DeliveryRequestService {
  static Future<RequestModel?> getDeliveryRequests() async {
    final employeeId = mySharedPreferences.getUserData()!.employeeId;

    final uri = Uri.parse(
      "${ApiUrl.baseUrl}CustodyRequests/GetCustodyRequests"
      "?from_employeeId=0"
      "&to_employeeId=$employeeId"
      "&status=0"
      "&type=2 "
      "&fromDate=0"
      "&toDate=0",
    );

    try {
      log("➡️ [GET] $uri");

      final response = await http.get(
        uri,
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
      );

      log("📥 [Response ${response.statusCode}] => ${response.body}");

      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body);
        return RequestModel.fromJson(jsonBody);
      } else {
        log("❌ Invalid status code: ${response.statusCode}");
        return null;
      }
    } catch (e, stack) {
      log("🔥 Exception in getDeliveryRequests: $e");
      log("$stack");
      return null;
    }
  }

  static Future<bool> updateDeliveryRequest({
    required int id,
    required int status,
    String rejectReason = "",
  }) async {
    final uri = Uri.parse(
      "${ApiUrl.baseUrl}CustodyRequests/ActionDeliveryRequest",
    );

    final body = jsonEncode({
      "id": id,
      "status": status,
      "reject_reason": rejectReason,
    });

    try {
      log("➡️ [PUT] $uri");
      log("📤 Body: $body");

      final response = await http.put(
        uri,
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: body,
      );

      log("📥 [Response ${response.statusCode}] => ${response.body}");

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        if (json["status"] == 200) {
          return true;
        }
      }

      return false;
    } catch (e, stack) {
      log("🔥 Exception in updateDeliveryRequest: $e");
      log("$stack");
      return false;
    }
  }
}
