import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/device_history_controller.dart';
import '../../../model/ticket/history_device_model.dart';

class DeviceHistoryScreen extends StatefulWidget {
  final int subProductFileId;

  const DeviceHistoryScreen({super.key, required this.subProductFileId});

  @override
  State<DeviceHistoryScreen> createState() => _DeviceHistoryScreenState();
}

class _DeviceHistoryScreenState extends State<DeviceHistoryScreen> {
  final controller = Get.put(DeviceHistoryController());

  int count = 10;

  @override
  void initState() {
    controller.getDeviceHistory(widget.subProductFileId);
    super.initState();
  }

  void _showFilterDialog() {
    final theme = Get.theme;
    final primaryColor = theme.primaryColor;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min, // ليأخذ حجم المحتوى فقط
            children: [
              /// العنوان
              Row(
                children: [
                  Icon(Icons.history_toggle_off_rounded, color: primaryColor),
                  const SizedBox(width: 10),
                  const Text(
                    "Fetch Settings",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              const Text(
                "How many records would you like to load?",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 20),

              /// التحكم في العدد (العداد)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: theme.dividerColor.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildCircleBtn(Icons.remove, controller.decrease),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: Obx(
                        () => Column(
                          children: [
                            Text(
                              "${controller.count.value}",
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              "RECORDS",
                              style: TextStyle(
                                fontSize: 10,
                                letterSpacing: 1,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    _buildCircleBtn(Icons.add, controller.increase),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              /// زر جلب البيانات
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Get.back(); // إغلاق الـ Dialog
                    controller.getDeviceHistory(widget.subProductFileId);
                  },
                  child: const Text(
                    "Apply & Load",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCircleBtn(IconData icon, VoidCallback onTap) {
    return Material(
      color: Get.theme.primaryColor.withValues(alpha: 0.1),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(icon, size: 20, color: Get.theme.primaryColor),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Get.theme;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showFilterDialog(),
        backgroundColor: Get.theme.primaryColor,
        icon: const Icon(Icons.tune_rounded, color: Colors.white),
        label: const Text(
          "Filters",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      appBar: AppBar(title: const Text("Device History")),

      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.errorMessage.isNotEmpty) {
                return Center(child: Text(controller.errorMessage.value));
              }

              final history =
                  controller.deviceHistoryModel.value?.ticketsHistory ?? [];

              if (history.isEmpty) {
                return const Center(child: Text("No history found"));
              }

              return ListView.separated(
                padding: const EdgeInsets.only(
                  top: 16,
                  left: 16,
                  right: 16,
                  bottom: 70,
                ),
                itemCount: history.length,
                separatorBuilder: (_, _) => const SizedBox(height: 14),
                itemBuilder: (_, i) => _historyCard(history[i], theme),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _historyCard(TicketHistory item, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: theme.brightness == Brightness.dark ? 0.3 : 0.06,
            ),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HEADER
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.build_circle_outlined, size: 18),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: Text(
                  item.ticketFaultNote ?? "No Fault Info",
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "#${item.ticketId}",
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Divider(color: theme.dividerColor.withValues(alpha: .5)),

          const SizedBox(height: 12),

          /// INFO
          _infoRow(Icons.person_outline, "Engineer", item.assignEmployeeName),
          _infoRow(
            Icons.calendar_today_outlined,
            "Ticket Date",
            item.ticketDate,
          ),
          _infoRow(Icons.schedule_outlined, "Record Date", item.recordDate),
          _infoRow(Icons.settings_outlined, "Solution", item.recordSolution),

          const SizedBox(height: 14),

          /// NOTE
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),

            decoration: BoxDecoration(
              color: theme.dividerColor.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(10),
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Repair Note",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),

                const SizedBox(height: 6),

                Text(
                  item.repairNote ?? "No note",
                  style: TextStyle(
                    color: theme.textTheme.bodyMedium?.color,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          /// STATUS
          if(item.serviceResult != "")
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),

              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),

              child: Text(
                item.serviceResult ?? "",
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String title, String? value) {
    final theme = Get.theme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.iconTheme.color),

          const SizedBox(width: 8),

          SizedBox(
            width: 110,
            child: Text(
              "$title:",
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),

          Expanded(
            child: Text(
              value ?? "",
              style: TextStyle(
                color: theme.textTheme.bodySmall?.color,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
