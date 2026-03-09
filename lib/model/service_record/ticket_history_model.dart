
class TicketHistoryModel {
  List<TicketData> tickets;

  TicketHistoryModel({
    required this.tickets,
  });

  factory TicketHistoryModel.fromJson(Map<String, dynamic> json) => TicketHistoryModel(
    tickets: List<TicketData>.from(json["Tickets"].map((x) => TicketData.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
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
  };
}
