import 'dart:developer';
import 'dart:ui';
import 'package:get/get.dart';
import 'package:ticket_app/controller/accepted_tickets_controller.dart';
import 'package:ticket_app/controller/main_controller.dart';
import 'package:ticket_app/ui/nav_bar_screen.dart';

import '../model/service_record/assign_ticket_model.dart';
import '../service/service_record_service.dart';
import 'accepted_tickets_home_controller.dart';

class AssignedTicketController extends GetxController {
  static AssignedTicketController get to =>
      Get.isRegistered<AssignedTicketController>()
      ? Get.find<AssignedTicketController>()
      : Get.put(AssignedTicketController());

  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var isUpdating = false.obs; // Track update state during Accept or Reject
  var acceptAssignId = RxInt(0);
  var rejectAssignId = RxInt(0);
  RxBool showAssigned = true.obs;

  List<LstTicket> data = [];

  @override
  void onInit() {
    fetchAssignedTickets();
    super.onInit();
  }

  Future<void> fetchAssignedTickets() async {
    try {
      isLoading(true);
      errorMessage('');

      log('🎬 Fetching assigned tickets from server...');

      final result = await ServiceRecordService.getAssignedTicketsByEmployee();

      if (result != null) {
        data = result.lstTicket;
        log('✅ Data received successfully: ${result.toJson()}');
      } else {
        errorMessage('Failed to load assigned tickets.');
        log('⚠️ No tickets found.');
      }
    } catch (e, stack) {
      errorMessage('An error occurred: $e');
      log('❌ Exception in fetchAssignedTickets: $e');
      log('$stack');
    } finally {
      update();
      isLoading(false);
    }
  }

  Future<void> acceptTicket(int intId) async {
    try {
      acceptAssignId.value = intId;
      log('🚀 Sending request to accept ticket intId=$intId');

      final success = await ServiceRecordService.updateAssignTicket(
        intId: intId,
        status: 3,
        intAccept: 1,
      );

      if (success) {
        Get.snackbar(
          "Accepted ✅",
          "The ticket has been accepted successfully.",
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFFD0F0C0),
          colorText: const Color(0xFF0D3D0D),
        );
        if (data.length == 1) {
          MainController.to.selected = 0;
          Get.off(() => NavBarScreen());
        }
        await fetchAssignedTickets();
        await AcceptedTicketController.to.fetchAcceptedTickets();
        await AcceptedTicketHomeController.to.fetchAcceptedTickets();
      } else {
        Get.snackbar(
          "Operation Failed ❌",
          "An error occurred while accepting the ticket.",
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFFFFE0E0),
          colorText: const Color(0xFF5A0000),
        );
      }
    } catch (e, stack) {
      log('❌ Error in acceptTicket: $e');
      log('$stack');
      Get.snackbar(
        "Error",
        "An exception occurred while accepting the ticket.",
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFFFE0E0),
        colorText: const Color(0xFF5A0000),
      );
    } finally {
      update();
      acceptAssignId.value = 0;
    }
  }

  Future<void> rejectTicket(int intId, String rejectNote) async {
    try {
      rejectAssignId.value = intId;
      log('🚀 Sending request to reject ticket intId=$intId, note=$rejectNote');

      final success = await ServiceRecordService.updateAssignTicket(
        intId: intId,
        status: 2,
        intAccept: 0,
        rejectNote: rejectNote,
      );

      if (success) {
        Get.snackbar(
          "Rejected 🚫",
          "The ticket has been rejected successfully.",
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFFD0F0C0),
          colorText: const Color(0xFF0D3D0D),
        );
        await fetchAssignedTickets();
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
      update();
      rejectAssignId.value = 0;
    }
  }
}
