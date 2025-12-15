import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/edit_request_controller.dart';
import '../../model/delivery_request/request_model.dart';
import '../../model/ticket/response_model.dart';
import '../../utils/color_app.dart';

class EditRequestScreen extends StatelessWidget {
  final LstRequest item;

  const EditRequestScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EditRequestController(item));

    return Scaffold(
      appBar: AppBar(title: const Text("Edit Request")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _inputField("Part Number", controller.partNumber),
            _inputField("Description", controller.description, maxLines: 3),
            _inputField("Cu stomer Name", controller.customerName),
            _inputField("Branch", controller.branch),

            const SizedBox(height: 10),

            Obx(() {
              return dropdownSearchField<LookupDatum>(
                title: "Sub Product",
                value: controller.selectedSubProduct.value,
                items: controller.subProducts,
                hint: "Select Sub Product",
                isLoading: controller.isLoadingSubProducts.value,
                display: (item) => item.strLookupText,
                compareFn: (a, b) => a.intLookupId == b.intLookupId,
                onChanged: (item) {
                  controller.selectedSubProduct.value = item;
                  if (item != null) {
                    controller.loadContents(item.intLookupId);
                  } else {
                    controller.contents.clear();
                    controller.selectedContent.value = null;
                  }
                },
              );
            }),

            Obx(() {
              return dropdownSearchField<LookupDatum>(
                title: "Content",
                value: controller.selectedContent.value,
                items: controller.contents,
                hint: controller.selectedSubProduct.value == null
                    ? "Select Sub Product first"
                    : "Select Content",
                isLoading: controller.isLoadingContents.value,
                display: (item) => item.strLookupText,
                compareFn: (a, b) => a.intLookupId == b.intLookupId,
                onChanged: (item) {
                  controller.selectedContent.value = item;
                },
              );
            }),

            const SizedBox(height: 35),

            // --------------------
            // Update Button
            // --------------------
            Obx(() {
              return SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorApp.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: controller.isSubmitting.value
                      ? null
                      : controller.updateRequest,
                  child: controller.isSubmitting.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "Update Request",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _inputField(
    String title,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            maxLines: maxLines,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget dropdownSearchField<T>({
    required String title,
    required T? value,
    required List<T> items,
    required String hint,
    required String Function(T) display,
    required Function(T?) onChanged,
    required bool Function(T, T) compareFn,
    bool isLoading = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: DropdownSearch<T>(
        enabled: !isLoading,
        selectedItem: value,
        compareFn: compareFn,
        itemAsString: (item) => display(item),
        items: (f, _) => items,
        onChanged: onChanged,

        popupProps:  PopupProps.dialog(
          showSearchBox: true,
          dialogProps: DialogProps(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        decoratorProps: DropDownDecoratorProps(
          decoration: InputDecoration(
            hintText: hint,
            labelText: title,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }
}
