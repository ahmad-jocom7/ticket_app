import 'package:get/get.dart';
import '../model/ticket/history_device_model.dart';
import '../service/service_record_service.dart';

class DeviceHistoryController extends GetxController {
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  var deviceHistoryModel = Rxn<DeviceHistoryModel>();

  var subProductFileId = 0.obs;
  var count = 10.obs;

  Future<void> getDeviceHistory(int subProductFileId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await ServiceRecordService.getDeviceHistory(
        subProductFileId: subProductFileId,
        count: count.value,
      );

      if (result != null) {
        deviceHistoryModel.value = result;
      } else {
        errorMessage.value = "Failed to load data";
      }
    } catch (e) {
      errorMessage.value = "Unexpected error";
    } finally {
      isLoading.value = false;
    }
  }

  void increase() {
    if (count.value < 25) {
      count.value++;
    }
  }

  void decrease() {
    if (count.value > 1) {
      count.value--;
    }
  }
}
