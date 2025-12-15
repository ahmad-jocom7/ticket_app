class ResponseModel {
  List<LookupDatum> lookupData;

  ResponseModel({required this.lookupData});

  factory ResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json["LookupData"];

    final List<LookupDatum> parsedList = (data is List)
        ? data.map((x) => LookupDatum.fromJson(x)).toList()
        : <LookupDatum>[];

    return ResponseModel(lookupData: parsedList);
  }

  Map<String, dynamic> toJson() => {
    "LookupData": List<dynamic>.from(lookupData.map((x) => x.toJson())),
  };
}

class LookupDatum {
  int intLookupId;
  dynamic strLookupId;
  String strLookupText;

  LookupDatum({
    required this.intLookupId,
    required this.strLookupId,
    required this.strLookupText,
  });

  factory LookupDatum.fromJson(Map<String, dynamic> json) => LookupDatum(
    intLookupId: json["intLookupId"] ?? 0,
    strLookupId: json["strLookupId"] ?? 0,
    strLookupText: json["strLookupText"] ?? '',
  );

  Map<String, dynamic> toJson() => {
    "intLookupId": intLookupId,
    "strLookupId": strLookupId,
    "strLookupText": strLookupText,
  };
}
