import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ticket_app/ui/dashboard/screens/client_signature_screen.dart';

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
  bool isRepair = true;
  String? selectedFault;
  String? selectedContentUsed;

  final TextEditingController repairNoteController = TextEditingController();
  final TextEditingController oldVersionController = TextEditingController();
  final TextEditingController newVersionController = TextEditingController();

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

            const SizedBox(height: 25),

            // 🔹 Section: Repair / Replace Details
            Text("Service Details", style: sectionTitleStyle),
            const SizedBox(height: 10),
            _solutionSelector(),
            const SizedBox(height: 10),
            _buildDynamicFields(),

            const SizedBox(height: 30),

            // 🔹 Save Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final controller = Get.put(ServiceRecordController());

                  await controller.fetchUnsolvedReasons(
                    widget.subProductFileId,
                  );

                  controller.serviceRecordId = widget.recordId;
                  controller.ticketId = widget.ticketId;
                  controller.tripTime = DateTime.now()
                      .toLocal()
                      .toString()
                      .split(' ')[0];
                  controller.repairNote = repairNoteController.text;
                  _showResolutionDialog(controller);
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
          ],
        ),
      ),
    );
  }

  Widget _ticketInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: ColorApp.primary.withValues(alpha: 0.25)),
        borderRadius: BorderRadius.circular(14),
        color: Colors.white,
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
                radius: 24,
                backgroundColor: Color(0xFFE3F2FD),
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
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
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
          selected: isRepair,
          onTap: () => setState(() => isRepair = true),
        ),
        // const SizedBox(width: 10),
        // _solutionButton(label: "Replace", selected: !isRepair, onTap: () {}),
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
    if (isRepair) {
      return _textInput(
        "Repair Note",
        controller: repairNoteController,
        maxLines: 5,
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _textInput("Repair Note", controller: repairNoteController),
          const SizedBox(height: 10),
          _dropdownRow(
            "Content Used",
            ["Card Reader", "Display", "Cable"],
            (val) => setState(() => selectedContentUsed = val),
            selectedContentUsed,
          ),
          const SizedBox(height: 10),
          _snRow("Old S/N"),
          _textInput("Old Version", controller: oldVersionController),
          _snRow("New S/N"),
          _textInput("New Version", controller: newVersionController),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _actionButton("Add Extra Content", ColorApp.primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _actionButton("List Added Content", ColorApp.primary),
              ),
            ],
          ),
        ],
      );
    }
  }

  InputDecoration _fieldDecoration(String label, String hint) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.black38, fontSize: 13.5),
      filled: true,
      fillColor: Colors.white,
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
    int? maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(fontSize: 14.5, color: Colors.black87),
        decoration: _fieldDecoration(label, "Enter $label"),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black12.withValues(alpha: 0.1)),
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
                  color: Colors.black87,
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
                  color: Colors.black54,
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

  Widget _dropdownRow(
    String label,
    List<String> items,
    ValueChanged<String?> onChanged,
    String? selectedValue,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: DropdownButtonFormField<String>(
        value: items.contains(selectedValue) ? selectedValue : null,
        items: items
            .map(
              (item) => DropdownMenuItem(
                value: item,
                child: Text(item, style: const TextStyle(fontSize: 14.5)),
              ),
            )
            .toList(),
        onChanged: onChanged,
        icon: const Icon(
          Icons.keyboard_arrow_down_rounded,
          color: Colors.black54,
        ),
        decoration: _fieldDecoration(label, "Select $label"),
        dropdownColor: Colors.white,
      ),
    );
  }

  Widget _snRow(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 9,
            child: _dropdownRow(
              label,
              ["0000000000", "1111111111"],
              (val) {},
              null,
            ),
          ),
          const SizedBox(width: 6),
          IconButton(
            onPressed: () {
              Get.snackbar(
                "Scan",
                "Scanning QR for $label...",
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.blue.shade100,
              );
            },
            icon: Icon(Icons.qr_code_2, color: ColorApp.primary),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(String text, Color color) {
    return SizedBox(
      height: 45,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

void _showResolutionDialog(ServiceRecordController controller) {
  bool isSolved = true;
  String? selectedReason;
  final TextEditingController noteController = TextEditingController();

  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
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
                        color: ColorApp.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.build_circle_outlined,
                        color: ColorApp.primary,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      "Close Service Record",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),
                const Text(
                  "Was the issue resolved?",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15.5,
                    color: Colors.black87,
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
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            "Yes, Solved",
                            style: TextStyle(
                              color: isSolved ? Colors.white : Colors.black87,
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
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            "Not Solved",
                            style: TextStyle(
                              color: !isSolved ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // 🔹 Dropdown + Note Field (if not solved)
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
                            controller.unsolvedReason.value?.lookupData ?? [];
                        return DropdownButtonFormField<String>(
                          dropdownColor: Colors.white,

                          isExpanded: true,
                          value: selectedReason,

                          decoration: InputDecoration(
                            labelText: "Select Unsolved Reason",
                            labelStyle: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: ColorApp.primary.withValues(alpha: 0.25),
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
                                  child: Text(r.strLookupText),
                                ),
                              )
                              .toList(),
                          onChanged: (val) =>
                              setState(() => selectedReason = val),
                        );
                      }),

                      const SizedBox(height: 12),

                      // 🔸 Note Field
                      TextFormField(
                        controller: noteController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: "Unsolved Note",
                          hintText: "Add a note explaining the issue...",
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: ColorApp.primary.withValues(alpha: 0.25),
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
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
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (!isSolved && selectedReason == null) {
                            Get.snackbar(
                              "Missing Reason ⚠️",
                              "Please select a reason before continuing.",
                              snackPosition: SnackPosition.TOP,
                              backgroundColor: Colors.yellow.shade100,
                              colorText: Colors.black87,
                            );
                            return;
                          }

                          controller.serviceResult = isSolved ? 1 : 2;
                          controller.unsolvedReasonId = isSolved
                              ? 0
                              : int.parse(selectedReason ?? '0');
                          controller.unsolvedNote = isSolved
                              ? ''
                              : noteController.text.trim();

                          Get.back();
                          Get.to(() => const ClientSignatureScreen());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorApp.primary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Confirm",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
