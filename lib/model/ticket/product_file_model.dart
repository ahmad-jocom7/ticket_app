class ProductFileModel {
  int intSubproductFileId;
  int intSubProductId;
  String strSerialNumber;
  int intAreaId;
  int intSubAreaId;

  ProductFileModel({
    required this.intSubproductFileId,
    required this.intSubProductId,
    required this.strSerialNumber,
    required this.intAreaId,
    required this.intSubAreaId,
  });

  factory ProductFileModel.fromJson(Map<String, dynamic> json) =>
      ProductFileModel(
        intSubproductFileId: json["intSubproductFileId"],
        intSubProductId: json["intSubProductId"],
        strSerialNumber: json["strSerialNumber"],
        intAreaId: json["intAreaId"],
        intSubAreaId: json["intSubAreaId"],
      );

  Map<String, dynamic> toJson() => {
    "intSubproductFileId": intSubproductFileId,
    "intSubProductId": intSubProductId,
    "strSerialNumber": strSerialNumber,
    "intAreaId": intAreaId,
    "intSubAreaId": intSubAreaId,
  };
}
