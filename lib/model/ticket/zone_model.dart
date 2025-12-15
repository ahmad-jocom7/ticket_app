
class ZoneModel {
  int intAreaId;
  int intZoneId;
  int intZoneNumber;
  String strAreaName;

  ZoneModel({
    required this.intAreaId,
    required this.intZoneId,
    required this.intZoneNumber,
    required this.strAreaName,
  });

  factory ZoneModel.fromJson(Map<String, dynamic> json) => ZoneModel(
    intAreaId: json["intAreaID"],
    intZoneId: json["intZoneID"],
    intZoneNumber: json["intZoneNumber"],
    strAreaName: json["strAreaName"],
  );

  Map<String, dynamic> toJson() => {
    "intAreaID": intAreaId,
    "intZoneID": intZoneId,
    "intZoneNumber": intZoneNumber,
    "strAreaName": strAreaName,
  };
}
