import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../utils/color_app.dart';
import '../../../controller/accepted_tickets_controller.dart';
import '../../../model/service_record/assign_ticket_model.dart';
import '../widgets/accepted_ticket_card.dart'; // للتأكد من أن الموديل معروف

class AcceptedTicketsScreen extends StatefulWidget {
  const AcceptedTicketsScreen({super.key});

  @override
  State<AcceptedTicketsScreen> createState() => _AcceptedTicketsScreenState();
}

class _AcceptedTicketsScreenState extends State<AcceptedTicketsScreen> {
  final AcceptedTicketController controller = Get.put(
    AcceptedTicketController(),
  );

  @override
  void initState() {
    super.initState();
    controller.fetchAcceptedTickets();
  }

  @override
  Widget build(BuildContext context) {
    const bgLight = Color(0xFFF5F6FA);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("Accepted Tickets")),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.errorMessage.isNotEmpty) {
          return Center(
            child: Text(
              controller.errorMessage.value,
              style: TextStyle(color: ColorApp.primary),
            ),
          );
        }
        if (controller.data.isEmpty) {
          return const Center(child: Text("No accepted tickets available."));
        }
        return Container(
          color: bgLight,
          padding: const EdgeInsets.all(16),
          child: ListView.builder(
            itemCount: controller.data.length,
            itemBuilder: (context, index) {
              final LstTicket ticket = controller.data[index];

              return AcceptedTicketCard(data: ticket);
            },
          ),
        );
      }),
    );
  }
}


void showRejectDialog(int ticketId) {
  final TextEditingController rejectController = TextEditingController();
  final controller = Get.find<AcceptedTicketController>();

  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 25),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 🔹 Title
              Row(
                children: [
                  Icon(Icons.cancel_outlined, color: Colors.red, size: 28),
                  SizedBox(width: 8),
                  Text(
                    "Reject Ticket",
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Text(
                "Please provide a reason for rejecting this ticket. "
                "This note will be sent to the server for record keeping.",
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 14.2,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: rejectController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Enter rejection reason...",
                  hintStyle: const TextStyle(color: Colors.black45),
                  filled: true,
                  fillColor: const Color(0xFFF9FAFB),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: ColorApp.primary, width: 1.4),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.grey, width: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Obx(() {
                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorApp.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        onPressed: controller.isRejected.value
                            ? null
                            : () async {
                                final note = rejectController.text.trim();

                                if (note.isEmpty) {
                                  Get.snackbar(
                                    "Missing Reason ⚠️",
                                    "Please enter a reason before rejecting.",
                                    snackPosition: SnackPosition.TOP,
                                    backgroundColor: Colors.yellow.shade100,
                                    colorText: Colors.black87,
                                  );
                                  return;
                                }
                                await controller.rejectTicket(ticketId, note);
                              },
                        child: controller.isRejected.value
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                "Confirm",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      );
                    }),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
    barrierDismissible: false, // prevent accidental close
  );
}
