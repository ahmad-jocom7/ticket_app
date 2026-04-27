import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:ticket_app/ui/dashboard/screens/client_signature_screen.dart';

import '../../../model/custody/custody_model.dart';
import '../../../utils/color_app.dart';
import '../../../controller/close_record_controller.dart';

class OpenServiceRecordScreen extends StatefulWidget {
  final int recordId;
  final int ticketId;
  final int subProductFileId;
  final String? recordData;

  const OpenServiceRecordScreen({
    super.key,
    required this.recordId,
    required this.ticketId,
    required this.subProductFileId,
    this.recordData,
  });

  @override
  State<OpenServiceRecordScreen> createState() =>
      _OpenServiceRecordScreenState();
}

class _OpenServiceRecordScreenState extends State<OpenServiceRecordScreen> {
  final controller = ServiceRecordController.to;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    const sectionTitleStyle = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
      color: Color(0xFF1976D2),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Open Service Record')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Section: Ticket Info
            Text("Ticket Information", style: sectionTitleStyle),
            const SizedBox(height: 8),
            _ticketInfoCard(),

            const SizedBox(height: 10),

            // 🔹 Section: Repair / Replace Details
            Text("Service Details", style: sectionTitleStyle),
            const SizedBox(height: 10),
            GetBuilder<ServiceRecordController>(
              builder: (logic) {
                return _solutionSelector();
              },
            ),
            const SizedBox(height: 10),
            GetBuilder<ServiceRecordController>(
              builder: (logic) {
                return _buildDynamicFields();
              },
            ),

            const SizedBox(height: 10),

            // 🔹 Save Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;
                  controller.serviceRecordId = widget.recordId;
                  controller.ticketId = widget.ticketId;
                  controller.tripTime = DateTime.now()
                      .toLocal()
                      .toString()
                      .split(' ')[0];
                  controller.repairNote = controller.repairNoteController.text;

                  if (controller.isRepair) {
                    await controller.fetchUnsolvedReasons(
                      widget.subProductFileId,
                    );

                    _showResolutionDialog(controller);
                  } else {
                    if (!controller.validateReplace()) return;

                    Get.to(() => const ClientSignatureScreen(isReplace: true));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorApp.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.save_alt, color: Colors.white),
                label: const Text(
                  "Save Record",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

          ],
        ),
      ),
    );
  }

  Widget _ticketInfoCard() {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: ColorApp.primary.withValues(alpha: 0.25)),
        borderRadius: BorderRadius.circular(14),
        color: theme.cardColor,

        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 25,
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
              const SizedBox(width: 10),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: "Ticket No. ",
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: "( ${widget.ticketId} )",
                      style: TextStyle(
                        color: ColorApp.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _infoRow("Record No.", widget.recordId.toString()),
          _infoRow(
            "Record Date",
            widget.recordData ??
                DateTime.now().toLocal().toString().split(' ')[0],
          ),
        ],
      ),
    );
  }

  Widget _solutionSelector() {
    return Row(
      children: [
        _solutionButton(
          label: "Repair",
          selected: controller.isRepair,
          onTap: () => controller.changeTap(true),
        ),
        // const SizedBox(width: 10),
        // _solutionButton(
        //   label: "Replace",
        //   selected: !controller.isRepair,
        //   onTap: () {
        //     controller.changeTap(false);
        //   },
        // ),
      ],
    );
  }

  Widget _solutionButton({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 42,
          decoration: BoxDecoration(
            color: selected ? ColorApp.primary : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: ColorApp.primary),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.blue.withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : ColorApp.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDynamicFields() {
    if (controller.isRepair) {
      return Form(
        key: _formKey,
        child: Column(
          children: [
            _textInput(
              // validator: (value) {
              //   if (value!.isEmpty || value == null) {
              //     return "please enter repair note";
              //   }
              // },
              "Actual Fault",
              controller: controller.actualFault,
              maxLines: 2,
            ),
            _textInput(
              validator: (value) {
                if (value!.isEmpty || value == null) {
                  return "please enter repair note";
                }
              },
              "Repair Note",
              controller: controller.repairNoteController,
              maxLines: 4,
            ),

          ],
        ),
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),

          _textInput(
            "Old S/N",
            keyboardType: TextInputType.number,
            controller: controller.oldSerialNumber,
            suffixIcon: IconButton(
              icon: const Icon(Icons.fit_screen_outlined),
              onPressed: () async {
                final result = await Get.to<String>(
                  () => const BarcodeScannerScreen(),
                );

                if (result != null && result.isNotEmpty) {
                  controller.oldSerialNumber.text = result;
                }

                // final result = await _scanBarcode(context);
                // if (result != null && result.isNotEmpty) {
                //   controller.oldSerialNumber.text = result;
                // }
              },
            ),
          ),

          _snRow("New S/N"),
          _textInput(
            "Note",
            maxLines: 2,
            controller: controller.repairNoteController,
          ),
        ],
      );
    }
  }

  // Future<String?> _scanBarcode(BuildContext context) async {
  //   String? scannedCode;
  //   bool isScanned = false;
  //
  //   await Get.to(() => Scaffold(
  //     backgroundColor: Colors.black,
  //     appBar: AppBar(
  //       title: const Text('Scan Barcode'),
  //       backgroundColor: Colors.black,
  //     ),
  //     body: Stack(
  //       children: [
  //         MobileScanner(
  //           onDetect: (BarcodeCapture capture) {
  //             if (isScanned) return;
  //
  //             final barcodes = capture.barcodes;
  //             if (barcodes.isNotEmpty) {
  //               final code = barcodes.first.rawValue;
  //               if (code != null && code.isNotEmpty) {
  //                 isScanned = true;
  //                 scannedCode = code;
  //
  //                 // ⏳ أعطي Flutter فريم واحد قبل الرجوع
  //                 Future.microtask(() => Get.back());
  //               }
  //             }
  //           },
  //         ),
  //         _ScannerOverlay(),
  //       ],
  //     ),
  //   ));
  //
  //   return scannedCode;
  // }

  InputDecoration _fieldDecoration(String label, String hint) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        // color: Colors.black87,
      ),

      hintText: hint,
      hintStyle: const TextStyle(fontSize: 13.5),
      filled: true,
      fillColor: isDark ? theme.colorScheme.surface : Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: ColorApp.primary.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide(color: ColorApp.primary, width: 1.3),
      ),
    );
  }

  Widget _textInput(
    String label, {
    TextEditingController? controller,
    TextInputType? keyboardType,
    int? maxLines = 1,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        validator: validator,
        keyboardType: keyboardType,
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(fontSize: 14.5),
        decoration: _fieldDecoration(
          label,
          "Enter $label",
        ).copyWith(suffixIcon: suffixIcon),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: theme.cardColor,

          borderRadius: BorderRadius.circular(10),
          // border: Border.all(color: Colors.black12.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  // color: Colors.black87,
                  fontSize: 14,
                ),
              ),
            ),
            Expanded(
              flex: 6,
              child: Text(
                value.isNotEmpty ? value : "—",
                textAlign: TextAlign.right,
                style: const TextStyle(
                  // color: Colors.black54,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _snRow(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Obx(() {
        if (controller.isCustodyLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.custodyList.isEmpty) {
          return Text(
            "No Serial Numbers Available",
            style: TextStyle(color: Colors.red.shade400),
          );
        }

        return DropdownButtonFormField<CustodyData>(
          value: controller.selectedNewCustody,
          items: controller.custodyList.map((item) {
            return DropdownMenuItem<CustodyData>(
              value: item,
              child: Text(
                item.serialNumber,
                style: const TextStyle(fontSize: 14.5),
              ),
            );
          }).toList(),
          onChanged: (val) {
            controller.selectedNewCustody = val;
          },
          decoration: _fieldDecoration(label, "Select Serial Number"),
        );
      }),
    );
  }
}

void _showResolutionDialog(ServiceRecordController controller) {
  bool isSolved = true;
  String? selectedReason;
  final TextEditingController noteController = TextEditingController();

  Get.dialog(
    Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return Center(
          child: SizedBox(
            child: Dialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 10),

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: theme.dialogTheme.backgroundColor,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: StatefulBuilder(
                    builder: (context, setState) => Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 🔹 Title
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
                              child: Icon(
                                Icons.build_circle_outlined,
                                color: ColorApp.primary,
                                size: 26,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              "Close Service Record",
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),
                        Text(
                          "Was the issue resolved?",
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // 🔸 Toggle Buttons
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => isSolved = true),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  height: 45,
                                  decoration: BoxDecoration(
                                    color: isSolved
                                        ? ColorApp.primary
                                        : theme.colorScheme.surface,
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    "Yes, Solved",
                                    style: TextStyle(
                                      color: isSolved
                                          ? Colors.white
                                          : theme.textTheme.bodyMedium?.color,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => isSolved = false),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  height: 45,
                                  decoration: BoxDecoration(
                                    color: !isSolved
                                        ? Colors.red.shade800
                                        : theme.colorScheme.surface,
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    "Not Solved",
                                    style: TextStyle(
                                      color: !isSolved
                                          ? Colors.white
                                          : theme.textTheme.bodyMedium?.color,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),
                        GetBuilder<ServiceRecordController>(
                          builder: (logic) {
                            return DropdownButtonFormField<int>(
                              value: controller.serviceLocation,
                              dropdownColor: theme.dialogTheme.backgroundColor,
                              decoration: InputDecoration(
                                labelText: "Service Location",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: ColorApp.primary.withValues(
                                      alpha: 0.25,
                                    ),
                                    width: 1,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: ColorApp.primary,
                                    width: 1.3,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 0,
                                  child: Text("On Site"),
                                ),
                                DropdownMenuItem(
                                  value: 1,
                                  child: Text("Workshop"),
                                ),
                              ],
                              onChanged: (val) {
                                controller.serviceLocation = val ?? 0;
                                controller.update();
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 10),

                        if (!isSolved)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Obx(() {
                                if (controller.isLoading.value) {
                                  return const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(8),
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                }

                                final reasons =
                                    controller
                                        .unsolvedReason
                                        .value
                                        ?.lookupData ??
                                    [];

                                return DropdownButtonFormField<String>(
                                  dropdownColor:
                                      theme.dialogTheme.backgroundColor,
                                  isExpanded: true,
                                  value: selectedReason,
                                  decoration: InputDecoration(
                                    labelText: "Select Unsolved Reason",
                                    labelStyle: theme.textTheme.bodyMedium
                                        ?.copyWith(fontWeight: FontWeight.w500),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color: ColorApp.primary.withValues(
                                          alpha: 0.25,
                                        ),
                                        width: 1,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(10),
                                      ),
                                      borderSide: BorderSide(
                                        color: ColorApp.primary,
                                        width: 1.3,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 12,
                                    ),
                                  ),
                                  items: reasons
                                      .map(
                                        (r) => DropdownMenuItem(
                                          value: r.intLookupId.toString(),
                                          child: Text(
                                            r.strLookupText,
                                            style: theme.textTheme.bodyMedium,
                                          ),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (val) =>
                                      setState(() => selectedReason = val),
                                );
                              }),

                              const SizedBox(height: 12),

                              TextFormField(
                                controller: noteController,
                                maxLines: 5,
                                style: theme.textTheme.bodyMedium,
                                decoration: InputDecoration(
                                  labelText: "Unsolved Note",
                                  hintText:
                                      "Add a note explaining the issue...",
                                  labelStyle: theme.textTheme.bodyMedium,

                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color: ColorApp.primary.withValues(
                                        alpha: 0.25,
                                      ),
                                      width: 1,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10),
                                    ),
                                    borderSide: BorderSide(
                                      color: ColorApp.primary,
                                      width: 1.3,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),

                        const SizedBox(height: 25),

                        // 🔹 Actions
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Get.back(),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor:
                                      theme.textTheme.bodyMedium?.color,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  "Cancel",
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Expanded(
                            //   child: ElevatedButton(
                            //     onPressed: () async {
                            //       if (!isSolved && selectedReason == null) {
                            //         Get.snackbar(
                            //           "Missing Reason ⚠️",
                            //           "Please select a reason before continuing.",
                            //           snackPosition: SnackPosition.TOP,
                            //           backgroundColor: isDark
                            //               ? Colors.orange.shade700
                            //               : Colors.yellow.shade100,
                            //           colorText: isDark
                            //               ? Colors.white
                            //               : Colors.black87,
                            //         );
                            //
                            //         return;
                            //       }
                            //
                            //       controller.serviceResult = isSolved ? 1 : 2;
                            //       controller.unsolvedReasonId = isSolved
                            //           ? 0
                            //           : int.parse(selectedReason ?? '0');
                            //       controller.unsolvedNote = isSolved
                            //           ? ''
                            //           : noteController.text.trim();
                            //
                            //       Get.back();
                            //       if (controller.serviceLocation == 1) {
                            //         await controller.repairServiceRecord(
                            //           clientSignature: "",
                            //           signatureName: "",
                            //         );
                            //       } else {
                            //         Get.to(() => const ClientSignatureScreen());
                            //       }
                            //     },
                            //     style: ElevatedButton.styleFrom(
                            //       backgroundColor: ColorApp.primary,
                            //       padding: const EdgeInsets.symmetric(
                            //         vertical: 12,
                            //       ),
                            //       shape: RoundedRectangleBorder(
                            //         borderRadius: BorderRadius.circular(12),
                            //       ),
                            //     ),
                            //     child: const Text(
                            //       "Confirm",
                            //       style: TextStyle(
                            //         fontWeight: FontWeight.w600,
                            //         color: Colors.white,
                            //       ),
                            //     ),
                            //   ),
                            // ),
                            Expanded(
                              child: Obx(() => ElevatedButton(
                                onPressed: controller.isClosing.value
                                    ? null
                                    : () async {
                                  if (!isSolved && selectedReason == null) {
                                    Get.snackbar(
                                      "Missing Reason ⚠️",
                                      "Please select a reason before continuing.",
                                      snackPosition: SnackPosition.TOP,
                                    );
                                    return;
                                  }

                                  controller.serviceResult = isSolved ? 1 : 0;
                                  controller.unsolvedReasonId =
                                  isSolved ? 0 : int.parse(selectedReason ?? '0');
                                  controller.unsolvedNote =
                                  isSolved ? '' : noteController.text.trim();


                                  if (controller.serviceLocation == 1) {
                                    await controller.repairServiceRecord(
                                      clientSignature: "",
                                      signatureName: "",
                                      back: true
                                    );

                                  } else {
                                    Get.back();

                                    Get.to(() => const ClientSignatureScreen());
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: ColorApp.primary,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: controller.isClosing.value
                                    ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                                    : const Text(
                                  "Confirm",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              )),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
}

class _ScannerOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Container(color: Colors.black.withValues(alpha: 0.5)),

          Center(
            child: Container(
              width: 260,
              height: 160,
              decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border.all(color: Colors.greenAccent, width: 3),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  bool isScanned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Scan Barcode'),
        backgroundColor: Colors.black,
      ),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (capture) {
              if (isScanned) return;

              final barcodes = capture.barcodes;
              if (barcodes.isNotEmpty) {
                final code = barcodes.first.rawValue;
                if (code != null && code.isNotEmpty) {
                  isScanned = true;

                  Future.delayed(const Duration(milliseconds: 100), () {
                    Navigator.of(context).pop(code);
                  });
                }
              }
            },
          ),
          _ScannerOverlay(),
        ],
      ),
    );
  }
}
