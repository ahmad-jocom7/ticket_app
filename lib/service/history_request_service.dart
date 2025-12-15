import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

import '../model/delivery_request/request_model.dart';
import '../utils/api_url.dart';
import '../utils/my_shared_preferences.dart';

class HistoryRequestService {
  static Future<RequestModel?> getHistoryRequests(int status) async {
    final employeeId = mySharedPreferences.getUserData()!.employeeId;

    final uri = Uri.parse(
      "${ApiUrl.baseUrl}CustodyRequests/GetCustodyRequests"
      "?to_employeeId=0"
      "&from_employeeId=$employeeId"
      "&status=$status"
      "&type=1"
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
      log("🔥 Exception in getHistoryRequests: $e");
      log("$stack");
      return null;
    }
  }

  static Future<bool> updateCustodyRequest({
    required int id,
    required String partNumber,
    required String description,
    required String customerName,
    required String branch,
    required int contentId,
    required String updateDate, // dd/MM/yyyy
  }) async {
    final uri = Uri.parse(
      "${ApiUrl.baseUrl}CustodyRequests/Update",
    );

    final body = {
      "id": id,
      "part_number": partNumber,
      "description": description,
      "customer_name": customerName,
      "branch": branch,
      "content_id": contentId,
      "update_date": updateDate,
    };

    try {
      log("➡️ [PUT] $uri");
      log("📤 Body => ${jsonEncode(body)}");

      final response = await http.put(
        uri,
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );

      log("📥 [Response ${response.statusCode}] => ${response.body}");

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        return json["status"] == 200;
      } else {
        log("❌ Update failed with status code ${response.statusCode}");
        return false;
      }
    } catch (e, stack) {
      log("🔥 Exception in updateCustodyRequest: $e");
      log("$stack");
      return false;
    }
  }

}
