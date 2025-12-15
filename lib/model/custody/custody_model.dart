
class CustodyModel {
  int status;
  String message;
  List<CustodyData> custody;

  CustodyModel({
    required this.status,
    required this.message,
    required this.custody,
  });

  factory CustodyModel.fromJson(Map<String, dynamic> json) => CustodyModel(
    status: json["status"],
    message: json["Message"],
    custody: List<CustodyData>.from(json["custody"].map((x) => CustodyData.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "Message": message,
    "custody": List<dynamic>.from(custody.map((x) => x.toJson())),
  };
}

class CustodyData {
  int id;
  int employeeId;
  int contentId;
  String partNumber;
  String serialNumber;
  String addedAt;
  String employeeName;
  String contentName;
  String poductName;
  int hasDeliveryRequest;

  CustodyData({
    required this.id,
    required this.employeeId,
    required this.contentId,
    required this.partNumber,
    required this.serialNumber,
    required this.addedAt,
    required this.employeeName,
    required this.contentName,
    required this.poductName,
    required this.hasDeliveryRequest,
  });

  factory CustodyData.fromJson(Map<String, dynamic> json) => CustodyData(
    id: json["id"],
    employeeId: json["employeeId"],
    contentId: json["contentId"],
    partNumber: json["partNumber"],
    serialNumber: json["serialNumber"],
    addedAt: json["addedAt"],
    employeeName: json["employeeName"],
    contentName: json["contentName"],
    poductName: json["poductName"],
    hasDeliveryRequest: json["has_delivery_request"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "employeeId": employeeId,
    "contentId": contentId,
    "partNumber": partNumber,
    "serialNumber": serialNumber,
    "addedAt": addedAt,
    "employeeName": employeeName,
    "contentName": contentName,
    "poductName": poductName,
    "has_delivery_request": hasDeliveryRequest,
  };
}
