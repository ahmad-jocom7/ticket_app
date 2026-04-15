class TicketHistoryModel {
  List<TicketData> tickets;
  TotalCount totalCount;

  TicketHistoryModel({required this.tickets, required this.totalCount});

  factory TicketHistoryModel.fromJson(Map<String, dynamic> json) =>
      TicketHistoryModel(
        totalCount: json["totalCount"] == null
            ? TotalCount.fromJson({})
            : TotalCount.fromJson(json["totalCount"]),
        tickets: List<TicketData>.from(
          json["Tickets"].map((x) => TicketData.fromJson(x)),
        ),
      );

  Map<String, dynamic> toJson() => {
    "totalCount": totalCount.toJson(),
    "Tickets": List<dynamic>.from(tickets.map((x) => x.toJson())),
  };
}

class TicketData {
  int ticketId;
  int subProductFileId;
  String employeeName;
  String subProductName;
  String customerName;
  String dateTime;
  String contentName;
  String status;
  String serialNo;
  String customerRefNo;
  String callerName;
  String area;
  String subArea;

  // 🆕 الجديد
  bool rejected;
  int serviceRecordResult;

  TicketData({
    required this.ticketId,
    required this.subProductFileId,
    required this.employeeName,
    required this.subProductName,
    required this.customerName,
    required this.dateTime,
    required this.contentName,
    required this.status,
    required this.serialNo,
    required this.customerRefNo,
    required this.callerName,
    required this.area,
    required this.subArea,
    required this.rejected,
    required this.serviceRecordResult,
  });

  factory TicketData.fromJson(Map<String, dynamic> json) => TicketData(
    ticketId: json["ticketId"],
    subProductFileId: json["subProductFileId"],
    employeeName: json["employeeName"],
    subProductName: json["subProductName"],
    customerName: json["customerName"],
    dateTime: json["dateTime"],
    contentName: json["contentName"],
    status: json["status"],
    serialNo: json["serialNo"],
    customerRefNo: json["customerRefNo"],
    callerName: json["callerName"],
    area: json["area"],
    subArea: json["subArea"],

    // 🆕
    rejected: json["rejected"] ?? false,
    serviceRecordResult: json["serviceRecordResult"] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "ticketId": ticketId,
    "subProductFileId": subProductFileId,
    "employeeName": employeeName,
    "subProductName": subProductName,
    "customerName": customerName,
    "dateTime": dateTime,
    "contentName": contentName,
    "status": status,
    "serialNo": serialNo,
    "customerRefNo": customerRefNo,
    "callerName": callerName,
    "area": area,
    "subArea": subArea,

    // 🆕
    "rejected": rejected,
    "serviceRecordResult": serviceRecordResult,
  };
}

class TotalCount {
  int resolvedOnSite;
  int resolvedOnWorkshop;
  int unResolved;
  int rejected;

  TotalCount({
    required this.resolvedOnSite,
    required this.resolvedOnWorkshop,
    required this.unResolved,
    required this.rejected,
  });

  factory TotalCount.fromJson(Map<String, dynamic> json) => TotalCount(
    resolvedOnSite: json["resolvedOnSite"] ?? 0,
    resolvedOnWorkshop: json["resolvedOnWorkshop"] ?? 0,
    unResolved: json["unResolved"] ?? 0,
    rejected: json["rejected"] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "resolvedOnSite": resolvedOnSite,
    "resolvedOnWorkshop": resolvedOnWorkshop,
    "unResolved": unResolved,
    "rejected": rejected,
  };
}
