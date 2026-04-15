import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/service_record_details.dart';
import '../../../controller/tickets_history_controller.dart';
import '../../../model/service_record/ticket_history_model.dart';
import '../../../utils/color_app.dart';

class TicketHistoryScreen extends StatefulWidget {
  const TicketHistoryScreen({super.key});

  @override
  State<TicketHistoryScreen> createState() => _TicketHistoryScreenState();
}

class _TicketHistoryScreenState extends State<TicketHistoryScreen> {
  final TicketHistoryController controller = Get.put(TicketHistoryController());

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchTicketsHistory();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isDark
        ? theme.colorScheme.surface
        : const Color(0xFFF5F6FA);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: const Text("Ticket History")),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.isNotEmpty) {
          return Center(
            child: Text(
              controller.errorMessage.value,
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.red),
            ),
          );
        }

        if (controller.data.isEmpty) {
          return Center(
            child: Text(
              "No closed tickets found.",
              style: theme.textTheme.bodyMedium,
            ),
          );
        }

        return Container(
          color: bgColor,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildTotalCounts(), // ✅ التوتال
              const SizedBox(height: 12),

              Expanded(
                child: ListView.builder(
                  itemCount: controller.data.length,
                  itemBuilder: (context, index) {
                    final ticket = controller.data[index];
                    return TicketHistoryCard(data: ticket);
                  },
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildTotalCounts() {
    final total = controller.totalCount.value;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surfaceContainerHighest
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: IntrinsicHeight(
        // مهم جداً لجعل الخطوط الفاصلة بنفس الطول
        child: Row(
          children: [
            _unifiedCountItem("On Site", total.resolvedOnSite, Colors.green),
            _buildDivider(),
            _unifiedCountItem(
              "Workshop",
              total.resolvedOnWorkshop,
              Colors.blue,
            ),
            _buildDivider(),
            _unifiedCountItem("Unresolved", total.unResolved, Colors.orange),
            _buildDivider(),
            _unifiedCountItem("Rejected", total.rejected, Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return VerticalDivider(
      color: Colors.grey.withValues(alpha: 0.2),
      thickness: 1,
      width: 1,
      indent: 12,
      endIndent: 12,
    );
  }

  Widget _unifiedCountItem(String title, int count, Color color) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              count.toString(),
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 20,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TicketHistoryCard extends StatelessWidget {
  final TicketData data;

  const TicketHistoryCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final info = data;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      color: theme.cardColor,
      elevation: isDark ? 0 : 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      shadowColor: ColorApp.primary.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        _getStatusColor().withValues(alpha: 0.25),
                        _getStatusColor().withValues(alpha: 0.08),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(
                      color: _getStatusColor().withValues(alpha: 0.35),
                      width: 1.2,
                    ),
                    // boxShadow: [
                    //   BoxShadow(
                    //     color: _getStatusColor().withValues(alpha: 0.15),
                    //     blurRadius: 8,
                    //     offset: const Offset(0, 3),
                    //   ),
                    // ],
                  ),
                  child: Center(
                    child: Icon(
                      _getStatusIcon(),
                      color: _getStatusColor(),
                      size: 26,
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Ticket No.",
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.textTheme.bodySmall?.color?.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                      Text(
                        "#${info.ticketId}",
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: ColorApp.primary,
                        ),
                      ),
                    ],
                  ),
                ),

                _statusBadge(),
              ],
            ),

            const SizedBox(height: 16),
            Divider(color: theme.dividerColor.withValues(alpha: 0.2)),

            // ================= INFO =================
            _infoRow(context, "S/N", info.serialNo),
            _infoRow(context, "Customer", info.customerName),
            _infoRow(context, "Caller Name", info.callerName),
            _infoRow(context, "Location", "${info.area} - ${info.subArea}"),
            _infoRow(context, "Sub Product", info.subProductName),

            const SizedBox(height: 14),
            Divider(color: theme.dividerColor.withValues(alpha: 0.2)),

            // ================= BUTTON =================
            if (!info.rejected && info.serviceRecordResult != -1)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Get.dialog(
                          ServiceRecordDialog(ticketId: info.ticketId),
                        );
                      },
                      icon: const Icon(Icons.list_alt_outlined, size: 18),
                      label: const Text("Service Records"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorApp.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  // ================= STATUS =================

  Widget _statusBadge() {
    String text;
    Color color;
    IconData icon;

    if (data.rejected) {
      text = "Rejected";
      color = Colors.red;
      icon = Icons.cancel_rounded;
    } else {
      switch (data.serviceRecordResult) {
        case 1:
          text = "Resolved";
          color = Colors.green;
          icon = Icons.check_circle_rounded;
          break;
        case 0:
          text = "Unresolved";
          color = Colors.orange;
          icon = Icons.error_rounded;
          break;
        default:
          text = "Pending";
          color = Colors.grey;
          icon = Icons.schedule_rounded;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20), // 🔥 pill shape
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon() {
    if (data.rejected) return Icons.cancel;

    switch (data.serviceRecordResult) {
      case 1:
        return Icons.check_circle;
      case 0:
        return Icons.error_outline;
      default:
        return Icons.hourglass_empty;
    }
  }

  Color _getStatusColor() {
    if (data.rejected) return Colors.red;

    switch (data.serviceRecordResult) {
      case 1:
        return Colors.green;
      case 0:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  // ================= INFO ROW =================

  Widget _infoRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              value.isEmpty ? "—" : value,
              textAlign: TextAlign.right,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withValues(
                  alpha: 0.7,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ServiceRecordDialog extends StatefulWidget {
  final int ticketId;

  const ServiceRecordDialog({super.key, required this.ticketId});

  @override
  State<ServiceRecordDialog> createState() => _ServiceRecordDialogState();
}

class _ServiceRecordDialogState extends State<ServiceRecordDialog> {
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

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: theme.dialogTheme.backgroundColor,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 600),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 🔹 Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: ColorApp.primary.withValues(
                        alpha: isDark ? 0.25 : 0.1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.history, color: ColorApp.primary),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Service Records",
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: Get.back,
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),

              const SizedBox(height: 10),
              Divider(color: theme.dividerColor.withValues(alpha: 0.2)),

              // 🔹 Content
              Flexible(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Padding(
                      padding: EdgeInsets.all(30),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (controller.errorMessage.isNotEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(controller.errorMessage.value),
                      ),
                    );
                  }

                  if (controller.serviceRecords.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text("No Records Found"),
                      ),
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    itemCount: controller.serviceRecords.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final record = controller.serviceRecords[index];

                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: ColorApp.primary.withValues(alpha: 0.15),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.person,
                                  size: 18,
                                  color: ColorApp.primary,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    record.strEmployeeName ?? "-",
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                // _statusChip(record.strServiceResult),
                              ],
                            ),

                            const SizedBox(height: 10),

                            Wrap(
                              runSpacing: 6,
                              children: [
                                _info("Solution", record.strSolution),
                                _info("Time In", record.strTimeIn),
                                if ((record.strTimeOut ?? '').isNotEmpty)
                                  _info("Time Out", record.strTimeOut),
                              ],
                            ),

                            if ((record.strRepairNote ?? '').isNotEmpty) ...[
                              const SizedBox(height: 10),
                              _noteBox("Note", record.strRepairNote!, theme),
                            ],
                            if ((record.strReason ?? '').isNotEmpty) ...[
                              const SizedBox(height: 10),
                              _noteBox("Reason", record.strReason!, theme, isError: true,),
                            ],

                            if ((record.strUnsolvedNote ?? '').isNotEmpty) ...[
                              const SizedBox(height: 10),
                              _noteBox(
                                "Unsolved Note"
                                    "",
                                record.strUnsolvedNote!,
                                theme,
                                isError: true,
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _info(String label, String? value) {
    return Row(
      children: [
        Text("$label: ", style: const TextStyle(fontWeight: FontWeight.w600)),
        Expanded(child: Text(value ?? "-")),
      ],
    );
  }

  Widget _statusChip(String? status) {
    final isSolved = status == "Solved";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: (isSolved ? Colors.green : Colors.red).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status ?? "-",
        style: TextStyle(
          color: isSolved ? Colors.green : Colors.red,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  // 🔹 Note Box
  Widget _noteBox(
    String title,
    String value,
    ThemeData theme, {
    bool isError = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: (isError ? Colors.red : ColorApp.primary).withValues(
          alpha: 0.08,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: isError ? Colors.red : ColorApp.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(value),
        ],
      ),
    );
  }
}
