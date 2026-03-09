import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signature/signature.dart';
import '../../../utils/color_app.dart';
import '../../../controller/close_record_controller.dart';

class ClientSignatureScreen extends StatefulWidget {
  final bool isReplace;

  const ClientSignatureScreen({super.key, this.isReplace = false});

  @override
  State<ClientSignatureScreen> createState() => _ClientSignatureScreenState();
}

class _ClientSignatureScreenState extends State<ClientSignatureScreen> {
  final TextEditingController nameController = TextEditingController();

  late SignatureController _signatureController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    _signatureController = SignatureController(
      penStrokeWidth: 2,
      penColor: isDark ? Colors.white : Colors.black,
      exportBackgroundColor: isDark ? theme.colorScheme.surface : Colors.white,
    );
  }

  @override
  void dispose() {
    _signatureController.dispose();
    super.dispose();
  }

  final controller = Get.find<ServiceRecordController>();

  Future<void> showSignaturePreviewDialog() async {
    // final controller = Get.find<ServiceRecordController>();

    await Get.dialog(
      Builder(
        builder: (context) {
          final theme = Theme.of(context);

          return Dialog(
            backgroundColor: theme.dialogTheme.backgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔹 Title
                  Text(
                    "Review Client Details",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 16),

                  if (controller.serviceRecordId != 0)
                    _previewRow(
                      context,
                      icon: Icons.build_circle_outlined,
                      label: "Service Record ID",
                      value: controller.serviceRecordId.toString(),
                    ),

                  if (controller.ticketId != 0)
                    _previewRow(
                      context,
                      icon: Icons.confirmation_number_outlined,
                      label: "Ticket ID",
                      value: controller.ticketId.toString(),
                    ),

                  if (controller.serviceResult != 0)
                    _previewRow(
                      context,
                      icon: Icons.build,
                      label: "Service Result",
                      value: controller.serviceResult == 1
                          ? "Solved"
                          : "Not Solved",
                    ),
                  if (controller.repairNote.isNotEmpty ||
                      controller.repairNote != null)
                    _previewRow(
                      context,
                      icon: Icons.report_gmailerrorred_rounded,
                      label: "Repair Note",
                      value: controller.repairNote,
                    ),

                  if (controller.unsolvedReasonId != 0 &&
                      controller.unsolvedReason.value != null)
                    _previewRow(
                      context,
                      icon: Icons.report_problem_outlined,
                      label: "Unsolved Reason",
                      value:
                          controller.unsolvedReason.value!.lookupData
                              .firstWhereOrNull(
                                (e) =>
                                    e.intLookupId ==
                                    controller.unsolvedReasonId,
                              )
                              ?.strLookupText ??
                          "—",
                    ),

                  if (controller.unsolvedNote != null &&
                      controller.unsolvedNote!.trim().isNotEmpty)
                    _previewRow(
                      context,
                      icon: Icons.note_alt_outlined,
                      label: "Unsolved Note",
                      value: controller.unsolvedNote!,
                    ),

                  if (widget.isReplace) ...[
                    if (controller.oldSerialNumber.text.trim().isNotEmpty)
                      _previewRow(
                        context,
                        icon: Icons.qr_code_2_outlined,
                        label: "Old Serial Number",
                        value: controller.oldSerialNumber.text.trim(),
                      ),

                    if (widget.isReplace &&
                        controller.selectedNewCustody != null) ...[
                      // const SizedBox(height: 8),
                      _previewRow(
                        context,
                        icon: Icons.qr_code_2_outlined,
                        label: "New Serial Number",
                        value: controller.selectedNewCustody!.serialNumber,
                      ),

                      _previewRow(
                        context,
                        icon: Icons.confirmation_number_outlined,
                        label: "New Part Number",
                        value: controller.selectedNewCustody!.partNumber,
                      ),

                      _previewRow(
                        context,
                        icon: Icons.memory_outlined,
                        label: "New Content Name",
                        value: controller.selectedNewCustody!.contentName,
                      ),

                      _previewRow(
                        context,
                        icon: Icons.devices_other_outlined,
                        label: "New Product Name",
                        value: controller.selectedNewCustody!.poductName,
                      ),
                    ],
                    if (controller.repairNoteController.text.trim().isNotEmpty)
                      _previewRow(
                        context,
                        icon: Icons.description_outlined,
                        label: "Note",
                        value: controller.repairNoteController.text.trim(),
                      ),

                    if (controller.tripTime.isNotEmpty)
                      _previewRow(
                        context,
                        icon: Icons.timer_outlined,
                        label: "Trip Time",
                        value: controller.tripTime,
                      ),
                  ],
                  const SizedBox(height: 20),

                  // 🔹 Actions
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Get.back(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorApp.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "OK",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      barrierDismissible: false,
    );
  }

  Widget _previewRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: theme.iconTheme.color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(value, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text("Client Signature")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    "Client Name",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    icon: Icon(
                      Icons.fact_check_outlined,
                      color: ColorApp.primary,
                      size: 20,
                    ),
                    label: Text(
                      "Service Summary",
                      style: TextStyle(
                        color: ColorApp.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () {
                      showSignaturePreviewDialog();
                    },
                  ),
                ],
              ),

              const SizedBox(height: 4),
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: isDark
                      ? theme.colorScheme.surface
                      : Colors.grey.shade50,

                  hintText: "Enter client full name",
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),

                  hintStyle: const TextStyle(
                    // color: Colors.black45,
                    fontSize: 13,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.black12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    borderSide: BorderSide(color: ColorApp.primary, width: 0.3),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Client Signature",
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isDark ? Colors.white : Colors.black38,
                      width: 0.4,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey.shade50,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Signature(
                      controller: _signatureController,
                      backgroundColor: isDark
                          ? theme.colorScheme.surface
                          : Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 🔹 Save & Clear Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _signatureController.clear();
                      },
                      icon: const Icon(Icons.clear, color: Colors.black87),
                      label: const Text(
                        "Clear",
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade300,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Obx(() {
                      return ElevatedButton.icon(
                        onPressed: controller.isClosing.value
                            ? null
                            : () async {
                                if (_signatureController.isEmpty ||
                                    nameController.text.isEmpty) {
                                  Get.snackbar(
                                    "Incomplete",
                                    "Please enter name and signature first ⚠️",
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: Colors.orange.shade100,
                                    colorText: Colors.black87,
                                  );
                                  return;
                                }
                                final sigBytes = await _signatureController
                                    .toPngBytes();
                                if (sigBytes == null) return;

                                final base64Signature = base64Encode(sigBytes);

                                if (widget.isReplace) {
                                  await controller.replaceServiceRecord(
                                    clientSignature: base64Signature,
                                    signatureName: nameController.text.trim(),
                                  );
                                } else {
                                  await controller.repairServiceRecord(
                                    clientSignature: base64Signature,
                                    signatureName: nameController.text.trim(),
                                  );
                                }
                              },
                        icon: controller.isClosing.value
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.save_alt, color: Colors.white),
                        label: Text(
                          controller.isClosing.value
                              ? "Saving..."
                              : "Save Record",
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorApp.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
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
      ),
    );
  }
}
