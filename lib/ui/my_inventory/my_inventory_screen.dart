import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ticket_app/controller/custody_controller.dart';
import 'package:ticket_app/model/custody/custody_model.dart';
import '../../../utils/color_app.dart';
import '../../model/ticket/response_model.dart';
import '../../utils/text_style.dart';

class MyCustodyScreen extends StatelessWidget {
  MyCustodyScreen({super.key});

  final controller = CustodyController.to;

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
                // style: const TextStyle(fontSize: 16, color: Colors.black54),
              ),
            );
          }

          if (controller.custodyList.isEmpty) {
            return const Center(
              child: Text(
                "No custody items found",
                // style: TextStyle(fontSize: 16, color: Colors.black54),
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
    final theme = Get.theme;

    final cardColor = theme.cardColor;
    final primaryTextColor = theme.textTheme.bodyLarge?.color;
    final dividerColor = theme.dividerColor;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(18),
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        // ✅ changed: theme-based card color
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            // ✅ changed: softer shadow for dark/light
            color: Colors.black.withValues(
              alpha: theme.brightness == Brightness.dark ? 0.25 : 0.07,
            ),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        // ✅ changed: adaptive border
        border: Border.all(color: dividerColor.withValues(alpha: 0.2)),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 Header -----------------------------------------------------
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
                  // ✅ changed: shared text style + theme color
                  style: semibold18.copyWith(color: primaryTextColor),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ✅ changed: divider uses theme color
          Divider(height: 1, color: dividerColor.withValues(alpha: 0.25)),

          const SizedBox(height: 16),

          // 🔹 Info rows (already themed)
          _rowInfo("Part No", item.partNumber),
          _rowInfo("Serial", item.serialNumber),
          _rowInfo("Product", item.poductName),
          _rowInfo("Received On", item.addedAt),

          const SizedBox(height: 18),

          // 🔹 Action / Status
          if (item.hasDeliveryRequest == 0)
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () {
                  showDeliveryDialog(item: item, controller: controller);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorApp.primary,
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
                  // ✅ changed: status color adapts well in dark/light
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
                    const SizedBox(width: 8),
                    Text(
                      'Request Sent • Pending',
                      // ✅ changed: shared style
                      style: semibold12.copyWith(color: ColorApp.primary),
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
    final theme = Get.theme;

    final primaryTextColor = theme.textTheme.bodyMedium?.color;
    final secondaryTextColor = theme.textTheme.bodySmall?.color;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              "$title:",
              // ✅ changed: use shared text style + theme color
              style: semibold14.copyWith(color: primaryTextColor),
            ),
          ),
          Expanded(
            child: Text(
              value,
              // ✅ changed: use shared text style + secondary theme color
              style: regular14.copyWith(color: secondaryTextColor),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> showDeliveryDialog({
  required CustodyData item,
  required CustodyController controller,
}) async {
  final TextEditingController descriptionController = TextEditingController();
  Widget dropdownSearchField<T>({
    required BuildContext context, // ✅ changed
    required String title,
    required T? value,
    required List<T> items,
    required String hint,
    required String Function(T item) display,
    required Function(T?) onChanged,
    bool Function(T, T)? compareFn,
    bool isLoading = false,
  }) {
    final theme = Theme.of(context); // ✅ changed
    final isDark = theme.brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w600), // ✅ changed
          ),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: theme.cardColor, // ✅ changed
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.3)
                      : Colors.black.withValues(alpha: 0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: DropdownSearch<T>(
              enabled: !isLoading,
              selectedItem: value,
              compareFn: compareFn ?? (a, b) => a == b,
              items: (filter, _) {
                return items.where((item) {
                  final text = display(item).toLowerCase();
                  return filter == null ||
                      text.contains(filter.toLowerCase());
                }).toList();
              },
              itemAsString: (item) => display(item),
              popupProps: PopupProps.dialog(
                showSearchBox: true,
                dialogProps: DialogProps(
                  backgroundColor: theme.cardColor, // ✅ changed
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              decoratorProps: DropDownDecoratorProps(
                decoration: InputDecoration(
                  
                  filled: true,
                  fillColor: isDark
                      ? theme.colorScheme.surface
                      : Colors.grey.shade100,

                  hintText: hint,
                  hintStyle:
                  theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 16,
                  ),
                  border: OutlineInputBorder(borderSide: BorderSide.none,borderRadius: BorderRadius.circular(20 )),
                ),
              ),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
  await Get.dialog(
    Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 10),
          backgroundColor: theme.dialogTheme.backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
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
                          color: ColorApp.primary.withValues(
                            alpha: isDark ? 0.25 : 0.12,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.inventory_2_rounded,
                          color: ColorApp.primary,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Send Delivery Request',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  Obx(() {
                    return dropdownSearchField<LookupDatum>(
                      context: context,
                      title: "To",
                      value: controller.selectedEmployee.value,
                      items: controller.employees,
                      hint: "Select Employee",
                      display: (item) => item.strLookupText,
                      compareFn: (a, b) => a.intLookupId == b.intLookupId,
                      onChanged: (item) {
                        controller.selectedEmployee.value = item;
                      },
                      isLoading: controller.isLoadingEmployees.value,
                    );
                  }),
                  const SizedBox(height: 10),

                  // Description field
                  TextField(
                    controller: descriptionController,
                    maxLines: 6,
                    onChanged: (_) =>
                    controller.descriptionError.value = '',
                    style: theme.textTheme.bodyMedium,
                    decoration: InputDecoration(
                      hintText: 'Enter description...',
                      hintStyle: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.hintColor,
                      ),
                      filled: true,
                      fillColor: isDark
                          ? theme.colorScheme.surface
                          : Colors.grey.shade100,
                      errorText:
                      controller.descriptionError.value.isEmpty
                          ? null
                          : controller.descriptionError.value,

                      // ❗ هذا الجزء لم يتغير
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),

                      contentPadding: const EdgeInsets.all(14),
                    ),
                  ),

                  const SizedBox(height: 22),

                  // Actions
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed:
                          controller.isSendingLoading.value
                              ? null
                              : () => Get.back(),
                          style: TextButton.styleFrom(
                            foregroundColor:
                            theme.textTheme.bodyMedium?.color,
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),

                      Expanded(
                        child: ElevatedButton(
                          onPressed:
                          controller.isSendingLoading.value
                              ? null
                              : () async {
                            if (descriptionController.text
                                .trim()
                                .isEmpty) {
                              controller
                                  .descriptionError.value =
                              'Description is required';
                              return;
                            }

                            await controller.sendDeliveryRequest(
                              custodyId: item.id,
                              description:
                              descriptionController.text
                                  .trim(),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorApp.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(14),
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
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }),
          ),
        );
      },
    ),
    barrierDismissible: false,
  );

}
