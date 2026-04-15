import 'package:ticket_app/model/service_record/service_record_model.dart';

class ServiceRecordDetailsModel {
  final List<ServiceRecords> serviceRecords;

  ServiceRecordDetailsModel({
    required this.serviceRecords,
  });

  factory ServiceRecordDetailsModel.fromJson(Map<String, dynamic> json) =>
      ServiceRecordDetailsModel(
        serviceRecords: (json["Service_Records"] as List? ?? [])
            .map((e) => ServiceRecords.fromJson(e))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
    "Service_Records": serviceRecords.map((e) => e.toJson()).toList(),
  };
}