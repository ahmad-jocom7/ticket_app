import 'dart:developer';
import 'package:get/get.dart';
import 'package:ticket_app/model/delivery_request/request_model.dart';
import 'package:ticket_app/service/delivery_request_service.dart';

import '../utils/snackbar.dart';

class DeliveryRequestController extends GetxController {
  static DeliveryRequestController get to =>
      Get.isRegistered<DeliveryRequestController>()
          ? Get.find<DeliveryRequestController>()
          : Get.put(DeliveryRequestController());

  var isLoading = false.obs;
  var isUpdating = false.obs;
  var errorMessage = "".obs;

  List<LstRequest> requests = [];
  int selectedIdForUpdate = 0;

  @override
  void onInit() {
    fetchDeliveryRequests();
    super.onInit();
  }

  Future<void> fetchDeliveryRequests() async {
    try {
      isLoading(true);
      errorMessage("");
      log("📡 Fetching delivery requests...");

      final result = await DeliveryRequestService.getDeliveryRequests();

      if (result == null) {
        errorMessage("Failed to load requests.");
        log("⚠️ result == null");
      } else {
        requests = result.lstRequests;
        log("✅ Loaded ${requests.length} delivery requests");
      }
    } catch (e, stack) {
      errorMessage("An error occurred: $e");
      log("🔥 fetchDeliveryRequests Error: $e");
      log("$stack");
    } finally {
      isLoading(false);
      update();
    }
  }

  /// ==================================
  /// 🔹 Accept Delivery Request
  /// ==================================
  Future<void> acceptRequest(int id) async {
    try {
      selectedIdForUpdate = id;
      isUpdating(true);

      log("🚀 Accepting delivery request ID=$id");

      final success = await DeliveryRequestService.updateDeliveryRequest(
        id: id,
        status: 1, // ACCEPT
      );

      if (success) {
        showSuccess("Request has been accepted successfully");
        await fetchDeliveryRequests();
      } else {
        showError("An error occurred while accepting the request");
      }
    } catch (e, stack) {
      log("🔥 acceptRequest Error: $e");
      log("$stack");
      showError("Something went wrong!");
    } finally {
      isUpdating(false);
      selectedIdForUpdate = 0;
      update();
    }
  }

  /// ==================================
  /// 🔹 Reject Delivery Request
  /// ==================================
  Future<void> rejectRequest(int id, String reason) async {
    try {
      selectedIdForUpdate = id;
      isUpdating(true);

      log("🚫 Rejecting delivery request ID=$id Reason=$reason");

      final success = await DeliveryRequestService.updateDeliveryRequest(
        id: id,
        status: 2, // REJECT
        rejectReason: reason,
      );

      if (success) {
        showSuccess("Request has been rejected successfully");
        await fetchDeliveryRequests();
      } else {
        showError("Could not reject the request");
      }
    } catch (e, stack) {
      log("🔥 rejectRequest Error: $e");
      log("$stack");
      showError("Something went wrong!");
    } finally {
      isUpdating(false);
      selectedIdForUpdate = 0;
      update();
    }
  }

}
