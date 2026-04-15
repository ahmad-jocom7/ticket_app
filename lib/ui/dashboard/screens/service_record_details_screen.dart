import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/service_record_details.dart';
import '../../../utils/color_app.dart';


class ServiceRecordViewScreen extends StatefulWidget {
  final int ticketId;

  const ServiceRecordViewScreen({super.key, required this.ticketId});

  @override
  State<ServiceRecordViewScreen> createState() =>
      _ServiceRecordViewScreenState();
}

class _ServiceRecordViewScreenState extends State<ServiceRecordViewScreen> {
  final controller = ServiceRecordViewController.to;

  @override
  void initState() {
    super.initState();
    controller.getServiceRecordByTicketId(widget.ticketId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text("Service Records"),
      ),
      body: Obx(() {
        // 🔄 Loading
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        // ❌ Error
        if (controller.errorMessage.isNotEmpty) {
          return Center(
            child: Text(
              controller.errorMessage.value,
              style: theme.textTheme.bodyMedium,
            ),
          );
        }

        // 📭 Empty
        if (controller.serviceRecords.isEmpty) {
          return const Center(child: Text("No Records Found"));
        }

        // ✅ Data
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.serviceRecords.length,
          itemBuilder: (context, index) {
            final record = controller.serviceRecords[index];

            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: isDark
                    ? []
                    : [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: ColorApp.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔹 Header
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: ColorApp.primary.withValues(
                          alpha: isDark ? 0.25 : 0.1,
                        ),
                        child: Icon(
                          Icons.build_circle_outlined,
                          color: ColorApp.primary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          record.strEmployeeName ?? "Unknown",
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // 🔹 Solution
                  _infoRow(
                    icon: Icons.build,
                    label: "Solution",
                    value: record.strSolution ?? "-",
                  ),

                  // 🔹 Result
                  _infoRow(
                    icon: Icons.check_circle,
                    label: "Result",
                    value: record.strServiceResult ?? "-",
                    color: record.strServiceResult == "Solved"
                        ? Colors.green
                        : Colors.red,
                  ),

                  // 🔹 Time In
                  _infoRow(
                    icon: Icons.login,
                    label: "Time In",
                    value: record.strTimeIn ?? "-",
                  ),

                  // 🔹 Time Out
                  if ((record.strTimeOut ?? '').isNotEmpty)
                    _infoRow(
                      icon: Icons.logout,
                      label: "Time Out",
                      value: record.strTimeOut ?? "-",
                    ),

                  // 🔹 Note
                  if ((record.strRepairNote ?? '').isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      "Note",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(record.strRepairNote!),
                  ],

                  // 🔹 Unsolved Note

                  if ((record.strUnsolvedNote ?? '').isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      "Unsolved Note",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    Text(record.strUnsolvedNote!),
                  ],
                ],
              ),
            );
          },
        );
      }),
    );
  }

  // 🔹 Reusable Row
  Widget _infoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color ?? Colors.grey),
          const SizedBox(width: 6),
          Text(
            "$label: ",
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: color),
            ),
          ),
        ],
      ),
    );
  }
}