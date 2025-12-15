class TicketResponse {
  int status;
  List<LstTicket> lstTicket;

  TicketResponse({required this.status, required this.lstTicket});

  factory TicketResponse.fromJson(Map<String, dynamic> json) => TicketResponse(
    status: json["status"],
    lstTicket: List<LstTicket>.from(
      json["lstTicket"].map((x) => LstTicket.fromJson(x)),
    ),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "lstTicket": List<dynamic>.from(lstTicket.map((x) => x.toJson())),
  };
}

class LstTicket {
  int intId;
  int intTicketId;
  int intEmployeeId;
  int intTicketPriority;
  int intAccept;
  int status;
  String strTaskNameOrNote;
  String strAssignedBy;
  TicketInfo ticketInfo;

  LstTicket({
    required this.intId,
    required this.intTicketId,
    required this.intEmployeeId,
    required this.intTicketPriority,
    required this.intAccept,
    required this.status,
    required this.strTaskNameOrNote,
    required this.strAssignedBy,
    required this.ticketInfo,
  });

  factory LstTicket.fromJson(Map<String, dynamic> json) => LstTicket(
    intId: json["intId"],
    intTicketId: json["intTicketId"],
    intEmployeeId: json["intEmployeeId"],
    intTicketPriority: json["intTicketPriority"],
    intAccept: json["intAccept"],
    status: json["status"],
    strTaskNameOrNote: json["strTaskNameOrNote"],
    strAssignedBy: json["strAssignedBy"],
    ticketInfo: TicketInfo.fromJson(json["ticketInfo"]),
  );

  Map<String, dynamic> toJson() => {
    "intId": intId,
    "intTicketId": intTicketId,
    "intEmployeeId": intEmployeeId,
    "intTicketPriority": intTicketPriority,
    "intAccept": intAccept,
    "status": status,
    "strTaskNameOrNote": strTaskNameOrNote,
    "strAssignedBy": strAssignedBy,
    "ticketInfo": ticketInfo.toJson(),
  };
}

class TicketInfo {
  int intTicketId;
  int intServiceRecordID;
  String strCustomerName;
  String strReportedBy;
  String strTicketType;
  String strFaultNote;
  String strNots;
  String strCallerName;
  int intCustomerId;
  int intSubProductFileId;
  String strDateTime;
  String strSerialNo;
  int intSubAreaId;
  int intSubProductId;
  String strSubProductName;
  String strFault;
  String strArea;
  String strSubArea;
  String strCustomerRefNo;
  String locationType;
  String suggestedFault;

  TicketInfo({
    required this.intTicketId,
    required this.intServiceRecordID,
    required this.strCustomerName,
    required this.strReportedBy,
    required this.strTicketType,
    required this.strFaultNote,
    required this.strNots,
    required this.strCallerName,
    required this.intCustomerId,
    required this.intSubProductFileId,
    required this.strDateTime,
    required this.strSerialNo,
    required this.intSubAreaId,
    required this.intSubProductId,
    required this.strSubProductName,
    required this.strFault,
    required this.strArea,
    required this.strSubArea,
    required this.strCustomerRefNo,
    required this.locationType,
    required this.suggestedFault,
  });

  factory TicketInfo.fromJson(Map<String, dynamic> json) => TicketInfo(
    intTicketId: json["intTicketId"],
    intServiceRecordID: json["intServiceRecordID"] ?? 0,
    strCustomerName: json["strCustomerName"],
    strReportedBy: json["strReportedBy"],
    strTicketType: json["strTicketType"],
    strFaultNote: json["strFaultNote"],
    strNots: json["strNots"],
    strCallerName: json["strCallerName"],
    intCustomerId: json["intCustomerId"],
    intSubProductFileId: json["intSubProductFileId"],
    strDateTime: json["strDateTime"],
    strSerialNo: json["strSerialNo"],
    intSubAreaId: json["intSubAreaId"],
    intSubProductId: json["intSubProductId"],
    strSubProductName: json["strSubProductName"],
    strFault: json["strFault"],
    strArea: json["strArea"],
    strSubArea: json["strSubArea"],
    strCustomerRefNo: json["strCustomerRefNo"],
    locationType: json["locationType"],
    suggestedFault: json["suggestedFault"],
  );

  Map<String, dynamic> toJson() => {
    "intTicketId": intTicketId,
    "intServiceRecordID": intServiceRecordID,
    "strCustomerName": strCustomerName,
    "strReportedBy": strReportedBy,
    "strTicketType": strTicketType,
    "strFaultNote": strFaultNote,
    "strNots": strNots,
    "strCallerName": strCallerName,
    "intCustomerId": intCustomerId,
    "intSubProductFileId": intSubProductFileId,
    "strSerialNo": strSerialNo,
    "intSubAreaId": intSubAreaId,
    "intSubProductId": intSubProductId,
    "strSubProductName": strSubProductName,
    "strFault": strFault,
    "strArea": strArea,
    "strSubArea": strSubArea,
    "strCustomerRefNo": strCustomerRefNo,
    "locationType": locationType,
    "suggestedFault": suggestedFault,
  };
}
