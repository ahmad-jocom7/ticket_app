import 'package:get/get.dart';

import '../model/delivery_request/request_model.dart';
import '../service/history_request_service.dart';

class HistoryRequestController extends GetxController {
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var requestModel = Rxn<RequestModel>();

  var selectedStatus = 0.obs; // 👈 default = Pending

  Future<void> getHistoryRequests(int status) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result =
      await HistoryRequestService.getHistoryRequests(status);

      if (result != null) {
        requestModel.value = result;
      } else {
        errorMessage.value = 'Failed to load data';
      }
    } catch (e) {
      errorMessage.value = 'Unexpected error';
    } finally {
      isLoading.value = false;
    }
  }

  void changeStatus(int status) {
    selectedStatus.value = status;
    getHistoryRequests(status);
  }
}
