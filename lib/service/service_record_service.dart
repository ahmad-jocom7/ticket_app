import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:ticket_app/utils/api_url.dart';
import 'package:ticket_app/utils/my_shared_preferences.dart';

import '../model/service_record/assign_ticket_model.dart';
import '../model/service_record/open_service_record_model.dart';
import '../model/ticket/response_model.dart';
import '../model/service_record/service_record_model.dart';

class TicketService {
  static Future<TicketResponse?> getAssignedTicketsByEmployee() async {
    final uri = Uri.parse(
      '${ApiUrl.baseUrl}${ApiUrl.getAssignedTickets}'
      '?employeeId=${mySharedPreferences.getUserData()!.employeeId}&status=0&ticketId=0&fromDate=0&toDate=0',
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
        return TicketResponse.fromJson(data);
      } else {
        log('⚠️ [Error] Invalid status: ${response.statusCode}');
        return null;
      }
    } catch (e, stack) {
      log('❌ [Exception] $e');
      log('$stack');
      return null;
    }
  }

  static Future<TicketResponse?> getAcceptedTicketsByEmployee() async {
    final uri = Uri.parse(
      '${ApiUrl.baseUrl}${ApiUrl.getAcceptedTickets}'
      '?employeeId=${mySharedPreferences.getUserData()!.employeeId}&status=3&ticketId=0&fromDate=0&toDate=0',
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
        return TicketResponse.fromJson(data);
      } else {
        log('⚠️ [Error] Invalid status: ${response.statusCode}');
        return null;
      }
    } catch (e, stack) {
      log('❌ [Exception] $e');
      log('$stack');
      return null;
    }
  }

  static Future<bool> updateAssignTicket({
    required int intId,
    required int status,
    required int intAccept,
    String? rejectNote,
  }) async {
    final uri = Uri.parse('${ApiUrl.baseUrl}${ApiUrl.updateAssignTicket}');

    final body = jsonEncode({
      'intId': intId,
      'status': status,
      'intAccept': intAccept,
      if (rejectNote != null) 'rejectNote': rejectNote,
    });

    try {
      log('➡️ [POST] $uri');
      log('📦 Body => $body');

      final response = await http.post(
        uri,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: body,
      );

      log('✅ [Response ${response.statusCode}] => ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 200) {
          return true;
        }
      }

      return false;
    } catch (e, stack) {
      log('❌ [Exception] $e');
      log('$stack');
      return false;
    }
  }

  static Future<OpenServiceRecordModel> openServiceRecord({
    required int ticketId,
  }) async {
    final uri = Uri.parse('${ApiUrl.baseUrl}${ApiUrl.openServiceRecord}');

    final body = jsonEncode({'intTicketId': ticketId, 'intEmployeeId': mySharedPreferences.getUserData()!.employeeId});

    try {
      log('➡️ [POST] $uri');
      log('📦 Body: $body');

      final response = await http.post(
        uri,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: body,
      );

      log('✅ [Response ${response.statusCode}] => ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return OpenServiceRecordModel.fromJson(data);
      } else {
        log('⚠️ [InsertTicket Error] Invalid status: ${response.statusCode}');
        return OpenServiceRecordModel.fromJson({});
      }
    } catch (e, stack) {
      log('❌ [InsertTicket Exception] $e');
      log("$stack");
      return OpenServiceRecordModel.fromJson({});
    }
  }

  static Future<bool> closeServiceRecord({
    required int serviceRecordId,
    required int ticketId,
    // required int solution,
    required String repairNote,
    required int serviceResult,
    int? unsolvedReasonId,
    String? unsolvedNote,
    required String tripTime,
    required String clientSignature,
    required String signatureName,
  }) async {
    final uri = Uri.parse('${ApiUrl.baseUrl}${ApiUrl.closeServiceRecord}');

    final body = jsonEncode({
      "intServiceRecordId": serviceRecordId,
      "intTicketId": ticketId,
      "intEmployeeId": mySharedPreferences.getUserData()!.employeeId,
      "intSolution": 0,
      "strRepairNote": repairNote,
      "intServiceResult": serviceResult,
      if (unsolvedReasonId != 0) "intUnsolvedReasonId": unsolvedReasonId,
      if (unsolvedNote!.isNotEmpty) "strUnsolvedNote": unsolvedNote,
      "strTripTime": tripTime,
      "bytClientSig": clientSignature,
      "signature_name": signatureName,
    });

    try {
      log('➡️ [POST] $uri');
      log('📦 Body: $body');

      final response = await http.post(
        uri,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: body,
      );

      log('✅ [Response ${response.statusCode}] => ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Assuming the API returns {"status":200} or {"success":true}
        if ((data['status'] == 200) || (data['success'] == true)) {
          log('✅ Service record closed successfully.');
          return true;
        } else {
          log(
            '⚠️ [CloseServiceRecord] Unexpected response: ${data.toString()}',
          );
          return false;
        }
      } else {
        log(
          '⚠️ [CloseServiceRecord Error] Invalid status: ${response.statusCode}',
        );
        return false;
      }
    } catch (e, stack) {
      log('❌ [CloseServiceRecord Exception] $e');
      log('$stack');
      return false;
    }
  }

  static Future<ResponseModel> getHardwareContent(int subProductFileId) async {
    final uri = Uri.parse(
      '${ApiUrl.baseUrl}${ApiUrl.getHardwareContent}?ParamName=in_sub_product_file_id&ParamValue=$subProductFileId&StoredProcedure=ddl_hardwareContentInstall',
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
        log('⚠️ [DeviceRef Error] Invalid status: ${response.statusCode}');
        return ResponseModel.fromJson({});
      }
    } catch (e, stack) {
      log('❌ [DeviceRef Exception] $e');
      log("$stack");
      return ResponseModel.fromJson({});
    }
  }

  static Future<ResponseModel> getUnsolvedReason(int subProductFileId) async {
    final uri = Uri.parse(
      '${ApiUrl.baseUrl}${ApiUrl.getUnsolvedReason}?ParamName=in_sub_product_file_id&ParamValue=$subProductFileId&StoredProcedure=ddl_UnsolvedReason',
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
        log('⚠️ [DeviceRef Error] Invalid status: ${response.statusCode}');
        return ResponseModel.fromJson({});
      }
    } catch (e, stack) {
      log('❌ [DeviceRef Exception] $e');
      log("$stack");
      return ResponseModel.fromJson({});
    }
  }
  static Future<ServiceRecordResponse> getServiceRecordById(int serviceRecordId) async {
    final uri = Uri.parse(
      '${ApiUrl.baseUrl}${ApiUrl.getServiceRecordById}?ServiceRecordId=$serviceRecordId',
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
        return ServiceRecordResponse.fromJson(data);
      } else {
        log('⚠️ [DeviceRef Error] Invalid status: ${response.statusCode}');
        return ServiceRecordResponse.fromJson({});
      }
    } catch (e, stack) {
      log('❌ [DeviceRef Exception] $e');
      log("$stack");
      return ServiceRecordResponse.fromJson({});
    }
  }

}
