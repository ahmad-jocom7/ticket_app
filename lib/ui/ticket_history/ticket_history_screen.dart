import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/accepted_tickets_controller.dart';
import '../../utils/color_app.dart';
import '../../model/service_record/assign_ticket_model.dart';
import '../dashboard/screens/preview_ticket_screen.dart';

class TicketHistoryScreen extends StatefulWidget {
  const TicketHistoryScreen({super.key});

  @override
  State<TicketHistoryScreen> createState() => _TicketHistoryScreenState();
}

class _TicketHistoryScreenState extends State<TicketHistoryScreen> {
  final AcceptedTicketController controller = Get.put(
    AcceptedTicketController(),
  );

  @override
  void initState() {
    super.initState();
    controller.fetchAcceptedTickets();
  }

  @override
  Widget build(BuildContext context) {
    const bgLight = Color(0xFFF5F6FA);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("Ticket History")),
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
          return const Center(child: Text("No closed tickets found."));
        }

        return Container(
          color: bgLight,
          padding: const EdgeInsets.all(16),
          child: ListView.builder(
            itemCount: controller.data.length,
            itemBuilder: (context, index) {
              final LstTicket ticket = controller.data[index];
              return TicketHistoryCard(data: ticket);
            },
          ),
        );
      }),
    );
  }
}

class TicketHistoryCard extends StatelessWidget {
  final LstTicket data;

  const TicketHistoryCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final info = data.ticketInfo;

    return Card(
      color: Colors.white,
      elevation: 3,
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
              children: [
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.orange.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Icon(
                    Icons.check_circle_outline,
                    color: Colors.orange,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Ticket No.",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      "#${info.intTicketId}",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: ColorApp.primary,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                _statusBadge("Closed"),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(),

            // ---------------- Info ----------------
            _infoRow("S/N", info.strSerialNo),
            _infoRow("Customer", info.strCustomerName),
            _infoRow("Fault", info.strFault),
            _infoRow("Location", "${info.strArea} - ${info.strSubArea}"),
            _infoRow("Sub Product", info.strSubProductName),

            const SizedBox(height: 14),
            const Divider(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Get.to(() => PreviewTicketScreen(data: data));
                },
                icon: const Icon(Icons.visibility_outlined, size: 20),
                label: const Text("View Details"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- Helpers ----------------
  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13.5,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              value.isEmpty ? "—" : value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 13.5, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: const TextStyle(
          color: Colors.orange,
          fontWeight: FontWeight.bold,
          fontSize: 12.5,
        ),
      ),
    );
  }
}
