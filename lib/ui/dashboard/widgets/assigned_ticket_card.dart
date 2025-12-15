import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/assigned_tickets_controller.dart';
import '../../../model/service_record/assign_ticket_model.dart';
import '../../../utils/color_app.dart';
import '../screens/new_ticket_screen.dart';

class AssignedTicketCard extends StatefulWidget {
  final TicketInfo data;
  final int assignId;

  const AssignedTicketCard({
    super.key,
    required this.data,
    required this.assignId,
  });

  @override
  State<AssignedTicketCard> createState() => _AssignedTicketCardState();
}

class _AssignedTicketCardState extends State<AssignedTicketCard> {
  bool isExpanded = false;
  final AssignedTicketController controller = Get.put(
    AssignedTicketController(),
  );

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Color(0xFFE3F2FD),
                  child: Icon(
                    Icons.confirmation_number_outlined,
                    color: ColorApp.primary,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                      children: [
                        const TextSpan(
                          text: "Ticket No. ",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        TextSpan(
                          text: "( ${widget.data.intTicketId} )",
                          style: TextStyle(
                            color: ColorApp.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: IconButton(
                    onPressed: () {
                      setState(() {
                        isExpanded = !isExpanded;
                      });
                    },
                    icon: Icon(Icons.keyboard_arrow_down_rounded),
                  ),
                ),
              ],
            ),

            AnimatedCrossFade(
              duration: const Duration(milliseconds: 250),
              crossFadeState: isExpanded
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              firstChild: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 15),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB), // خلفية خفيفة جدًا
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFE5E7EB),
                        width: 1,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _detailItem("S/N", widget.data.strSerialNo),
                        const Divider(height: 16, color: Color(0xFFE0E0E0)),
                        _detailItem(
                          "Customer Name",
                          widget.data.strCustomerName,
                        ),
                        const Divider(height: 16, color: Color(0xFFE0E0E0)),
                        _detailItem(
                          "Customer Ref.No",
                          widget.data.strCustomerRefNo,
                        ),
                        const Divider(height: 16, color: Color(0xFFE0E0E0)),
                        _detailItem(
                          "Sub Product",
                          widget.data.strSubProductName,
                        ),
                        const Divider(height: 16, color: Color(0xFFE0E0E0)),
                        _detailItem("Fault", widget.data.strFault),
                        const Divider(height: 16, color: Color(0xFFE0E0E0)),
                        _detailItem(
                          "Location",
                          "${widget.data.strArea} , ${widget.data.strSubArea} ",
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),

              secondChild: const SizedBox.shrink(),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // ✅ ACCEPT BUTTON
                Expanded(
                  child: Obx(() {
                    final isAccepting =
                        controller.acceptAssignId.value == widget.assignId;
                    final isRejecting =
                        controller.rejectAssignId.value == widget.assignId;

                    return ElevatedButton(
                      onPressed: (isRejecting || isAccepting)
                          ? null // 🔒 تعطيل الزر أثناء الرفض أو التحميل
                          : () async {
                        await controller.acceptTicket(widget.assignId);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isAccepting || isRejecting
                            ? Colors
                            .grey // 🔒 اللون الرمادي وقت التعطيل
                            : ColorApp.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: isAccepting
                          ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                          : const Text(
                        "Accept",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }),
                ),

                const SizedBox(width: 10),
                Expanded(
                  child: Obx(() {
                    final isRejecting =
                        controller.rejectAssignId.value == widget.assignId;
                    final isAccepting =
                        controller.acceptAssignId.value == widget.assignId;

                    return OutlinedButton(
                      onPressed: (isRejecting || isAccepting)
                          ? null
                          : () {
                        showRejectDialog(context, widget.assignId);
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: ColorApp.primary, width: 1.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: isRejecting
                          ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: ColorApp.primary,
                          strokeWidth: 2,
                        ),
                      )
                          : Text(
                        "Reject",
                        style: TextStyle(
                          color: ColorApp.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailItem(String label, String value) {
    const labelColor = Color(0xFF6B7280); // رمادي أنيق

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: labelColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value.isNotEmpty ? value : "-",
          style: TextStyle(
            fontSize: 14.5,
            color: ColorApp.primary,
            fontWeight: FontWeight.w500,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}
