import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ticket_app/controller/delivery_request_controller.dart';
import 'package:ticket_app/model/delivery_request/request_model.dart';
import 'package:ticket_app/utils/color_app.dart';

import '../../utils/snackbar.dart';

class DeliveryRequestScreen extends StatefulWidget {
  const DeliveryRequestScreen({super.key});

  @override
  State<DeliveryRequestScreen> createState() => _DeliveryRequestScreenState();
}

class _DeliveryRequestScreenState extends State<DeliveryRequestScreen> {
  final controller = DeliveryRequestController.to;


  @override
  void initState() {
    controller.fetchDeliveryRequests();
    super.initState();
  }

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
                style: const TextStyle(fontSize: 16, color: Colors.red),
              ),
            );
          }
          if (controller.requests.isEmpty) {
            return const Center(
              child: Text(
                "No delivery requests available",
                style: TextStyle(fontSize: 16, color: Colors.black54),
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
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: ColorApp.primary.withValues(alpha: 0.1),
                child: Icon(Icons.inventory_2_outlined,
                    color: ColorApp.primary, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.partNumber,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1),
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
              // REJECT BUTTON
              TextButton.icon(
                onPressed: () => showDeliveryRejectDialog(item.id),
                icon: const Icon(Icons.close, color: Colors.red),
                label: const Text(
                  "Reject",
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
                ),
              ),

              const SizedBox(width: 10),

              // ACCEPT BUTTON
              ElevatedButton.icon(
                onPressed: () => controller.acceptRequest(item.id),
                icon: const Icon(Icons.check_circle_outline),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorApp.primary,
                ),
                label: const Text("Accept"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _row(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              "$title:",
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black54, fontSize: 14.5),
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
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 25),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 🔹 Title Row
                Row(
                  children: const [
                    Icon(Icons.cancel_outlined, color: Colors.red, size: 28),
                    SizedBox(width: 8),
                    Text(
                      "Reject Request",
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // 🔹 Description
                const Text(
                  "Please provide a reason for rejecting this delivery request. "
                      "The reason will be stored on the server.",
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 14.2,
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
                      borderSide: const BorderSide(
                        color: Colors.red,
                        width: 1.3,
                      ),
                    ),
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
                            showError("Please enter a reason before rejecting.");
                            return;
                          }

                          Get.back(); // Close dialog first
                          await controller.rejectRequest(requestId, reason);
                        },
                        child: const Text(
                          "Confirm",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
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
