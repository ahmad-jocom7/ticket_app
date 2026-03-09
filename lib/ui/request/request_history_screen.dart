import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../utils/color_app.dart';
import '../../controller/history_request_controller.dart';
import '../../model/delivery_request/request_model.dart';
import 'edit_request_screen.dart';

class RequestHistoryScreen extends StatefulWidget {
   const RequestHistoryScreen({super.key});

  @override
  State<RequestHistoryScreen> createState() => _RequestHistoryScreenState();
}

class _RequestHistoryScreenState extends State<RequestHistoryScreen> {
  final HistoryRequestController controller = Get.put(
    HistoryRequestController(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Request History")),
      body: Column(
        children: [
          _statusFilter(),
          Expanded(child: _requestList()),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  Widget _statusFilter() {
    return Obx(() {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _filterChip("Pending", 0),
            const SizedBox(width: 8),
            _filterChip("Accepted", 1),
            const SizedBox(width: 8),
            _filterChip("Rejected", 2),
          ],
        ),
      );
    });
  }

  Widget _filterChip(String title, int value) {
    final theme = Theme.of(context); // ✅ changed
    final isSelected = controller.selectedStatus.value == value;

    return Expanded(
      child: GestureDetector(
        onTap: () => controller.changeStatus(value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            // ✅ changed: theme-aware background
            color: isSelected ? ColorApp.primary : theme.cardColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: ColorApp.primary, width: 0.5),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                // ✅ changed: adaptive text color
                color: isSelected
                    ? Colors.white
                    : theme.textTheme.bodyMedium?.color,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------
  Widget _requestList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.requestModel.value == null) {
        return Center(child: Text(controller.errorMessage.value));
      }

      final data = controller.requestModel.value!.lstRequests;

      if (data.isEmpty) {
        return const Center(child: Text("No requests found"));
      }

      return ListView.builder(
        padding: const EdgeInsets.all(18),
        itemCount: data.length,
        itemBuilder: (context, index) {
          return _professionalCard(data[index]);
        },
      );
    });
  }

  // ---------------------------------------------------------
  Widget _professionalCard(LstRequest item) {
    final theme = Theme.of(context); // ✅ changed

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        // ✅ changed: theme card color
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.4),
          width: 0.25,
        ),
        boxShadow: [
          BoxShadow(
            // ✅ changed: softer shadow for dark/light
            color: Colors.black.withValues(
              alpha: theme.brightness == Brightness.dark ? 0.25 : 0.05,
            ),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: ColorApp.primary.withValues(alpha: 0.12),
                child: Icon(
                  Icons.inventory_2_rounded,
                  color: ColorApp.primary,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  item.partNumber,
                  // ✅ changed: theme text color
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
              ),
              _statusBadge(_statusText(item.status)),
            ],
          ),

          const SizedBox(height: 14),
          Divider(color: theme.dividerColor.withValues(alpha: 0.4)),
          const SizedBox(height: 14),

          _infoTile("Description", item.description),
          _infoTile("Client", item.customerName),
          _infoTile("Content", item.contentName),
          _infoTile("Date", _formatDate(item.dateTime)),

          if (item.status == 0) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: () {
                  Get.to(() => EditRequestScreen(item: item));
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: ColorApp.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: ColorApp.primary.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.edit_outlined,
                        size: 18,
                        color: ColorApp.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "Edit",
                        style: TextStyle(
                          color: ColorApp.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  Widget _infoTile(String title, String value) {
    final theme = Theme.of(context); // ✅ changed

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 95,
            child: Text(
              "$title:",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14.5,
                // ✅ changed
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14.5,
                // ✅ changed
                color: theme.textTheme.bodyMedium?.color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  Widget _statusBadge(String status) {
    Color color;

    switch (status.toLowerCase()) {
      case 'accepted':
        color = Colors.green;
        break;
      case 'pending':
        color = Colors.orange;
        break;
      case 'rejected':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12.5,
        ),
      ),
    );
  }

  String _statusText(int status) {
    switch (status) {
      case 0:
        return "Pending";
      case 1:
        return "Accepted";
      case 2:
        return "Rejected";
      default:
        return "Unknown";
    }
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }
}
