import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../model/delivery_request/request_model.dart';
import '../model/ticket/response_model.dart';
import '../service/history_request_service.dart';
import '../service/request_part_service.dart';
import '../utils/snackbar.dart';
import 'history_request_controller.dart';

class EditRequestController extends GetxController {
  final LstRequest item;

  EditRequestController(this.item);

  // --------------------
  // Text Controllers
  // --------------------
  late TextEditingController partNumber;
  late TextEditingController description;
  late TextEditingController customerName;
  late TextEditingController branch;

  // --------------------
  // Dropdown Data
  // --------------------
  var subProducts = <LookupDatum>[].obs;
  var contents = <LookupDatum>[].obs;

  var selectedSubProduct = Rxn<LookupDatum>();
  var selectedContent = Rxn<LookupDatum>();

  // --------------------
  // States
  // --------------------
  var isLoadingSubProducts = false.obs;
  var isLoadingContents = false.obs;
  var isSubmitting = false.obs;

  @override
  void onInit() {
    super.onInit();

    partNumber = TextEditingController(text: item.partNumber);
    description = TextEditingController(text: item.description);
    customerName = TextEditingController(text: item.customerName);
    branch = TextEditingController(text: item.branch);

    loadSubProducts();
  }

  // --------------------
  // Load Sub Products
  // --------------------
  Future<void> loadSubProducts() async {
    isLoadingSubProducts.value = true;

    final result = await RequestPartService.getSubProducts();
    subProducts.value = result.lookupData;

    // auto select related sub product if exists
    selectedSubProduct.value = subProducts.firstWhereOrNull(
      (e) => e.intLookupId == item.contentId,
    );

    if (selectedSubProduct.value != null) {
      await loadContents(selectedSubProduct.value!.intLookupId);
    }

    isLoadingSubProducts.value = false;
  }

  // --------------------
  // Load Contents
  // --------------------
  Future<void> loadContents(int subProductId) async {
    isLoadingContents.value = true;

    final result = await RequestPartService.getContentBySubProduct(
      subProductId,
    );

    contents.value = result.lookupData;

    selectedContent.value = contents.firstWhereOrNull(
      (e) => e.intLookupId == item.contentId,
    );

    isLoadingContents.value = false;
  }

  // --------------------
  // Update Request
  // --------------------
  Future<void> updateRequest() async {
    isSubmitting.value = true;

    final int contentIdToSend =
        selectedContent.value?.intLookupId ?? item.contentId;

    final success = await HistoryRequestService.updateCustodyRequest(
      id: item.id,
      partNumber: partNumber.text,
      description: description.text,
      customerName: customerName.text,
      branch: branch.text,
      contentId: contentIdToSend, // 👈 القديم أو الجديد
      updateDate: _formatDate(DateTime.now()),
    );

    isSubmitting.value = false;

    if (success) {
      Get.back(result: true);

      final HistoryRequestController controller =
      Get.find<HistoryRequestController>();
      controller.getHistoryRequests(0);

      showSuccess("Request updated successfully");
    } else {
      showError("Update failed");
    }

  }

  String _formatDate(DateTime date) => "${date.day}/${date.month}/${date.year}";
}
