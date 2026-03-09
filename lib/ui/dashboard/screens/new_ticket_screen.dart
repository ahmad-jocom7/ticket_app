import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/color_app.dart';
import '../../../controller/assigned_tickets_controller.dart';
import '../widgets/assigned_ticket_card.dart';

class AssignedTicketsScreen extends StatefulWidget {
  const AssignedTicketsScreen({super.key});

  @override
  State<AssignedTicketsScreen> createState() => _AssignedTicketsScreenState();
}

class _AssignedTicketsScreenState extends State<AssignedTicketsScreen> {
  final AssignedTicketController controller = Get.put(
    AssignedTicketController(),
  );

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchAssignedTickets();
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Assigned Tickets")),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.isNotEmpty) {
          return Center(
            child: Text(
              controller.errorMessage.value,
              style: const TextStyle(color: Colors.red),
            ),
          );
        }
        if (controller.data.isEmpty) {
          return const Center(child: Text("No assigned tickets available."));
        }
        return Container(
          padding: const EdgeInsets.all(16),
          child: ListView.builder(
            itemCount: controller.data.length,
            itemBuilder: (context, index) {
              final ticket = controller.data[index];
              return AssignedTicketCard(
                data: ticket.ticketInfo,
                assignId: ticket.intId,
              );
            },
          ),
        );
      }),
    );
  }
}

void showRejectDialog(BuildContext context, int ticketId) {
  final TextEditingController rejectController = TextEditingController();
  final controller = Get.find<AssignedTicketController>();

  Get.dialog(
    Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: theme.dialogTheme.backgroundColor,
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
                      const Icon(
                        Icons.cancel_outlined,
                        color: Colors.red,
                        size: 28,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Reject Ticket",
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // 🔹 Description
                  Text(
                    "Please provide a reason for rejecting this ticket. "
                    "This note will be sent to the server for record keeping.",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.4,
                      color: theme.textTheme.bodyMedium?.color?.withValues(
                        alpha: 0.85,
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // 🔹 Text Field
                  TextField(
                    controller: rejectController,
                    maxLines: 3,
                    style: theme.textTheme.bodyMedium,
                    decoration: InputDecoration(
                      hintText: "Enter rejection reason...",
                      hintStyle: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.hintColor,
                      ),
                      filled: true,
                      fillColor: isDark
                          ? theme.colorScheme.surface
                          : const Color(0xFFF9FAFB),
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
                        borderSide: BorderSide(
                          color: ColorApp.primary,
                          width: 1.4,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 🔹 Buttons Row
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Get.back(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: theme.textTheme.bodyMedium?.color,
                            side: BorderSide(color: theme.dividerColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          child: const Text(
                            "Cancel",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorApp.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          onPressed: () async {
                            final note = rejectController.text.trim();

                            if (note.isEmpty) {
                              Get.snackbar(
                                "Missing Reason ⚠️",
                                "Please enter a reason before rejecting.",
                                snackPosition: SnackPosition.TOP,
                                backgroundColor: isDark
                                    ? Colors.orange.shade700
                                    : Colors.yellow.shade100,
                                colorText: isDark
                                    ? Colors.white
                                    : Colors.black87,
                              );
                              return;
                            }

                            Get.back();
                            await controller.rejectTicket(ticketId, note);
                          },
                          child: const Text(
                            "Confirm",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
    barrierDismissible: false,
  );
}
