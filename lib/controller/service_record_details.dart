import 'dart:developer';
import 'package:get/get.dart';

import '../model/service_record/service_record_model.dart';
import '../service/service_record_service.dart';

class ServiceRecordViewController extends GetxController {
  // 🔹 Singleton
  static ServiceRecordViewController get to =>
      Get.isRegistered<ServiceRecordViewController>()
      ? Get.find<ServiceRecordViewController>()
      : Get.put(ServiceRecordViewController());

  // ==============================
  // 🔹 STATE
  // ==============================

  RxList<ServiceRecords> serviceRecords = <ServiceRecords>[].obs;

  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;

  // ==============================
  // 🔹 API CALL
  // ==============================

  Future<void> getServiceRecordByTicketId(int ticketId) async {
    try {
      isLoading(true);
      errorMessage('');

      log('📡 Fetching Service Records for TicketId=$ticketId');

      final res = await ServiceRecordService.getServiceRecordByTicketId(
        ticketId,
      );

      if (res != null && (res.serviceRecords.isNotEmpty ?? false)) {
        serviceRecords.assignAll(res.serviceRecords);
      } else {
        serviceRecords.clear();
        errorMessage('No service records found');
      }
    } catch (e, stack) {
      errorMessage('Failed to load service records');

      log('❌ Error: $e');
      log('$stack');
    } finally {
      isLoading(false);
    }
  }

  // ==============================
  // 🔹 HELPERS
  // ==============================

  bool get hasData => serviceRecords.isNotEmpty;

  ServiceRecords? get firstRecord =>
      serviceRecords.isNotEmpty ? serviceRecords.first : null;

  // ==============================
  // 🔹 CLEAR
  // ==============================

  void clear() {
    serviceRecords.clear();
    errorMessage('');
  }
}
