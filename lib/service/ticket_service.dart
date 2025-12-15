import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:ticket_app/model/ticket/response_model.dart';
import '../utils/api_url.dart';
import '../utils/my_shared_preferences.dart';
import '../model/service_record/add_assign_ticket_model.dart';
import '../model/service_record/serial_no_model.dart';
import '../model/ticket/product_file_model.dart';
import '../model/ticket/system_config_model.dart';
import '../model/ticket/add_ticket_model.dart';
import '../model/ticket/zone_model.dart';

class TicketService {
  static Future<SystemConfigurationModel> getSystemConfiguration() async {
    final uri = Uri.parse(
      '${ApiUrl.baseUrl}${ApiUrl.getSystemConfiguration}?strKey=ticket_types',
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
        return SystemConfigurationModel.fromJson(data);
      } else {
        log('⚠️ [SystemConfig Error] Invalid status: ${response.statusCode}');
        return SystemConfigurationModel.fromJson({});
      }
    } catch (e, stack) {
      log('❌ [SystemConfig Exception] $e');
      log("$stack");
      return SystemConfigurationModel.fromJson({});
    }
  }

  static Future<ResponseModel> getCustomers({
    String searchText = "",
    int pageNumber = 1,
    int pageSize = 20,
  }) async {
    final uri = Uri.parse(
      '${ApiUrl.baseUrl}${ApiUrl.getCustomers}'
      '?ParamName=in_status'
      '&ParamValue=3'
      '&StoredProcedure=ddl_customers'
      '&searchText=$searchText'
      '&pageNumber=$pageNumber'
      '&pageSize=$pageSize',
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
        log('⚠️ [Customers Error] Invalid status: ${response.statusCode}');
        return ResponseModel.fromJson({});
      }
    } catch (e, stack) {
      log('❌ [Customers Exception] $e');
      log("$stack");
      return ResponseModel.fromJson({});
    }
  }

  static Future<ResponseModel> getSubProduct(
    int customerId, {
    int area = 0,
    int subArea = 0,
  }) async {
    String endpoint = "${ApiUrl.baseUrl}${ApiUrl.getSubProduct}";
    String storedProcedure = "ddl_subProductByCustomer";
    String query = "";

    // ✅ الحالة 1: Customer فقط
    if (area == 0 && subArea == 0) {
      storedProcedure = "ddl_subProductByCustomer";
      query =
          "ParamName=in_customer_id&ParamValue=$customerId&StoredProcedure=$storedProcedure";
    }
    // ✅ الحالة 2: Customer + Area → استخدم FillDDL2Param
    else if (area != 0 && subArea == 0) {
      endpoint = "${ApiUrl.baseUrl}ddl/FillDDL2Param";
      storedProcedure = "ddl_subProductByArea";
      query =
          "ParamName1=in_area_id&ParamValue1=$area&ParamName2=in_customer_id&ParamValue2=$customerId&StoredProcedure=$storedProcedure";
    }
    // ✅ الحالة 3: Customer + SubArea → استخدم FillDDL2Param
    else if (subArea != 0) {
      endpoint = "${ApiUrl.baseUrl}ddl/FillDDL2Param";
      storedProcedure = "ddl_subProductBySubArea";
      query =
          "ParamName1=in_subArea_id&ParamValue1=$subArea&ParamName2=in_customer_id&ParamValue2=$customerId&StoredProcedure=$storedProcedure";
    }

    final uri = Uri.parse("$endpoint?$query");

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

  static Future<ResponseModel> getDeviceRef(int customerId) async {
    final uri = Uri.parse(
      '${ApiUrl.baseUrl}${ApiUrl.getDeviceRef}?ParamName=in_customer_id&ParamValue=$customerId&StoredProcedure=ddl_customerRefNoByCustomerId',
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

  static Future<ProductFileModel> getSubProductFileByCustomerRefNo(
    int customerId,
    String customerRefNo,
  ) async {
    final uri = Uri.parse(
      '${ApiUrl.baseUrl}${ApiUrl.getSubProductFileByCustomerRefNo}?CustomerId=$customerId&CustRefNo=$customerRefNo',
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
        return ProductFileModel.fromJson(data);
      } else {
        log('⚠️ [Serial Error] Invalid status: ${response.statusCode}');
        return ProductFileModel.fromJson({});
      }
    } catch (e, stack) {
      log('❌ [Serial Exception] $e');
      log("$stack");
      return ProductFileModel.fromJson({});
    }
  }

  static Future<ResponseModel> getSerial(
    int customerId, {
    int area = 0,
    int subArea = 0,
  }) async {
    String endpoint = "${ApiUrl.baseUrl}ddl/FillDDLParamIdString";
    String storedProcedure = "ddl_serialByCustomer";
    String query = "";
    if (area == 0 && subArea == 0) {
      storedProcedure = "ddl_serialByCustomer";
      endpoint = "${ApiUrl.baseUrl}ddl/FillDDLParamIdString";
      query =
          "ParamName=in_customer_id&ParamValue=$customerId&StoredProcedure=$storedProcedure";
    } else if (area != 0 && subArea == 0) {
      storedProcedure = "ddl_serialNoByArea";
      endpoint = "${ApiUrl.baseUrl}ddl/FillDDL2ParamIdString";
      query =
          "ParamName1=in_area_id&ParamValue1=$area&ParamName2=in_customer_id&ParamValue2=$customerId&StoredProcedure=$storedProcedure";
    } else if (subArea != 0) {
      storedProcedure = "ddl_serialNoBySubArea";
      endpoint = "${ApiUrl.baseUrl}ddl/FillDDL2ParamIdString";
      query =
          "ParamName1=in_subArea_id&ParamValue1=$subArea&ParamName2=in_customer_id&ParamValue2=$customerId&StoredProcedure=$storedProcedure";
    }

    final uri = Uri.parse("$endpoint?$query");

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
        log('⚠️ [Serial Error] Invalid status: ${response.statusCode}');
        return ResponseModel.fromJson({});
      }
    } catch (e, stack) {
      log('❌ [Serial Exception] $e');
      log("$stack");
      return ResponseModel.fromJson({});
    }
  }

  static Future<ResponseModel> getArea(int customerId) async {
    final uri = Uri.parse(
      '${ApiUrl.baseUrl}${ApiUrl.getArea}?ParamName=in_customer_id&ParamValue=$customerId&StoredProcedure=ddl_ariaByCustomer',
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
        log('⚠️ [Serial Error] Invalid status: ${response.statusCode}');
        return ResponseModel.fromJson({});
      }
    } catch (e, stack) {
      log('❌ [Serial Exception] $e');
      log("$stack");
      return ResponseModel.fromJson({});
    }
  }

  static Future<ResponseModel> getSubArea(int customerId) async {
    final uri = Uri.parse(
      '${ApiUrl.baseUrl}${ApiUrl.getSubArea}?ParamName=in_area_id&ParamValue=$customerId&StoredProcedure=ddl_SubArea',
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
        log('⚠️ [Serial Error] Invalid status: ${response.statusCode}');
        return ResponseModel.fromJson({});
      }
    } catch (e, stack) {
      log('❌ [Serial Exception] $e');
      log("$stack");
      return ResponseModel.fromJson({});
    }
  }

  static Future<ZoneModel> getZone(int areaId) async {
    final uri = Uri.parse(
      '${ApiUrl.baseUrl}${ApiUrl.getZone}?intAreaId=$areaId&intPlatformType=2',
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
        return ZoneModel.fromJson(data);
      } else {
        log('⚠️ [Serial Error] Invalid status: ${response.statusCode}');
        return ZoneModel.fromJson({});
      }
    } catch (e, stack) {
      log('❌ [Serial Exception] $e');
      log("$stack");
      return ZoneModel.fromJson({});
    }
  }

  static Future<SerialNoModel> getSubProductFileBySerialNo(
    String serialNo,
  ) async {
    final uri = Uri.parse(
      '${ApiUrl.baseUrl}${ApiUrl.getSubProductFileBySerialNo}?SerialNo=$serialNo',
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
        return SerialNoModel.fromJson(data);
      } else {
        log('⚠️ [Serial Error] Invalid status: ${response.statusCode}');
        return SerialNoModel.fromJson({});
      }
    } catch (e, stack) {
      log('❌ [Serial Exception] $e');
      log("$stack");
      return SerialNoModel.fromJson({});
    }
  }

  static Future<ResponseModel> getFault(int subProductFileId) async {
    final uri = Uri.parse(
      '${ApiUrl.baseUrl}${ApiUrl.getFault}?ParamName=in_sub_product_file_id&ParamValue=$subProductFileId&StoredProcedure=ddl_hardwareContentInstall',
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
        log('⚠️ [Serial Error] Invalid status: ${response.statusCode}');
        return ResponseModel.fromJson({});
      }
    } catch (e, stack) {
      log('❌ [Serial Exception] $e');
      log("$stack");
      return ResponseModel.fromJson({});
    }
  }

  static Future<AddTicketModel> insertTicket({
    String? faultNote,
    String? notes,
    required String ticketType,
    required int customerId,
    required int subProductFileId,
    required String callerName,
    String? contentId,
  }) async {
    final uri = Uri.parse('${ApiUrl.baseUrl}${ApiUrl.addTicket}');

    final body = jsonEncode({
      if (faultNote != null) "strFaultNote": faultNote,
      if (notes != null) "strNots": notes,
      "strTicketType": ticketType,
      "intUserId": mySharedPreferences.getUserData()!.userId,
      "intCustomerId": customerId,
      "intSubProductFileId": subProductFileId,
      "strCallerName": callerName,
      if (contentId != null && contentId != "0") "intContentId": contentId,
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
        return AddTicketModel.fromJson(data);
      } else {
        log('⚠️ [InsertTicket Error] Invalid status: ${response.statusCode}');
        return AddTicketModel.fromJson({});
      }
    } catch (e, stack) {
      log('❌ [InsertTicket Exception] $e');
      log("$stack");
      return AddTicketModel.fromJson({});
    }
  }

  static Future<AddAssignTicketModel> assignTicket({
    required String ticketId,
  }) async {
    final uri = Uri.parse('${ApiUrl.baseUrl}${ApiUrl.assignTicket}');

    final body = jsonEncode({
      "intTicketId": ticketId,
      "intEmployeeId": mySharedPreferences.getUserData()!.employeeId,
      "intTicketPriority": "2",
      "strTaskNameOrNote": "",
      "strAssignedBy": "1",
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
        return AddAssignTicketModel.fromJson(data);
      } else {
        log('⚠️ [InsertTicket Error] Invalid status: ${response.statusCode}');
        return AddAssignTicketModel.fromJson({});
      }
    } catch (e, stack) {
      log('❌ [InsertTicket Exception] $e');
      log("$stack");
      return AddAssignTicketModel.fromJson({});
    }
  }
}
