import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ticket_app/utils/my_shared_preferences.dart';
import 'package:ticket_app/utils/snackbar.dart';

import '../model/ticket/response_model.dart';
import '../service/request_part_service.dart';

class RequestPartsController extends GetxController {
  static RequestPartsController get to =>
      Get.isRegistered<RequestPartsController>()
      ? Get.find<RequestPartsController>()
      : Get.put(RequestPartsController());

  var isLoadingSubProducts = false.obs;
  var isLoadingContents = false.obs;
  var isLoadingEmployees = false.obs;
  var isSubmitting = false.obs;

  List<LookupDatum> subProducts = [];
  List<LookupDatum> contents = [];
  List<LookupDatum> employees = [];

  Rxn<LookupDatum> selectedSubProduct = Rxn<LookupDatum>();
  Rxn<LookupDatum> selectedContent = Rxn<LookupDatum>();
  Rxn<LookupDatum> selectedEmployee = Rxn<LookupDatum>(
    LookupDatum(intLookupId: 0, strLookupId: "0", strLookupText: "Workshop"),
  );

  final partNumber = TextEditingController();
  final description = TextEditingController();
  final customerName = TextEditingController();
  final branch = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadSubProducts();
    loadEmployees();
  }

  Future<void> loadSubProducts() async {
    isLoadingSubProducts.value = true;

    final result = await RequestPartService.getSubProducts();

    subProducts = result.lookupData;
    isLoadingSubProducts.value = false;
  }

  Future<void> loadContents(int subProductId) async {
    isLoadingContents.value = true;

    final result = await RequestPartService.getContentBySubProduct(
      subProductId,
    );

    contents = result.lookupData;
    isLoadingContents.value = false;
  }

  Future<void> loadEmployees() async {
    isLoadingEmployees.value = true;

    final result = await RequestPartService.getEmployee();

    employees = result.lookupData;
    employees.insert(
      0,
      LookupDatum(
        intLookupId: 0, // رقم مميز لأنه ليس من السيرفر
        strLookupId: "0",
        strLookupText: "Workshop",
      ),
    );

    isLoadingEmployees.value = false;
  }

  // ================================
  // 🔹 Validate before submitting
  // ================================
  bool validate() {
    List<String> missingFields = [];

    // TEXT FIELDS
    if (partNumber.text.isEmpty) {
      missingFields.add("Part Number");
    }
    if (description.text.isEmpty) {
      missingFields.add("Description");
    }
    if (customerName.text.isEmpty) {
      missingFields.add("Customer Name");
    }
    if (branch.text.isEmpty) {
      missingFields.add("Branch");
    }

    // DROPDOWNS
    if (selectedSubProduct.value == null) {
      missingFields.add("Sub Product");
    }
    if (selectedContent.value == null) {
      missingFields.add("Content");
    }
    if (selectedEmployee.value == null) {
      missingFields.add("Employee");
    }

    // SHOW ERROR MESSAGE
    if (missingFields.isNotEmpty) {
      String fields = missingFields.join(", ");

      Get.snackbar(
        'Missing Required Fields',
        '$fields ${missingFields.length > 1 ? "are" : "is"} required.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.black87,
        duration: const Duration(seconds: 4),
        icon: const Icon(Icons.warning_amber_rounded, color: Colors.orange),
        margin: const EdgeInsets.all(12),
        borderRadius: 12,
      );

      return false;
    }

    return true;
  }

  Future<void> submitRequest() async {
    if (!validate()) return;

    isSubmitting.value = true;

    final response = await RequestPartService.sendRequest(
      fromEmployeeId: mySharedPreferences.getUserData()!.employeeId,
      toEmployeeId: selectedEmployee.value!.intLookupId,
      partNumber: partNumber.text,
      description: description.text,
      customerName: customerName.text,
      branch: branch.text,
      contentId: selectedContent.value!.intLookupId,
      type: 1,
    );

    isSubmitting.value = false;

    if (response["status"] == 200) {
      Get.back();

      showSuccess("Request sent successfully");
      resetForm();
    } else {
      showError(response["message"] ?? "Something went wrong");
    }
  }

  void resetForm() {
    selectedSubProduct.value = null;
    selectedContent.value = null;
    selectedEmployee.value = null;

    partNumber.clear();
    description.clear();
    customerName.clear();
    branch.clear();
  }
}
