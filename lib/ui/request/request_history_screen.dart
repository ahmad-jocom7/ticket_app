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
  void initState() {
    controller.getHistoryRequests(controller.selectedStatus.value);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // first load (default = pending)

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
    final isSelected = controller.selectedStatus.value == value;

    return Expanded(
      child: GestureDetector(
        onTap: () => controller.changeStatus(value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? ColorApp.primary : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: ColorApp.primary),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : ColorApp.primary,
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

      final List<LstRequest> data = controller.requestModel.value!.lstRequests;

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
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black12, width: 0.7),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
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
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                  ),
                ),
              ),
              _statusBadge(_statusText(item.status)),
            ],
          ),

          const SizedBox(height: 14),
          const Divider(),
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

  // ---------------------------------------------------------
  Widget _infoTile(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 95,
            child: Text(
              "$title:",
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14.5,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14.5, color: Colors.black54),
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
}
