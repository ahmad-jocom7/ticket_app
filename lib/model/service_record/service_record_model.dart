class ServiceRecordResponse {
  final ServiceRecords? serviceRecords;

  ServiceRecordResponse({
    this.serviceRecords,
  });

  factory ServiceRecordResponse.fromJson(Map<String, dynamic> json) =>
      ServiceRecordResponse(
        serviceRecords: json["Service_Records"] == null
            ? null
            : ServiceRecords.fromJson(json["Service_Records"]),
      );

  Map<String, dynamic> toJson() => {
    "Service_Records": serviceRecords?.toJson(),
  };
}

class ServiceRecords {
  int? intServiceRecordId;
  int? intServiceRecordApprovalRequstId;
  int? intTicketId;
  int? intUserId;
  String? strRecordDate;
  String? strTimeIn;
  String? strTimeOut;
  DateTime? strTripTime;
  String? strSolutionTime;
  int? intEmployeeId;
  int? intSolution;
  String? strRepairNote;
  int? intServiceResult;
  int? intUnsolvedReasonId;
  String? strUnsolvedNote;
  int? intEngineerMark;
  int? intMarkedBy;
  int? intPlatformType;
  String? strEmployeeName;
  String? strEmployeeTel;
  String? strContentName;
  String? strSolution;
  String? strServiceResult;
  String? strReason;
  String? strFault;
  String? strActualFault;
  String? strActualFaultSerial;
  int? intActualFault;
  int? intActualFaultSerial;
  int? intSubProductFileId;
  int? intTicketStatus;
  String? btClientSig;
  String? bytClientSig;
  String? strApprovalRequestDescription;
  String? strUserName;
  int? intIfRequestMedia;
  double? dblTranspExpn;
  double? dblOvertimeExpn;
  String? overtimeHours;
  String? strCustomerName;
  String? strSerialNo;
  String? strSubProductName;
  String? strTicketType;
  String? strFaultNote;
  String? strTicketDate;
  String? strTicketReceivedBy;
  String? strLocationDesc;
  String? srVandalism;
  int? intVandalism;
  double? transportationExpenses;
  String? signatureName;

  ServiceRecords({
    this.intServiceRecordId,
    this.intServiceRecordApprovalRequstId,
    this.intTicketId,
    this.intUserId,
    this.strRecordDate,
    this.strTimeIn,
    this.strTimeOut,
    this.strTripTime,
    this.strSolutionTime,
    this.intEmployeeId,
    this.intSolution,
    this.strRepairNote,
    this.intServiceResult,
    this.intUnsolvedReasonId,
    this.strUnsolvedNote,
    this.intEngineerMark,
    this.intMarkedBy,
    this.intPlatformType,
    this.strEmployeeName,
    this.strEmployeeTel,
    this.strContentName,
    this.strSolution,
    this.strServiceResult,
    this.strReason,
    this.strFault,
    this.strActualFault,
    this.strActualFaultSerial,
    this.intActualFault,
    this.intActualFaultSerial,
    this.intSubProductFileId,
    this.intTicketStatus,
    this.btClientSig,
    this.bytClientSig,
    this.strApprovalRequestDescription,
    this.strUserName,
    this.intIfRequestMedia,
    this.dblTranspExpn,
    this.dblOvertimeExpn,
    this.overtimeHours,
    this.strCustomerName,
    this.strSerialNo,
    this.strSubProductName,
    this.strTicketType,
    this.strFaultNote,
    this.strTicketDate,
    this.strTicketReceivedBy,
    this.strLocationDesc,
    this.srVandalism,
    this.intVandalism,
    this.transportationExpenses,
    this.signatureName,
  });

  factory ServiceRecords.fromJson(Map<String, dynamic> json) => ServiceRecords(
    intServiceRecordId: json["intServiceRecordId"],
    intServiceRecordApprovalRequstId:
    json["intServiceRecordApprovalRequstId"],
    intTicketId: json["intTicketId"],
    intUserId: json["intUserId"],
    strRecordDate: json["strRecordDate"],
    strTimeIn: json["strTimeIn"],
    strTimeOut: json["strTimeOut"],
    strTripTime: json["strTripTime"] != null
        ? DateTime.tryParse(json["strTripTime"])
        : null,
    strSolutionTime: json["strSolutionTime"],
    intEmployeeId: json["intEmployeeId"],
    intSolution: json["intSolution"],
    strRepairNote: json["strRepairNote"],
    intServiceResult: json["intServiceResult"],
    intUnsolvedReasonId: json["intUnsolvedReasonId"],
    strUnsolvedNote: json["strUnsolvedNote"],
    intEngineerMark: json["intEngineerMark"],
    intMarkedBy: json["intMarkedBy"],
    intPlatformType: json["intPlatformType"],
    strEmployeeName: json["strEmployeeName"],
    strEmployeeTel: json["strEmployeeTel"],
    strContentName: json["strContentName"],
    strSolution: json["strSolution"],
    strServiceResult: json["strServiceResult"],
    strReason: json["strReason"],
    strFault: json["strFault"],
    strActualFault: json["strActualFault"],
    strActualFaultSerial: json["strActualFaultSerial"],
    intActualFault: json["intActualFault"],
    intActualFaultSerial: json["intActualFaultSerial"],
    intSubProductFileId: json["intSubProductFileId"],
    intTicketStatus: json["intTicketStatus"],
    btClientSig: json["btClientSig"],
    bytClientSig: json["bytClientSig"],
    strApprovalRequestDescription: json["strApprovalRequestDescription"],
    strUserName: json["strUserName"],
    intIfRequestMedia: json["intIfRequestMedia"],
    dblTranspExpn: (json["dblTranspExpn"] as num?)?.toDouble(),
    dblOvertimeExpn: (json["dblOvertimeExpn"] as num?)?.toDouble(),
    overtimeHours: json["OvertimeHours"],
    strCustomerName: json["strCustomerName"],
    strSerialNo: json["strSerialNo"],
    strSubProductName: json["strSubProductName"],
    strTicketType: json["strTicketType"],
    strFaultNote: json["strFaultNote"],
    strTicketDate: json["strTicketDate"],
    strTicketReceivedBy: json["strTicketReceivedBy"],
    strLocationDesc: json["strLocationDesc"],
    srVandalism: json["sr_vandalism"],
    intVandalism: json["intVandalism"],
    transportationExpenses:
    (json["transportation_expenses"] as num?)?.toDouble(),
    signatureName: json["signature_name"],
  );

  Map<String, dynamic> toJson() => {
    "intServiceRecordId": intServiceRecordId,
    "intServiceRecordApprovalRequstId": intServiceRecordApprovalRequstId,
    "intTicketId": intTicketId,
    "intUserId": intUserId,
    "strRecordDate": strRecordDate,
    "strTimeIn": strTimeIn,
    "strTimeOut": strTimeOut,
    "strTripTime": strTripTime?.toIso8601String(),
    "strSolutionTime": strSolutionTime,
    "intEmployeeId": intEmployeeId,
    "intSolution": intSolution,
    "strRepairNote": strRepairNote,
    "intServiceResult": intServiceResult,
    "intUnsolvedReasonId": intUnsolvedReasonId,
    "strUnsolvedNote": strUnsolvedNote,
    "intEngineerMark": intEngineerMark,
    "intMarkedBy": intMarkedBy,
    "intPlatformType": intPlatformType,
    "strEmployeeName": strEmployeeName,
    "strEmployeeTel": strEmployeeTel,
    "strContentName": strContentName,
    "strSolution": strSolution,
    "strServiceResult": strServiceResult,
    "strReason": strReason,
    "strFault": strFault,
    "strActualFault": strActualFault,
    "strActualFaultSerial": strActualFaultSerial,
    "intActualFault": intActualFault,
    "intActualFaultSerial": intActualFaultSerial,
    "intSubProductFileId": intSubProductFileId,
    "intTicketStatus": intTicketStatus,
    "btClientSig": btClientSig,
    "bytClientSig": bytClientSig,
    "strApprovalRequestDescription": strApprovalRequestDescription,
    "strUserName": strUserName,
    "intIfRequestMedia": intIfRequestMedia,
    "dblTranspExpn": dblTranspExpn,
    "dblOvertimeExpn": dblOvertimeExpn,
    "OvertimeHours": overtimeHours,
    "strCustomerName": strCustomerName,
    "strSerialNo": strSerialNo,
    "strSubProductName": strSubProductName,
    "strTicketType": strTicketType,
    "strFaultNote": strFaultNote,
    "strTicketDate": strTicketDate,
    "strTicketReceivedBy": strTicketReceivedBy,
    "strLocationDesc": strLocationDesc,
    "sr_vandalism": srVandalism,
    "intVandalism": intVandalism,
    "transportation_expenses": transportationExpenses,
    "signature_name": signatureName,
  };
}
