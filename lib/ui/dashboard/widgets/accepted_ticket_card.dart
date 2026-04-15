import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/accepted_tickets_controller.dart';
import '../../../model/service_record/assign_ticket_model.dart';
import '../../../utils/color_app.dart';
import '../../../utils/snackbar.dart';
import '../../../utils/text_style.dart';
import '../screens/accepted_ticket_screen.dart';
import '../screens/device_history_screen.dart';
import '../screens/preview_ticket_screen.dart';

class AcceptedTicketCard extends StatelessWidget {
  final LstTicket data;

  AcceptedTicketCard({super.key, required this.data});

  final controller = Get.find<AcceptedTicketController>();

  @override
  Widget build(BuildContext context) {
    // ✅ changed: detect theme
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = Theme.of(context).cardColor;
    final dividerColor = Theme.of(context).dividerColor;
    final textColor = Theme.of(context).textTheme.bodyMedium?.color;

    return Card(
      // ✅ changed: card color from theme
      color: cardColor,
      elevation: isDark ? 0 : 3,
      // ✅ changed: flatter in dark mode
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
                    // ✅ changed: adaptive background
                    color: ColorApp.primary.withValues(
                      alpha: isDark ? 0.18 : 0.08,
                    ),
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
                        // ✅ changed: shared text style + theme color
                        style: themed(context, medium13),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          // ✅ changed
                          color: isDark
                              ? Colors.grey.shade800
                              : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: ColorApp.primary.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Text(
                          "#${data.intTicketId}",
                          // ✅ changed
                          style: semibold14.copyWith(color: ColorApp.primary),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // 🔹 Info Rows (already reusable widget 👍)
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

            // ✅ changed: divider from theme
            Divider(thickness: 0.8, color: dividerColor.withValues(alpha: 0.5)),

            const SizedBox(height: 8),

            // 🔹 Actions
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ActionButton(
                        label: "Review",
                        // ✅ changed
                        color: isDark
                            ? Colors.grey.shade800
                            : Colors.grey.shade200,
                        textColor: textColor ?? Colors.black87,
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
                            if (controller.hasOpenedRecord.value &&
                                data.ticketInfo.intServiceRecordID == 0) {
                              showWarning(
                                "You must close the opened service record first",
                              );
                              return;
                            }

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
                          // onPressed: controller.isOpening.value
                          //     ? null
                          //     : () async {
                          //         if (data.ticketInfo.intServiceRecordID == 0) {
                          //           await controller.openServiceRecord(
                          //             data.intTicketId,
                          //             data.ticketInfo.intSubProductFileId,
                          //           );
                          //         } else {
                          //           controller.viewServiceRecord(
                          //             data.ticketInfo.intServiceRecordID,
                          //             data.intTicketId,
                          //             data.ticketInfo.intSubProductFileId,
                          //           );
                          //         }
                          //       },
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
                            // ✅ changed: shared text style
                            style: semibold12.copyWith(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                            controller.hasOpenedRecord.value &&
                                data.ticketInfo.intServiceRecordID == 0
                                ? Colors.grey
                                : ColorApp.primary,
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
                SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ActionButton(
                    label: "Device History",
                    color: ColorApp.primary.withValues(
                      alpha: isDark ? 0.25 : 0.08,
                    ),
                    textColor: ColorApp.primary,
                    icon: Icons.history,
                    onTap: () {
                      Get.to(
                        () => DeviceHistoryScreen(
                          subProductFileId: data.ticketInfo.intSubProductFileId,
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 10),

                if (data.ticketInfo.intServiceRecordID == 0)
                  SizedBox(
                    width: double.infinity,
                    child: ActionButton(
                      label: "Reject",
                      // ✅ changed
                      color: Colors.red.withValues(alpha: isDark ? 0.25 : 0.1),
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
    // ✅ changed: detect disabled state
    final isDisabled = onTap == null;

    return SizedBox(
      height: 42,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(
          icon,
          // ✅ changed: reduce opacity when disabled
          color: isDisabled ? textColor.withValues(alpha: 0.5) : textColor,
          size: 18,
        ),
        label: Text(
          label,
          style: semibold12.copyWith(
            color: isDisabled ? textColor.withValues(alpha: 0.5) : textColor,
          ),
        ),
        style: ElevatedButton.styleFrom(
          // ✅ changed: disabled visual handling
          backgroundColor: isDisabled ? color.withValues(alpha: 0.6) : color,
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
    // ✅ changed: read theme once
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = Theme.of(context).textTheme.bodyMedium?.color;
    final secondaryTextColor = Theme.of(context).textTheme.bodySmall?.color;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        // ✅ changed: background adapts to theme
        color: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          // ✅ changed: border adapts to theme
          color: isDark
              ? Colors.grey.shade700
              : Colors.grey.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          // 🔹 Label
          Expanded(
            flex: 4,
            child: Text(
              label,
              // ✅ changed: use shared text style + theme color
              style: semibold14.copyWith(color: textColor),
            ),
          ),

          // 🔹 Value
          Expanded(
            flex: 6,
            child: Text(
              value.isEmpty ? "—" : value,
              textAlign: TextAlign.right,
              // ✅ changed: shared style + secondary theme color
              style: regular14.copyWith(color: secondaryTextColor, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }
}
