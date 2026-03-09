import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/assigned_tickets_controller.dart';
import '../../../model/service_record/assign_ticket_model.dart';
import '../../../utils/color_app.dart';
import '../../../utils/text_style.dart';
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
      // ✅ changed: card color from theme
      color: Theme.of(context).cardColor,
      elevation: Theme.of(context).brightness == Brightness.dark ? 0 : 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Header
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  // ✅ changed: adaptive background
                  backgroundColor: ColorApp.primary.withValues(
                    alpha: Theme.of(context).brightness == Brightness.dark
                        ? 0.18
                        : 0.1,
                  ),
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
                      // ✅ changed: base text style from theme + shared font
                      style: themed(context, semibold14),
                      children: [
                        const TextSpan(text: "Ticket No. "),
                        TextSpan(
                          text: "( ${widget.data.intTicketId} )",
                          style: semibold14.copyWith(color: ColorApp.primary),
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
                    // ✅ changed: icon color from theme
                    icon: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Theme.of(context).iconTheme.color,
                    ),
                  ),
                ),
              ],
            ),

            // 🔹 Expandable Details
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
                      // ✅ changed: adaptive background
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey.shade800
                          : const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        // ✅ changed
                        color: Theme.of(context).dividerColor,
                        width: 0.2,
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
                        DividerWidget(),

                        _detailItem(
                          "Customer Name",
                          widget.data.strCustomerName,
                        ),
                        DividerWidget(),

                        _detailItem(
                          "Customer Ref.No",
                          widget.data.strCustomerRefNo,
                        ),
                        DividerWidget(),
                        _detailItem(
                          "Sub Product",
                          widget.data.strSubProductName,
                        ),
                        DividerWidget(),

                        _detailItem("Fault", widget.data.strFault),
                        DividerWidget(),
                        _detailItem("Fault Note", widget.data.strFaultNote),
                        DividerWidget(),
                        _detailItem("Nots", widget.data.strNots),
                        DividerWidget(),

                        _detailItem(
                          "Location",
                          "${widget.data.strArea} , ${widget.data.strSubArea}",
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

            // 🔹 Actions
            Row(
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
                          ? null
                          : () async {
                              await controller.acceptTicket(widget.assignId);
                            },
                      style: ElevatedButton.styleFrom(
                        // ✅ changed: disabled handling
                        backgroundColor: (isAccepting || isRejecting)
                            ? Colors.grey
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
                          : Text(
                              "Accept",
                              // ✅ changed
                              style: semibold14.copyWith(color: Colors.white),
                            ),
                    );
                  }),
                ),

                const SizedBox(width: 10),

                // ❌ Reject
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
                              // ✅ changed
                              style: semibold14.copyWith(
                                color: ColorApp.primary,
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
    // ✅ changed: read theme colors instead of hardcoded colors
    final primaryColor = ColorApp.primary;
    final labelColor = Theme.of(context).textTheme.bodySmall?.color;
    final valueColor = primaryColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🔹 Label
        Text(
          label,
          // ✅ changed: use shared text style + theme color
          style: semibold12.copyWith(color: labelColor),
        ),

        const SizedBox(height: 4),

        // 🔹 Value
        Text(
          value.isNotEmpty ? value : "-",
          // ✅ changed: use shared text style instead of raw TextStyle
          style: medium14.copyWith(color: valueColor, height: 1.3),
        ),
      ],
    );
  }
}

class DividerWidget extends StatelessWidget {
  const DividerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 16,
      color: Theme.of(context).dividerColor.withValues(alpha: 0.15),
    );
  }
}
