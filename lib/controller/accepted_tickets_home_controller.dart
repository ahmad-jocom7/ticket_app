import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ticket_app/ui/dashboard/screens/open_service_record_screen.dart';

import '../model/service_record/assign_ticket_model.dart';
import '../service/service_record_service.dart';

class AcceptedTicketHomeController extends GetxController {
  static AcceptedTicketHomeController get to =>
      Get.isRegistered<AcceptedTicketHomeController>()
      ? Get.find<AcceptedTicketHomeController>()
      : Get.put(AcceptedTicketHomeController());

  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var isOpening = false.obs;
  var isRejected = false.obs;
  RxBool showInProgress = true.obs;
  RxBool showAccepted = true.obs;

  var hasOpenedRecord = false.obs;

  void checkOpenedRecord(List<LstTicket> tickets) {
    hasOpenedRecord.value =
        tickets.any((e) => e.ticketInfo.intServiceRecordID != 0);
  }
  List<LstTicket> data = [];
  final TextEditingController ticketIdController = TextEditingController();

  // 📅 Date filters
  DateTime fromDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime toDate = DateTime.now();

  Future<void> fetchAcceptedTickets() async {
    try {
      isLoading(true);
      errorMessage('');

      final ticketId = ticketIdController.text.trim().isEmpty
          ? 0
          : int.tryParse(ticketIdController.text.trim()) ?? 0;

      final from = fromDate == null
          ? '0'
          : '${fromDate.day.toString().padLeft(2, '0')}/'
          '${fromDate.month.toString().padLeft(2, '0')}/'
          '${fromDate.year}';

      final to = toDate == null
          ? '0'
          : '${toDate.day.toString().padLeft(2, '0')}/'
          '${toDate.month.toString().padLeft(2, '0')}/'
          '${toDate.year}';

      log('🎬 Fetching accepted tickets...');
      log('➡️ Filters: ticketId=$ticketId | from=$from | to=$to');

      final result =
      await ServiceRecordService.getAcceptedTicketsByEmployee(
        ticketId: ticketId,
        fromDate: from,
        toDate: to,
      );

      if (result != null) {
        data = result.lstTicket;
        checkOpenedRecord(data);
        log('✅ Tickets loaded: ${data.length}');
      } else {
        errorMessage('Failed to load accepted tickets.');
      }
    } catch (e, stack) {
      errorMessage('An error occurred: $e');
      log('❌ Exception: $e');
      log('$stack');
    } finally {
      update();
      isLoading(false);
    }
  }

  // Future<void> fetchAcceptedTicketsHome() async {
  //   try {
  //     isLoading(true);
  //     errorMessage('');
  //
  //     log('🎬 Fetching accepted tickets from server...');
  //
  //     final result = await ServiceRecordService.getAcceptedTicketsByEmployee();
  //
  //     if (result != null) {
  //       data = result.lstTicket;
  //       log('✅ Data received successfully: ${result.toJson()}');
  //     } else {
  //       errorMessage('Failed to load accepted tickets.');
  //       log('⚠️ No tickets found.');
  //     }
  //   } catch (e, stack) {
  //     errorMessage('An error occurred: $e');
  //     log('❌ Exception in fetchAcceptedTickets: $e');
  //     log('$stack');
  //   } finally {
  //     update();
  //
  //     isLoading(false);
  //   }
  // }

  Future<void> openServiceRecord(int ticketId, int subProductFileId) async {
    try {
      isOpening(true);
      log('🚀 Sending request to open service record for ticketId=$ticketId');

      final result = await ServiceRecordService.openServiceRecord(
        ticketId: ticketId,
      );

      if (result.status == 200) {
        Get.to(
          () => OpenServiceRecordScreen(
            recordId: result.serviceRecordId,
            ticketId: ticketId,
            subProductFileId: subProductFileId,
          ),
        );
        Get.snackbar(
          "Opened Successfully ✅",
          "Service record has been opened for ticket #$ticketId",
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFFD0F0C0),
          colorText: const Color(0xFF0D3D0D),
        );

        fetchAcceptedTickets();
      } else {
        Get.snackbar(
          "Failed ❌",
          "Could not open service record. Please try again.",
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFFFFE0E0),
          colorText: const Color(0xFF5A0000),
        );
      }
    } catch (e, stack) {
      log('❌ Error in openServiceRecord: $e');
      log('$stack');
      Get.snackbar(
        "Error",
        "An exception occurred while opening the service record.",
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFFFE0E0),
        colorText: const Color(0xFF5A0000),
      );
    } finally {
      update();
      isOpening(false);
    }
  }

  Future<void> viewServiceRecord(
    int serviceRecordId,
    int ticketId,
    int subProductFileId,
  ) async {
    try {
      isOpening(true);
      log(
        '🚀 Sending request to open service record for ticketId=$serviceRecordId',
      );

      final result = await ServiceRecordService.getServiceRecordById(
        serviceRecordId,
      );

      if (result.serviceRecords?.intServiceRecordId != null) {
        Get.to(
          () => OpenServiceRecordScreen(
            recordId: result.serviceRecords!.intServiceRecordId!,
            ticketId: ticketId,
            subProductFileId: subProductFileId,
            recordData: result.serviceRecords!.strRecordDate,
          ),
        );
        Get.snackbar(
          "Record Loaded 🎯",
          "Service record for ticket #$ticketId has been successfully loaded",
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFFD0F0C0),
          colorText: const Color(0xFF0D3D0D),
        );

        fetchAcceptedTickets();
      } else {
        Get.snackbar(
          "No Record Found ⚠️",
          "Could not retrieve the service record. Please check again.",
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFFFFE0E0),
          colorText: const Color(0xFF5A0000),
        );
      }
    } catch (e, stack) {
      log('❌ Error in openServiceRecord: $e');
      log('$stack');
      Get.snackbar(
        "Unexpected Error ❌",
        "Something went wrong while fetching the service record. Please try again later.",
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFFFE0E0),
        colorText: const Color(0xFF5A0000),
      );
    } finally {
      isOpening(false);
    }
  }

  Future<void> rejectTicket(int intId, String rejectNote) async {
    try {
      isRejected.value = true;
      log('🚀 Sending request to reject ticket intId=$intId, note=$rejectNote');

      final success = await ServiceRecordService.updateAssignTicket(
        intId: intId,
        status: 2,
        intAccept: 0,
        rejectNote: rejectNote,
      );

      if (success) {
        Get.back();
        Get.snackbar(
          "Rejected 🚫",
          "The ticket has been rejected successfully.",
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFFD0F0C0),
          colorText: const Color(0xFF0D3D0D),
        );
        await fetchAcceptedTickets();
      } else {
        Get.snackbar(
          "Operation Failed ❌",
          "An error occurred while rejecting the ticket.",
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFFFFE0E0),
          colorText: const Color(0xFF5A0000),
        );
      }
    } catch (e, stack) {
      log('❌ Error in rejectTicket: $e');
      log('$stack');
      Get.snackbar(
        "Error",
        "An exception occurred while rejecting the ticket.",
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFFFE0E0),
        colorText: const Color(0xFF5A0000),
      );
    } finally {
      isRejected.value = false;
    }
  }
  @override
  void onClose() {
    ticketIdController.dispose();
    super.onClose();
  }

}
