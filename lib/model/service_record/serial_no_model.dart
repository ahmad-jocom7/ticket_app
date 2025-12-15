class SerialNoModel {
  int intSubProductIdFile;
  int intSubProductId;
  int intAreaId;
  int intSubAreaId;

  SerialNoModel({
    required this.intSubProductIdFile,
    required this.intSubProductId,
    required this.intAreaId,
    required this.intSubAreaId,
  });

  factory SerialNoModel.fromJson(Map<String, dynamic> json) => SerialNoModel(
    intSubProductIdFile: json["intSubproductFileId"],
    intSubProductId: json["intSubProductId"],
    intAreaId: json["intAreaId"],
    intSubAreaId: json["intSubAreaId"],
  );

  Map<String, dynamic> toJson() => {
    "intSubproductFileId": intSubProductIdFile,
    "intSubProductId": intSubProductId,
    "intAreaId": intAreaId,
    "intSubAreaId": intSubAreaId,

  };
}
