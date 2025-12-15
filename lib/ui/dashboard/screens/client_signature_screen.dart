import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signature/signature.dart';
import '../../../utils/color_app.dart';
import '../../../controller/close_record_controller.dart';
import '../../../utils/snackbar.dart';

class ClientSignatureScreen extends StatefulWidget {
  const ClientSignatureScreen({super.key});

  @override
  State<ClientSignatureScreen> createState() => _ClientSignatureScreenState();
}

class _ClientSignatureScreenState extends State<ClientSignatureScreen> {
  final TextEditingController nameController = TextEditingController();

  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 2,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  @override
  void dispose() {
    _signatureController.dispose();
    super.dispose();
  }

  final controller = Get.find<ServiceRecordController>();

  Future<void> showSignaturePreviewDialog({
    required String name,
  }) async {
    await Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Review Client Details",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 14),

              // Name
              Row(
                children: [
                  const Icon(Icons.person, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      child: const Text("Edit"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Get.back(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorApp.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Looks Good",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Client Signature"),
        actions: [
          IconButton(
            icon: const Icon(Icons.visibility),
            tooltip: 'Review Details',
            onPressed: () async {
              if (_signatureController.isEmpty ||
                  nameController.text.trim().isEmpty) {
                showError("Please enter name and signature first");
                return;
              }

              final sigBytes = await _signatureController.toPngBytes();
              if (sigBytes == null) return;

              showSignaturePreviewDialog(
                name: nameController.text.trim(),
              );
            },
          ),
        ],
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Client Name",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: "Enter client full name",
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  hintStyle: const TextStyle(
                    color: Colors.black45,
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
              const SizedBox(height: 16),
              const Text(
                "Client Signature",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: ColorApp.primary.withValues(alpha: 0.5),
                      width: 0.4,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey.shade50,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Signature(
                      controller: _signatureController,
                      backgroundColor: Colors.white,
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
                        nameController.clear();
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

                                await controller.closeServiceRecord(
                                  clientSignature: base64Signature,
                                  signatureName: nameController.text.trim(),
                                );
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
