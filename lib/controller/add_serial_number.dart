import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../model/ticket/response_model.dart';
import '../../../service/ticket_service.dart';

class AddSerialFromTicketController extends GetxController {

  late String customerId;

  /// Loading
  RxBool isLoading = false.obs;

  /// Product Categories
  RxList<LookupDatum> productCategories = <LookupDatum>[].obs;
  RxnInt selectedCategoryId = RxnInt();

  /// Sub Products
  RxList<LookupDatum> subProducts = <LookupDatum>[].obs;
  RxnInt selectedSubProductId = RxnInt();

  /// Serial
  TextEditingController serialController = TextEditingController();

  /// Note
  TextEditingController noteController = TextEditingController();

  /// Init
  void init(String customerIdParam) {
    customerId = customerIdParam;
    loadProductCategories();
  }

  /// Load Categories
  Future<void> loadProductCategories() async {
    isLoading(true);

    final result = await TicketService.getProductCategory();

    productCategories.assignAll(result.lookupData ?? []);

    isLoading(false);
  }

  /// Select Category
  Future<void> onCategorySelected(int id) async {
    selectedCategoryId.value = id;

    isLoading(true);

    final result = await TicketService.getSubProductByCategory(id);

    subProducts.assignAll(result.lookupData ?? []);

    isLoading(false);
  }

  /// Select SubProduct
  void onSubProductSelected(int id) {
    selectedSubProductId.value = id;
  }

  /// Submit
  Future<bool> submit() async {
    if (selectedSubProductId.value == null) {
      Get.snackbar("Error", "Please select sub product");
      return false;
    }

    if (serialController.text.isEmpty) {
      Get.snackbar("Error", "Enter Serial Number");
      return false;
    }

    isLoading(true);

    final result = await TicketService.addSerialFromTicket(
      subProductId: selectedSubProductId.value!,
      customerId: customerId,
      serialNumber: serialController.text,
      note: noteController.text,
    );

    isLoading(false);

    if (result) {
      Get.back(result: true);
    }

    return result;
  }
}