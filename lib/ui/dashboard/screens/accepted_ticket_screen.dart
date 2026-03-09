import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../utils/color_app.dart';
import '../../../controller/accepted_tickets_controller.dart';
import '../widgets/accepted_ticket_card.dart'; // للتأكد من أن الموديل معروف

class AcceptedTicketsScreen extends StatelessWidget {
   AcceptedTicketsScreen({super.key});

  final  controller = AcceptedTicketController.to;

  // @override
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: const Text("Accepted Tickets")),
      body: Column(
        children: [
          // 🔍 Filters
          Padding(
            padding: const EdgeInsets.all(12),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: isDark
                    ? []
                    : [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // 🔎 Ticket ID
                  TextField(
                    controller: controller.ticketIdController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Ticket ID",
                      hintText: "Search by ticket number",
                      prefixIcon: Icon(
                        Icons.confirmation_number_outlined,
                        color: ColorApp.primary,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.search, color: ColorApp.primary),
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          controller.fetchAcceptedTickets();
                        },
                      ),
                      filled: true,
                      fillColor:
                      isDark ? theme.colorScheme.surface : Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: ColorApp.primary.withValues(alpha: 0.25),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: ColorApp.primary.withValues(alpha: 0.25),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: ColorApp.primary, width: 1.4),
                      ),
                    ),
                    onSubmitted: (_) => controller.fetchAcceptedTickets(),
                  ),

                  const SizedBox(height: 12),

                  // 📅 Date range
                  GetBuilder<AcceptedTicketController>(
                    builder: (_) {
                      return Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: controller.fromDate,
                                  firstDate: DateTime(2020),
                                  lastDate: controller.toDate,
                                  builder: (context, child) {
                                    return Theme(
                                      data: theme,
                                      child: child!,
                                    );
                                  },
                                );

                                if (picked != null &&
                                    !DateUtils.isSameDay(
                                      controller.fromDate,
                                      picked,
                                    )) {
                                  controller.fromDate = picked;
                                  controller.fetchAcceptedTickets();
                                }
                              },
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: "From Date",
                                  prefixIcon: Icon(
                                    Icons.date_range_outlined,
                                    color: ColorApp.primary,
                                  ),
                                  filled: true,
                                  fillColor: isDark
                                      ? theme.colorScheme.surface
                                      : Colors.grey.shade50,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide(
                                      color:
                                      ColorApp.primary.withValues(alpha: 0.25),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide(
                                      color:
                                      ColorApp.primary.withValues(alpha: 0.25),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide:
                                    BorderSide(color: ColorApp.primary, width: 1.4),
                                  ),
                                ),
                                child: Text(
                                  "${controller.fromDate.day.toString().padLeft(2, '0')}/"
                                      "${controller.fromDate.month.toString().padLeft(2, '0')}/"
                                      "${controller.fromDate.year}",
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: controller.toDate,
                                  firstDate: controller.fromDate,
                                  lastDate: DateTime.now(),
                                  builder: (context, child) {
                                    return Theme(
                                      data: theme,
                                      child: child!,
                                    );
                                  },
                                );

                                if (picked != null &&
                                    !DateUtils.isSameDay(
                                      controller.toDate,
                                      picked,
                                    )) {
                                  controller.toDate = picked;
                                  controller.fetchAcceptedTickets();
                                }
                              },
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: "To Date",
                                  prefixIcon: Icon(
                                    Icons.date_range_outlined,
                                    color: ColorApp.primary,
                                  ),
                                  filled: true,
                                  fillColor: isDark
                                      ? theme.colorScheme.surface
                                      : Colors.grey.shade50,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide(
                                      color:
                                      ColorApp.primary.withValues(alpha: 0.25),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide(
                                      color:
                                      ColorApp.primary.withValues(alpha: 0.25),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide:
                                    BorderSide(color: ColorApp.primary, width: 1.4),
                                  ),
                                ),
                                child: Text(
                                  "${controller.toDate.day.toString().padLeft(2, '0')}/"
                                      "${controller.toDate.month.toString().padLeft(2, '0')}/"
                                      "${controller.toDate.year}",
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),


          const SizedBox(height: 6),

          // 📋 Tickets List
          Expanded(
            child: Obx(() {
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
                return const Center(
                  child: Text("No accepted tickets available."),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.data.length,
                itemBuilder: (context, index) {
                  return AcceptedTicketCard(data: controller.data[index]);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _dateButton(
    BuildContext context, {
    required String label,
    required DateTime? date,
    required ValueChanged<DateTime> onPicked,
  }) {
    return OutlinedButton.icon(
      icon: const Icon(Icons.date_range),
      label: Text(
        date == null ? label : '${date.day}/${date.month}/${date.year}',
      ),
      onPressed: () async {
        final picked = await showDatePicker(
          context: context,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
          initialDate: date ?? DateTime.now(),
        );
        if (picked != null) {
          onPicked(picked);
        }
      },
    );
  }
}

void showRejectDialog(int ticketId) {
  final TextEditingController rejectController = TextEditingController();
  final controller = Get.find<AcceptedTicketController>();

  final theme = Get.theme;
  final isDark = theme.brightness == Brightness.dark;

  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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

              // 🔹 TextField
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
                    borderSide: BorderSide(
                      color: theme.dividerColor,
                      width: 0.1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: theme.dividerColor,
                      width: 0.1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: ColorApp.primary, width: 0.3),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 🔹 Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.colorScheme.onSurface,
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
                    child: Obx(() {
                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorApp.primary,
                          foregroundColor: Colors.white,
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
                                    backgroundColor: isDark
                                        ? Colors.orange.shade700
                                        : Colors.yellow.shade100,
                                    colorText: isDark
                                        ? Colors.white
                                        : Colors.black87,
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
                                style: TextStyle(fontWeight: FontWeight.w600),
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
    barrierDismissible: false,
  );
}
