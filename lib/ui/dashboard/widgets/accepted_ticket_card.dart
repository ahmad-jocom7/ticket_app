import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/accepted_tickets_controller.dart';
import '../../../model/service_record/assign_ticket_model.dart';
import '../../../utils/color_app.dart';
import '../screens/accepted_ticket_screen.dart';
import '../screens/preview_ticket_screen.dart';

class AcceptedTicketCard extends StatelessWidget {
  final LstTicket data;

  AcceptedTicketCard({super.key, required this.data});

  final controller = Get.find<AcceptedTicketController>();

  @override
  Widget build(BuildContext context) {
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
            // 🔹 Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 54,
                  width: 54,
                  decoration: BoxDecoration(
                    color: ColorApp.primary.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: ColorApp.primary.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Icon(
                    Icons.confirmation_number_outlined,
                    color: ColorApp.primary,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Ticket Number",
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: ColorApp.primary.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Text(
                          "#${data.intTicketId}",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: ColorApp.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // 🔹 Info Rows
            InfoRowWidget(label: "S/N", value: data.ticketInfo.strSerialNo),
            InfoRowWidget(
              label: "Customer Ref. No.",
              value: data.ticketInfo.strCustomerRefNo,
            ),
            InfoRowWidget(
              label: "Customer Name",
              value: data.ticketInfo.strCustomerName,
            ),
            InfoRowWidget(label: "Fault", value: data.ticketInfo.strFault),
            InfoRowWidget(
              label: "Location",
              value:
                  "${data.ticketInfo.strArea} , ${data.ticketInfo.strSubArea}",
            ),

            const SizedBox(height: 14),
            const Divider(thickness: 0.8, color: Color(0xFFE0E0E0)),
            const SizedBox(height: 8),

            // 🔹 Actions
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ActionButton(
                        label: "Review",
                        color: Colors.grey.shade200,
                        textColor: Colors.black87,
                        icon: Icons.visibility_outlined,
                        onTap: () {
                          Get.to(() => PreviewTicketScreen(data: data));
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Obx(() {
                        return ElevatedButton.icon(
                          onPressed: controller.isOpening.value
                              ? null
                              : () async {
                                  if (data.ticketInfo.intServiceRecordID == 0) {
                                    await controller.openServiceRecord(
                                      data.intTicketId,
                                      data.ticketInfo.intSubProductFileId,
                                    );
                                  } else {
                                    controller.viewServiceRecord(
                                      data.ticketInfo.intServiceRecordID,
                                      data.intTicketId,
                                      data.ticketInfo.intSubProductFileId,
                                    );
                                  }
                                },
                          icon: controller.isOpening.value
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(
                                  Icons.build_circle_outlined,
                                  color: Colors.white,
                                  size: 18,
                                ),
                          label: Text(
                            controller.isOpening.value
                                ? "Opening..."
                                : data.ticketInfo.intServiceRecordID == 0
                                ? "Open Record"
                                : "View Record",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 13.5,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorApp.primary,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (data.ticketInfo.intServiceRecordID == 0)
                  SizedBox(
                    width: double.infinity,
                    child: ActionButton(
                      label: "Reject",
                      color: Colors.red.withValues(alpha: 0.1),
                      textColor: Colors.red,
                      icon: Icons.cancel_outlined,
                      onTap: controller.isRejected.value == true
                          ? null
                          : () {
                              showRejectDialog(data.intId);
                            },
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;
  final IconData icon;
  final VoidCallback? onTap;

  const ActionButton({
    super.key,
    required this.label,
    required this.color,
    required this.textColor,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: textColor, size: 18),
        label: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w600,
            fontSize: 13.5,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}

class InfoRowWidget extends StatelessWidget {
  final String label;
  final String value;

  const InfoRowWidget({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
      ),
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
              style: const TextStyle(
                fontSize: 13.5,
                color: Colors.black54,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
