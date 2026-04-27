import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:ticket_app/utils/api_url.dart';
import 'package:ticket_app/utils/my_shared_preferences.dart';

import '../model/service_record/assign_ticket_model.dart';
import '../model/service_record/open_service_record_model.dart';
import '../model/service_record/service_record_details_model.dart';
import '../model/service_record/ticket_history_model.dart';
import '../model/ticket/history_device_model.dart';
import '../model/ticket/response_model.dart';
import '../model/service_record/service_record_model.dart';

class ServiceRecordService {
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

  static Future<TicketResponse?> getAcceptedTicketsByEmployee({
    int ticketId = 0,
    String fromDate = '0',
    String toDate = '0',
  }) async {
    final uri = Uri.parse(
      '${ApiUrl.baseUrl}${ApiUrl.getAcceptedTickets}'
      '?employeeId=${mySharedPreferences.getUserData()!.employeeId}&status=3&ticketId=$ticketId&fromDate=$fromDate&toDate=$toDate',
      // '?employeeId=9&status=3&ticketId=0&fromDate=05/12/2025&toDate=07/01/2026',
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

  static Future<TicketHistoryModel?> getTicketsHistoryByEmployee() async {
    final uri = Uri.parse(
      '${ApiUrl.baseUrl}${ApiUrl.getTicketsHistory}'
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
        return TicketHistoryModel.fromJson(data);
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

    final body = jsonEncode({
      'intTicketId': ticketId,
      'intEmployeeId': mySharedPreferences.getUserData()!.employeeId,
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
    required String repairNote,

    required int serviceResult,
    required int intSolution,
    int custodyId = 0,
    String? oldSerial,
    int? unsolvedReasonId,
    int? intuserId = 0,
    String? unsolvedNote,
    String? actualFault,
    required String tripTime,
    required String clientSignature,
    required String signatureName,
    required int serviceLocation,
  }) async {
    final uri = Uri.parse('${ApiUrl.baseUrl}${ApiUrl.closeServiceRecord}');

    final body = jsonEncode({
      "intServiceRecordId": serviceRecordId,
      "intTicketId": ticketId,
      "intEmployeeId": mySharedPreferences.getUserData()!.employeeId,
      "intSolution": intSolution,
      "strRepairNote": repairNote,
      "intServiceResult": serviceResult,
      if (unsolvedReasonId != 0) "intUnsolvedReasonId": unsolvedReasonId,
      if (intuserId != 0) "intuserId": intuserId,
      if (unsolvedNote!.isNotEmpty) "strUnsolvedNote": unsolvedNote,
      if (actualFault!.isNotEmpty) "actualFault": actualFault,
      "strTripTime": tripTime,

      "bytClientSig": clientSignature,
      "signature_name": signatureName,
      if (custodyId != 0) "custodyId": custodyId,
      if (oldSerial != null || oldSerial != "" || oldSerial!.isNotEmpty)
        "oldSerial": oldSerial,
      "serviceLocation": serviceLocation,
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

  static Future<ServiceRecordResponse> getServiceRecordById(
    int serviceRecordId,
  ) async {
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

  static Future<DeviceHistoryModel?> getDeviceHistory({
    required int subProductFileId,
    int count = 10,
  }) async {
    final uri = Uri.parse(
      '${ApiUrl.baseUrl}ServiceRecord/GetDeviceHistory'
          '?subProductFileId=$subProductFileId&count=$count',
      // 'http://10.0.0.63:9096/api/ServiceRecord/GetDeviceHistory'
      // '?subProductFileId=$subProductFileId&count=$count',
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
        return DeviceHistoryModel.fromJson(data);
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
  static Future<ServiceRecordDetailsModel?> getServiceRecordByTicketId(int ticketId) async {
    final uri = Uri.parse(
      '${ApiUrl.baseUrl}ServiceRecord/GetByTicketId?TicketId=$ticketId',
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
        return ServiceRecordDetailsModel.fromJson(data);
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
}
