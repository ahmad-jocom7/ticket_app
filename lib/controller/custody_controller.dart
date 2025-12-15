import 'dart:developer';
import 'package:get/get.dart';
import 'package:ticket_app/model/custody/custody_model.dart';
import 'package:ticket_app/service/custody_service.dart';

import '../utils/snackbar.dart';

class CustodyController extends GetxController {
  static CustodyController get to => Get.isRegistered<CustodyController>()
      ? Get.find<CustodyController>()
      : Get.put(CustodyController());

  /// Loading + Error States
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var isSendingLoading = false.obs;

  final RxString descriptionError = ''.obs;

  /// Custody Data List
  List<CustodyData> custodyList = [];

  Future<void> fetchCustody() async {
    try {
      isLoading(true);
      errorMessage('');

      log('🎬 Fetching custody items for employee...');

      final result = await CustodyService.getCustody();

      custodyList = result.custody;

      if (custodyList.isEmpty) {
        errorMessage('No custody records found.');
        log('⚠️ Custody list is empty.');
      } else {
        log('✅ Loaded ${custodyList.length} custody items.');
      }
    } catch (e, stack) {
      errorMessage('An error occurred: $e');
      log('❌ Error: $e');
      log('$stack');
    } finally {
      isLoading(false);
      update();
    }
  }

  Future<void> sendDeliveryRequest({
    required int custodyId,
    required String description,
  }) async {
    try {
      Get.back(); // إغلاق الـ dialog
      isSendingLoading(true);
      errorMessage('');

      log('📦 Sending delivery request for custodyId: $custodyId');

      final success = await CustodyService.sendDeliveryRequest(
        custodyId: custodyId,
        description: description,
      );

      if (success) {
        log('✅ Delivery request sent successfully');

        showSuccess('Delivery request sent successfully');

        await fetchCustody();
      } else {
        errorMessage('Failed to send delivery request');

        showError('Failed to send delivery request');
      }
    } catch (e, stack) {
      errorMessage('An error occurred: $e');

      log('❌ SendDeliveryRequest Error: $e');
      log('$stack');

      showError('Something went wrong');
    } finally {
      isSendingLoading(false);
      update();
    }
  }


  /// Refresh manually (if needed)
  Future<void> refreshCustody() async {
    await fetchCustody();
  }
}
