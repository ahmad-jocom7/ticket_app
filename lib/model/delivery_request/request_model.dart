// To parse this JSON data, do
//
//     final requestModel = requestModelFromJson(jsonString);

import 'dart:convert';

RequestModel requestModelFromJson(String str) => RequestModel.fromJson(json.decode(str));

String requestModelToJson(RequestModel data) => json.encode(data.toJson());

class RequestModel {
  int status;
  String message;
  List<LstRequest> lstRequests;

  RequestModel({
    required this.status,
    required this.message,
    required this.lstRequests,
  });

  factory RequestModel.fromJson(Map<String, dynamic> json) => RequestModel(
    status: json["status"],
    message: json["Message"],
    lstRequests: List<LstRequest>.from(json["lstRequests"].map((x) => LstRequest.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "Message": message,
    "lstRequests": List<dynamic>.from(lstRequests.map((x) => x.toJson())),
  };
}

class LstRequest {
  int id;
  int fromEmployeeId;
  int toEmplyeeId;
  String partNumber;
  String description;
  String customerName;
  String branch;
  int status;
  int contentId;
  dynamic custodyId;
  DateTime dateTime;
  String fromEmployeeName;
  String toEmployeeName;
  String contentName;

  LstRequest({
    required this.id,
    required this.fromEmployeeId,
    required this.toEmplyeeId,
    required this.partNumber,
    required this.description,
    required this.customerName,
    required this.branch,
    required this.status,
    required this.contentId,
    required this.custodyId,
    required this.dateTime,
    required this.fromEmployeeName,
    required this.toEmployeeName,
    required this.contentName,
  });

  factory LstRequest.fromJson(Map<String, dynamic> json) => LstRequest(
    id: json["id"],
    fromEmployeeId: json["from_employee_id"],
    toEmplyeeId: json["to_emplyee_id"],
    partNumber: json["part_number"],
    description: json["description"],
    customerName: json["customer_name"],
    branch: json["branch"],
    status: json["status"],
    contentId: json["content_id"],
    custodyId: json["custody_id"],
    dateTime: DateTime.parse(json["date_time"]),
    fromEmployeeName: json["from_employeeName"],
    toEmployeeName: json["to_employeeName"],
    contentName: json["contentName"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "from_employee_id": fromEmployeeId,
    "to_emplyee_id": toEmplyeeId,
    "part_number": partNumber,
    "description": description,
    "customer_name": customerName,
    "branch": branch,
    "status": status,
    "content_id": contentId,
    "custody_id": custodyId,
    "date_time": dateTime.toIso8601String(),
    "from_employeeName": fromEmployeeName,
    "to_employeeName": toEmployeeName,
    "contentName": contentName,
  };
}
