import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ticket_app/ui/nav_bar_screen.dart';
import 'package:ticket_app/utils/my_shared_preferences.dart';
import '../model/custody/custody_model.dart';
import '../model/service_record/open_service_record_model.dart';
import '../model/ticket/response_model.dart';
import '../service/custody_service.dart';
import '../service/service_record_service.dart';

class ServiceRecordController extends GetxController {
  static ServiceRecordController get to =>
      Get.isRegistered<ServiceRecordController>()
      ? Get.find<ServiceRecordController>()
      : Get.put(ServiceRecordController());

  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var isClosing = false.obs;
  bool isRepair = true;
  String? selectedFault;
  String? selectedContentUsed;
  int serviceRecordId = 0;
  int ticketId = 0;
  String tripTime = '';
  int serviceLocation = 0;
  String repairNote = '';
  int serviceResult = 0;
  int unsolvedReasonId = 0;
  String? unsolvedNote = '';

  final TextEditingController repairNoteController = TextEditingController();
  final TextEditingController oldSerialNumber = TextEditingController();

  Rx<OpenServiceRecordModel?> openRecord = Rx<OpenServiceRecordModel?>(null);
  Rx<ResponseModel?> hardwareContent = Rx<ResponseModel?>(null);
  Rx<ResponseModel?> unsolvedReason = Rx<ResponseModel?>(null);

  bool validateReplace() {
    if (oldSerialNumber.text.trim().isEmpty) {
      Get.snackbar(
        "Missing Data",
        "Please enter Old Serial Number",
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFFFE0E0),
        colorText: const Color(0xFF5A0000),
      );
      return false;
    }

    if (selectedNewCustody == null) {
      Get.snackbar(
        "Missing Data",
        "Please select New Serial Number",
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFFFE0E0),
        colorText: const Color(0xFF5A0000),
      );
      return false;
    }

    return true;
  }

  RxBool isCustodyLoading = false.obs;
  RxString custodyError = ''.obs;

  RxList<CustodyData> custodyList = <CustodyData>[].obs;
  CustodyData? selectedNewCustody;

  @override
  void onInit() {
    fetchCustody();
    super.onInit();
  }

  Future<void> fetchCustody() async {
    try {
      isCustodyLoading(true);
      custodyError('');

      final result = await CustodyService.getCustody();

      if (result.custody.isNotEmpty) {
        custodyList.assignAll(result.custody);
        log('✅ Custody loaded: ${custodyList.length}');
      } else {
        custodyError('No custody items found');
      }
    } catch (e, stack) {
      custodyError('Failed to load custody');
      log('❌ Custody Exception: $e');
      log('$stack');
    } finally {
      isCustodyLoading(false);
    }
  }

  void changeTap(bool value) {
    if (value == isRepair) return;
    isRepair = value;
    selectedNewCustody = null;
    oldSerialNumber.text = "";
    repairNote = "";
    repairNoteController.text = "";
    update();
  }

  Future<void> fetchHardwareContent(int subProductFileId) async {
    try {
      isLoading(true);
      errorMessage('');
      log(
        '📡 Fetching hardware content for subProductFileId=$subProductFileId',
      );

      final result = await ServiceRecordService.getHardwareContent(
        subProductFileId,
      );

      if (result.lookupData.isNotEmpty) {
        hardwareContent.value = result;
        log('✅ Hardware content loaded successfully');
      } else {
        errorMessage('No hardware content found.');
        log('⚠️ Response returned an empty list.');
      }
    } catch (e, stack) {
      errorMessage('An error occurred: $e');
      log('❌ Exception in fetchHardwareContent: $e');
      log('$stack');
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchUnsolvedReasons(int subProductFileId) async {
    try {
      isLoading(true);
      errorMessage('');
      log(
        '📡 Fetching unsolved reasons for subProductFileId=$subProductFileId',
      );

      final result = await ServiceRecordService.getUnsolvedReason(
        subProductFileId,
      );

      if (result.lookupData.isNotEmpty) {
        unsolvedReason.value = result;
        log('✅ Unsolved reasons loaded successfully');
      } else {
        errorMessage('No unsolved reasons found.');
        log('⚠️ Response returned an empty list.');
      }
    } catch (e, stack) {
      errorMessage('An error occurred: $e');
      log('❌ Exception in fetchUnsolvedReasons: $e');
      log('$stack');
    } finally {
      isLoading(false);
    }
  }

  Future<void> repairServiceRecord({
    required String clientSignature,
    required String signatureName,
    bool back = false,
  }) async {
    try {
      isClosing(true);
      errorMessage('');
      log('🚀 Sending request to close service record for ticketId=$ticketId');

      final success = await ServiceRecordService.closeServiceRecord(
        serviceRecordId: serviceRecordId,
        ticketId: ticketId,
        repairNote: repairNote,
        serviceResult: serviceResult,
        unsolvedReasonId: unsolvedReasonId,
        unsolvedNote: unsolvedNote,
        tripTime: tripTime,
        clientSignature: clientSignature,
        signatureName: signatureName,
        intSolution: 0,
        serviceLocation: serviceLocation,
      );

      if (success) {
        if (back) Get.back();

        Get.offAll((() => NavBarScreen()));
        Get.snackbar(
          "Closed ✅",
          "Service record closed successfully.",
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFFD0F0C0),
          colorText: const Color(0xFF0D3D0D),
        );
        log('✅ Service record closed successfully.');
      } else {
        errorMessage('Failed to close service record.');
        Get.snackbar(
          "Failed ❌",
          "Could not close the service record. Please try again.",
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFFFFE0E0),
          colorText: const Color(0xFF5A0000),
        );
        log('⚠️ CloseServiceRecord returned false.');
      }
    } catch (e, stack) {
      errorMessage('An error occurred: $e');
      log('❌ Exception in closeServiceRecord: $e');
      log('$stack');
      Get.snackbar(
        "Error",
        "An unexpected error occurred while closing the service record.",
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFFFE0E0),
        colorText: const Color(0xFF5A0000),
      );
    } finally {
      isClosing(false);
    }
  }

  Future<void> replaceServiceRecord({
    required String clientSignature,
    required String signatureName,
  }) async {
    try {
      isClosing(true);
      errorMessage('');
      log('🚀 Sending request to close service record for ticketId=$ticketId');

      final success = await ServiceRecordService.closeServiceRecord(
        serviceRecordId: serviceRecordId,
        ticketId: ticketId,
        repairNote: repairNote,
        serviceResult: serviceResult,
        unsolvedReasonId: 0,
        unsolvedNote: "",
        tripTime: tripTime,
        clientSignature: clientSignature,
        signatureName: signatureName,
        intSolution: 1,
        custodyId: selectedNewCustody!.id,
        oldSerial: oldSerialNumber.text,
        intuserId: mySharedPreferences.getUserData()!.userId,
        serviceLocation: serviceLocation,
      );

      if (success) {
        Get.offAll((() => NavBarScreen()));
        Get.snackbar(
          "Closed ✅",
          "Service record closed successfully.",
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFFD0F0C0),
          colorText: const Color(0xFF0D3D0D),
        );
        log('✅ Service record closed successfully.');
      } else {
        errorMessage('Failed to close service record.');
        Get.snackbar(
          "Failed ❌",
          "Could not close the service record. Please try again.",
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFFFFE0E0),
          colorText: const Color(0xFF5A0000),
        );
        log('⚠️ CloseServiceRecord returned false.');
      }
    } catch (e, stack) {
      errorMessage('An error occurred: $e');
      log('❌ Exception in closeServiceRecord: $e');
      log('$stack');
      Get.snackbar(
        "Error",
        "An unexpected error occurred while closing the service record.",
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFFFE0E0),
        colorText: const Color(0xFF5A0000),
      );
    } finally {
      isClosing(false);
    }
  }
}
