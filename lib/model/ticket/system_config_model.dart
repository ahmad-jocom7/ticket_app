class SystemConfigurationModel {
  int status;
  String message;
  List<String> systemConfigList;

  SystemConfigurationModel({
    required this.status,
    required this.message,
    required this.systemConfigList,
  });

  factory SystemConfigurationModel.fromJson(Map<String, dynamic> json) {
    // تأكد إن المفتاح موجود
    final rawValue = json["System_Configration"];

    // إذا كانت القيمة نص، نفصلها حسب الفاصلة
    List<String> parsedList = [];
    if (rawValue is String) {
      parsedList = rawValue
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    return SystemConfigurationModel(
      status: json["status"] ?? 0,
      message: json["Message"] ?? '',
      systemConfigList: parsedList,
    );
  }

  Map<String, dynamic> toJson() => {
    "status": status,
    "Message": message,
    "System_Configration": systemConfigList.join(', '),
  };
}
