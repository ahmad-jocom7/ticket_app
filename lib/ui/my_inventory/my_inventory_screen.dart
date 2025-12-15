import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ticket_app/controller/custody_controller.dart';
import 'package:ticket_app/model/custody/custody_model.dart';
import '../../../utils/color_app.dart';

class MyCustodyScreen extends StatefulWidget {
  const MyCustodyScreen({super.key});

  @override
  State<MyCustodyScreen> createState() => _MyCustodyScreenState();
}

class _MyCustodyScreenState extends State<MyCustodyScreen> {
  final controller = CustodyController.to;

  @override
  void initState() {
    super.initState();
    controller.fetchCustody();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Custody")),

      body: GetBuilder<CustodyController>(
        builder: (controller) {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.errorMessage.isNotEmpty) {
            return Center(
              child: Text(
                controller.errorMessage.value,
                style: const TextStyle(fontSize: 16, color: Colors.black54),
              ),
            );
          }

          if (controller.custodyList.isEmpty) {
            return const Center(
              child: Text(
                "No custody items found",
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.custodyList.length,
            itemBuilder: (_, i) {
              return _inventoryCard(controller.custodyList[i]);
            },
          );
        },
      ),
    );
  }

  Widget _inventoryCard(CustodyData item) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(18),
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.black12.withValues(alpha: 0.08)),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row -----------------------------------------------------
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: ColorApp.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.inventory_2_rounded,
                  color: ColorApp.primary,
                  size: 26,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Text(
                  item.contentName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(height: 1, color: Colors.black12),
          const SizedBox(height: 16),

          _rowInfo("Part No", item.partNumber),
          _rowInfo("Serial", item.serialNumber),
          _rowInfo("Product", item.poductName),
          _rowInfo("Received On", item.addedAt),

          const SizedBox(height: 18),
          const SizedBox(height: 12),

          if (item.hasDeliveryRequest == 0)
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () {
                  showDeliveryDialog(
                    context: context,
                    item: item,
                    controller: controller,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorApp.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.send_rounded, size: 18),
                label: const Text(
                  'Send Delivery Request',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            )
          else
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: ColorApp.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: ColorApp.primary.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.hourglass_top_rounded,
                      size: 18,
                      color: ColorApp.primary,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Request Sent • Pending',
                      style: TextStyle(
                        color: ColorApp.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _rowInfo(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              "$title:",
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14.5,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14.5, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> showDeliveryDialog({
  required BuildContext context,
  required CustodyData item,
  required CustodyController controller,
}) async {
  final TextEditingController descriptionController = TextEditingController();

  await Get.dialog(
    Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Obx(() {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: ColorApp.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.inventory_2_rounded,
                      color: ColorApp.primary,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Send Delivery Request',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Obx(() {
                return TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  onChanged: (_) => controller.descriptionError.value = '',
                  decoration: InputDecoration(
                    hintText: 'Enter description...',
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    errorText: controller.descriptionError.value.isEmpty
                        ? null
                        : controller.descriptionError.value,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(14),
                  ),
                );
              }),

              const SizedBox(height: 22),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: controller.isSendingLoading.value
                          ? null
                          : () => Get.back(),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: controller.isSendingLoading.value
                          ? null
                          : () async {
                              if (descriptionController.text.trim().isEmpty) {
                                controller.descriptionError.value =
                                    'Description is required';
                                return;
                              }

                              await controller.sendDeliveryRequest(
                                custodyId: item.id,
                                description: descriptionController.text.trim(),
                              );
                            },

                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorApp.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: controller.isSendingLoading.value
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Confirm',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          );
        }),
      ),
    ),
    barrierDismissible: false,
  );
}
