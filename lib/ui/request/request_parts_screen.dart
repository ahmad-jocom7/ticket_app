import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/request_parts_controller.dart';
import '../../model/ticket/response_model.dart';
import '../../utils/color_app.dart';

class RequestPartsScreen extends StatelessWidget {
  RequestPartsScreen({super.key});

  final controller = RequestPartsController.to;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Request Parts")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _inputField(
              title: "Part Number",
              controller: controller.partNumber,
              hint: "Enter part number",
            ),
            _inputField(
              title: "Description",
              controller: controller.description,
              hint: "Enter description",
              maxLines: 3,
            ),
            _inputField(
              title: "Customer Name",
              controller: controller.customerName,
              hint: "Enter customer name",
            ),
            _inputField(
              title: "Branch",
              controller: controller.branch,
              hint: "Enter branch",
            ),
            const SizedBox(height: 10),

            Obx(() {
              return dropdownSearchField<LookupDatum>(
                title: "Sub Product",
                value: controller.selectedSubProduct.value,
                items: controller.subProducts,
                hint: "Select Sub Product",
                display: (item) => item.strLookupText,
                compareFn: (a, b) => a.intLookupId == b.intLookupId,
                onChanged: (item) {
                  controller.selectedSubProduct.value = item;
                  if (item != null) {
                    controller.loadContents(item.intLookupId);
                  }
                },

                isLoading: controller.isLoadingSubProducts.value,
              );
            }),
            Obx(() {
              return dropdownSearchField<LookupDatum>(
                title: "Content",
                value: controller.selectedContent.value,
                items: controller.contents,
                hint: "Select content",
                display: (item) => item.strLookupText,
                compareFn: (a, b) => a.intLookupId == b.intLookupId,
                onChanged: (item) {
                  controller.selectedContent.value = item;
                },
                isLoading: controller.isLoadingContents.value,
              );
            }),

            Obx(() {
              return dropdownSearchField<LookupDatum>(
                title: "From",
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

            const SizedBox(height: 35),
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
                      : controller.submitRequest,
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
                          "Submit Request",
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

  Widget _inputField({
    required String title,
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: TextField(
              controller: controller,
              maxLines: maxLines,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(color: Colors.black45),
                contentPadding: const EdgeInsets.all(14),
                border: InputBorder.none,
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
    required String Function(T item) display,
    required Function(T?) onChanged,
    bool Function(T, T)? compareFn,
    bool isLoading = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),

            child: DropdownSearch<T>(
              enabled: !isLoading,
              suffixProps: DropdownSuffixProps(
                dropdownButtonProps: DropdownButtonProps(
                  iconClosed: isLoading
                      ? SizedBox(
                          height: 28,
                          width: 28,
                          child: const CircularProgressIndicator(),
                        )
                      : const Icon(Icons.arrow_drop_down),
                ),
              ),
              selectedItem: value,
              compareFn: compareFn ?? (a, b) => a == b,

              items: (String? filter, _) {
                return items.where((item) {
                  final text = display(item).toLowerCase();
                  return filter == null || text.contains(filter.toLowerCase());
                }).toList();
              },
              itemAsString: (item) => display(item),
              popupProps: PopupProps.dialog(
                showSearchBox: true,
                dialogProps: DialogProps(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                searchFieldProps: TextFieldProps(
                  decoration: InputDecoration(
                    hintText: "Search $title...",
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              decoratorProps: DropDownDecoratorProps(
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: const TextStyle(color: Colors.black45),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 16,
                  ),
                  border: InputBorder.none,
                ),
              ),

              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
