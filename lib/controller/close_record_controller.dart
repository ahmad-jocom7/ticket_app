import 'dart:developer';
import 'dart:ui';
import 'package:get/get.dart';
import 'package:ticket_app/ui/nav_bar_screen.dart';
import '../model/service_record/open_service_record_model.dart';
import '../model/ticket/response_model.dart';
import '../service/service_record_service.dart';

class ServiceRecordController extends GetxController {
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var isClosing = false.obs;

  Rx<OpenServiceRecordModel?> openRecord = Rx<OpenServiceRecordModel?>(null);
  Rx<ResponseModel?> hardwareContent = Rx<ResponseModel?>(null);
  Rx<ResponseModel?> unsolvedReason = Rx<ResponseModel?>(null);

  Future<void> fetchHardwareContent(int subProductFileId) async {
    try {
      isLoading(true);
      errorMessage('');
      log(
        '📡 Fetching hardware content for subProductFileId=$subProductFileId',
      );

      final result = await TicketService.getHardwareContent(subProductFileId);

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

      final result = await TicketService.getUnsolvedReason(subProductFileId);

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

  int serviceRecordId = 0;
  int ticketId = 0;
  String tripTime = '';

  String repairNote = '';
  int serviceResult = 0;
  int unsolvedReasonId = 0;
  String? unsolvedNote = '';

  Future<void> closeServiceRecord({
    required String clientSignature,
    required String signatureName,
  }) async {
    try {
      isClosing(true);
      errorMessage('');
      log('🚀 Sending request to close service record for ticketId=$ticketId');

      final success = await TicketService.closeServiceRecord(
        serviceRecordId: serviceRecordId,
        ticketId: ticketId,
        repairNote: repairNote,
        serviceResult: serviceResult,
        unsolvedReasonId: unsolvedReasonId,
        unsolvedNote: unsolvedNote,
        tripTime: tripTime,
        clientSignature: clientSignature,
        signatureName: signatureName,
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
