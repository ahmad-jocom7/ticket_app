import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ticket_app/controller/delivery_request_controller.dart';
import 'package:ticket_app/model/delivery_request/request_model.dart';
import 'package:ticket_app/utils/color_app.dart';

import '../../utils/snackbar.dart';
import '../../utils/text_style.dart';

class DeliveryRequestScreen extends StatelessWidget {
   DeliveryRequestScreen({super.key});

  final controller = DeliveryRequestController.to;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Delivery Requests")),
      body: GetBuilder<DeliveryRequestController>(
        builder: (_) {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.errorMessage.isNotEmpty) {
            return Center(
              child: Text(
                controller.errorMessage.value,
                // style: const TextStyle(fontSize: 16, color: Colors.red),
              ),
            );
          }
          if (controller.requests.isEmpty) {
            return const Center(
              child: Text(
                "No delivery requests available",
                // style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: controller.fetchDeliveryRequests,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: controller.requests.length,
              itemBuilder: (_, index) {
                return _requestCard(controller.requests[index], controller);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _requestCard(LstRequest item, DeliveryRequestController controller) {
    final theme = Get.theme;

    final isDark = theme.brightness == Brightness.dark;
    final cardColor = theme.cardColor;
    final dividerColor = theme.dividerColor;
    final primaryTextColor = theme.textTheme.bodyMedium?.color;

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        // ✅ changed: card background from theme
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          width: 0.2,
          // ✅ changed
          color: dividerColor,
        ),
        boxShadow: [
          BoxShadow(
            // ✅ changed: softer shadow in dark mode
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 HEADER
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                // ✅ changed: adaptive background
                backgroundColor: ColorApp.primary.withValues(
                  alpha: isDark ? 0.18 : 0.1,
                ),
                child: Icon(
                  Icons.inventory_2_outlined,
                  color: ColorApp.primary,
                  size: 26,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  item.partNumber,
                  // ✅ changed: shared text style
                  style: bold18.copyWith(color: primaryTextColor),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ✅ changed: divider color from theme
          Divider(height: 1, color: dividerColor.withValues(alpha: 0.2)),

          const SizedBox(height: 12),

          _row("Content", item.contentName),
          _row("Description", item.description),
          _row("Requested By", item.fromEmployeeName),
          _row("Customer", item.customerName.isEmpty ? "-" : item.customerName),
          _row("Branch", item.branch.isEmpty ? "-" : item.branch),
          _row("Date", item.dateTime.toString().split(".")[0]),

          const SizedBox(height: 14),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // 🔴 REJECT BUTTON
              TextButton.icon(
                onPressed: () => showDeliveryRejectDialog(item.id),
                icon: const Icon(Icons.close, color: Colors.red),
                label: Text(
                  "Reject",
                  // ✅ changed
                  style: semibold14.copyWith(color: Colors.red),
                ),
              ),

              const SizedBox(width: 10),

              // 🟢 ACCEPT BUTTON
              ElevatedButton.icon(
                onPressed: () => controller.acceptRequest(item.id),
                icon: const Icon(Icons.check_circle_outline),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorApp.primary,
                ),
                label: Text(
                  "Accept",
                  // ✅ changed
                  style: semibold14.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _row(String title, String value) {
    // ✅ changed: get theme-based colors once
    final theme = Get.theme;

    final primaryTextColor = theme.textTheme.bodyMedium?.color;
    final secondaryTextColor = theme.textTheme.bodySmall?.color;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              "$title:",
              // ✅ changed: use shared text style + theme color
              style: semibold14.copyWith(color: primaryTextColor),
            ),
          ),
          Expanded(
            child: Text(
              value,
              // ✅ changed: use shared text style + secondary theme color
              style: regular14.copyWith(color: secondaryTextColor),
            ),
          ),
        ],
      ),
    );
  }

  void showDeliveryRejectDialog(int requestId) {
    final TextEditingController reasonCtrl = TextEditingController();
    final controller = Get.find<DeliveryRequestController>();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        // ✅ changed: dialog background from theme
        backgroundColor: Get.theme.cardColor,
        insetPadding: const EdgeInsets.symmetric(horizontal: 25),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔹 Title Row
                Row(
                  children: [
                    const Icon(
                      Icons.cancel_outlined,
                      color: Colors.red,
                      size: 28,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Reject Request",
                      // ✅ changed: shared text style
                      style: bold18.copyWith(color: Colors.red),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // 🔹 Description
                Text(
                  "Please provide a reason for rejecting this delivery request. "
                  "The reason will be stored on the server.",
                  // ✅ changed: theme-based text color
                  style: regular14.copyWith(
                    color: Get.theme.textTheme.bodyMedium?.color,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 14),

                // 🔹 Input Field
                TextField(
                  controller: reasonCtrl,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: "Enter rejection reason...",
                    // ✅ changed: hint color from theme
                    hintStyle: TextStyle(color: Get.theme.hintColor),
                    filled: true,
                    // ✅ changed: adaptive fill color
                    fillColor: Get.isDarkMode
                        ? Colors.grey.shade800
                        : const Color(0xFFF9FAFB),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        // ✅ changed
                        width: 0.2,
                        color: Get.theme.dividerColor,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        width: 0.2,
                        // ✅ changed
                        color: Get.theme.dividerColor,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Colors.red,

                        width: 0.5,
                      ),
                    ),
                  ),
                  style: regular14.copyWith(
                    color: Get.theme.textTheme.bodyMedium?.color,
                  ),
                ),

                const SizedBox(height: 20),

                // 🔹 Buttons
                Row(
                  children: [
                    // Cancel Button
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            // ✅ changed
                            color: Get.theme.dividerColor,
                            width: 1,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        child: Text(
                          "Cancel",
                          // ✅ changed
                          style: semibold14.copyWith(
                            color: Get.theme.textTheme.bodyMedium?.color,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    // Confirm Button
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        onPressed: () async {
                          final reason = reasonCtrl.text.trim();

                          if (reason.isEmpty) {
                            showError(
                              "Please enter a reason before rejecting.",
                            );
                            return;
                          }

                          Get.back(); // Close dialog first
                          await controller.rejectRequest(requestId, reason);
                        },
                        child: Text(
                          "Confirm",
                          // ✅ changed
                          style: semibold14.copyWith(color: Colors.white),
                        ),
                      ),
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
}
