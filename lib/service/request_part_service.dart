import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

import '../model/ticket/response_model.dart';
import '../utils/api_url.dart';

class RequestPartService {
  static Future<ResponseModel> getSubProducts() async {
    final uri = Uri.parse(
      '${ApiUrl.baseUrl}ddl/FillDDLParam'
      '?ParamName=in_product_category_id'
      '&ParamValue=10'
      '&StoredProcedure=ddl_subProduct',
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
        return ResponseModel.fromJson(data);
      } else {
        log('⚠️ [SubProduct Error] Invalid status: ${response.statusCode}');
        return ResponseModel.fromJson({});
      }
    } catch (e, stack) {
      log('❌ [SubProduct Exception] $e');
      log("$stack");
      return ResponseModel.fromJson({});
    }
  }

  static Future<ResponseModel> getContentBySubProduct(int subProductId) async {
    final uri = Uri.parse(
      '${ApiUrl.baseUrl}ddl/FillDDL2Param'
          '?ParamName1=in_sub_product_id'
          '&ParamValue1=$subProductId'
          '&ParamName2=in_type'
          '&ParamValue2=1'
          '&StoredProcedure=ddl_ContentBySubProduct',
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
        return ResponseModel.fromJson(data);
      } else {
        log('⚠️ [Content Error] Invalid status: ${response.statusCode}');
        return ResponseModel.fromJson({});
      }
    } catch (e, stack) {
      log('❌ [Content Exception] $e');
      log("$stack");
      return ResponseModel.fromJson({});
    }
  }

  static Future<ResponseModel> getEmployee() async {
    final uri = Uri.parse(
      '${ApiUrl.baseUrl}ddl/FillDDL?StoredProcedure=ddl_ActiveServiceEng',
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
        return ResponseModel.fromJson(data);
      } else {
        log('⚠️ [Engineer Error] Invalid status: ${response.statusCode}');
        return ResponseModel.fromJson({});
      }
    } catch (e, stack) {
      log('❌ [Engineer Exception] $e');
      log("$stack");
      return ResponseModel.fromJson({});
    }
  }

  static Future<Map<String, dynamic>> sendRequest({
    required int fromEmployeeId,
    required int toEmployeeId,
    required String partNumber,
    required String description,
    required String customerName,
    required String branch,
    required int contentId,
    required int type,
  }) async {
    final uri = Uri.parse(
      '${ApiUrl.baseUrl}CustodyRequests/Insert',
    );

    final body = {
      "from_employee_id": fromEmployeeId,
      "to_emplyee_id": toEmployeeId,
      "part_number": partNumber,
      "description": description,
      "customer_name": customerName,
      "branch": branch,
      "content_id": contentId,
      "type": type,
    };

    try {
      log("➡️ [POST] $uri");
      log("📦 Body => $body");

      final response = await http.post(
        uri,
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );

      log("✅ [Response ${response.statusCode}] => ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          "status": response.statusCode,
          "message": "Server Error",
        };
      }
    } catch (e, stack) {
      log("❌ [SendRequest Exception] $e");
      log("$stack");

      return {
        "status": 500,
        "message": "Exception occurred",
      };
    }
  }


}
