import 'dart:developer';
import 'package:get/get.dart';

import '../model/service_record/ticket_history_model.dart';
import '../service/service_record_service.dart';

class TicketHistoryController extends GetxController {
  static TicketHistoryController get to =>
      Get.isRegistered<TicketHistoryController>()
      ? Get.find<TicketHistoryController>()
      : Get.put(TicketHistoryController());

  var isLoading = false.obs;
  var errorMessage = ''.obs;

  List<TicketData> data = [];

  Future<void> fetchTicketsHistory() async {
    try {
      isLoading(true);
      errorMessage('');

      log('🎬 Fetching accepted tickets from server...');

      final result = await ServiceRecordService.getTicketsHistoryByEmployee();

      if (result != null) {
        data = result.tickets;
        log('✅ Data received successfully: ${result.toJson()}');
      } else {
        errorMessage('Failed to load accepted tickets.');
        log('⚠️ No tickets found.');
      }
    } catch (e, stack) {
      errorMessage('An error occurred: $e');
      log('❌ Exception in fetchTicketsHistory: $e');
      log('$stack');
    } finally {
      update();

      isLoading(false);
    }
  }
}
