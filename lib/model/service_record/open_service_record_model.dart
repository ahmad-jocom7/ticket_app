class OpenServiceRecordModel {
  int status;
  int serviceRecordId;
  String message;

  OpenServiceRecordModel({
    required this.status,
    required this.serviceRecordId,
    required this.message,
  });

  factory OpenServiceRecordModel.fromJson(Map<String, dynamic> json) =>
      OpenServiceRecordModel(
        status: json["status"],
        serviceRecordId: json["ServiceRecord_ID"],
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "ServiceRecord_ID": serviceRecordId,
    "message": message,
  };
}
