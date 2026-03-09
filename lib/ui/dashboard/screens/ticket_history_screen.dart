import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/tickets_history_controller.dart';
import '../../../model/service_record/ticket_history_model.dart';
import '../../../utils/color_app.dart';

class TicketHistoryScreen extends StatefulWidget {
  const TicketHistoryScreen({super.key});

  @override
  State<TicketHistoryScreen> createState() => _TicketHistoryScreenState();
}

class _TicketHistoryScreenState extends State<TicketHistoryScreen> {
  final TicketHistoryController controller = Get.put(
    TicketHistoryController(),
  );

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
          child: ListView.builder(
            itemCount: controller.data.length,
            itemBuilder: (context, index) {
              final TicketData ticket = controller.data[index];
              return TicketHistoryCard(data: ticket);
            },
          ),
        );
      }),
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
            // ---------------- Header ----------------
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.orange.withValues(alpha: 0.35),
                    ),
                  ),
                  child: const Icon(
                    Icons.check_circle_outline,
                    color: Colors.orange,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),

                // Ticket info
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
                      // const SizedBox(height: 4),
                      // Row(
                      //   children: [
                      //     const Icon(Icons.event, size: 14, color: Colors.grey),
                      //     const SizedBox(width: 4),
                      //     Text(
                      //       "Closed: $closedDate",
                      //       style: theme.textTheme.bodySmall?.copyWith(
                      //         color: theme.textTheme.bodySmall?.color
                      //             ?.withValues(alpha: 0.7),
                      //       ),
                      //     ),
                      //   ],
                      // ),
                    ],
                  ),
                ),

                _statusBadge(),
              ],
            ),

            const SizedBox(height: 16),
            Divider(color: theme.dividerColor.withValues(alpha: 0.2)),

            // ---------------- Info ----------------
            _infoRow(context, "S/N", info.serialNo),
            _infoRow(context, "Customer", info.customerName),
            _infoRow(context, "Caller Name", info.callerName),
            // _infoRow(context, "Fault", info.strFault),
            _infoRow(
              context,
              "Location",
              "${info.area} - ${info.subArea}",
            ),
            _infoRow(context, "Sub Product", info.subProductName),

            const SizedBox(height: 14),
            Divider(color: theme.dividerColor.withValues(alpha: 0.2)),

            // ---------------- Actions ----------------
            // Row(
            //   children: [
            //     Expanded(
            //       child: ElevatedButton.icon(
            //         onPressed: () {
            //           Get.to(() => PreviewTicketScreen(data: data));
            //         },
            //         icon: const Icon(Icons.visibility_outlined, size: 18),
            //         label: const Text("View"),
            //         style: ElevatedButton.styleFrom(
            //           backgroundColor: ColorApp.primary,
            //           foregroundColor: Colors.white,
            //           padding: const EdgeInsets.symmetric(vertical: 12),
            //           shape: RoundedRectangleBorder(
            //             borderRadius: BorderRadius.circular(10),
            //           ),
            //         ),
            //       ),
            //     ),
            //     const SizedBox(width: 10),
            //     Expanded(
            //       child: OutlinedButton.icon(
            //         onPressed: () {
            //           _showAddNoteDialog(context, info.ticketId);
            //         },
            //         icon: const Icon(Icons.note_add_outlined, size: 18),
            //         label: const Text("Add Note"),
            //         style: OutlinedButton.styleFrom(
            //           padding: const EdgeInsets.symmetric(vertical: 12),
            //           shape: RoundedRectangleBorder(
            //             borderRadius: BorderRadius.circular(10),
            //           ),
            //         ),
            //       ),
            //     ),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }

  // ---------------- Helpers ----------------

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

  Widget _statusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        "Closed",
        style: TextStyle(
          color: Colors.orange,
          fontWeight: FontWeight.bold,
          fontSize: 12.5,
        ),
      ),
    );
  }


}
