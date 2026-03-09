import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/add_serial_number.dart';

class AddSerialDialog extends StatelessWidget {
  final String customerId;

  AddSerialDialog({super.key, required this.customerId});

  final controller = Get.put(AddSerialFromTicketController());

  @override
  Widget build(BuildContext context) {
    controller.init(customerId);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(20),
        child: Obx(() {
          if (controller.isLoading.value) {
            return const SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            );
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Title
              const Text(
                "Add New Sub Product File",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              /// Product Category
              const Text("Product Category *"),

              const SizedBox(height: 6),

              Obx(
                () => DropdownButtonFormField<int>(
                  value: controller.selectedCategoryId.value,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Please Select..",
                  ),
                  items: controller.productCategories
                      .map(
                        (e) => DropdownMenuItem(
                          value: e.intLookupId,
                          child: Text(e.strLookupText ?? ""),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      controller.onCategorySelected(value);
                    }
                  },
                ),
              ),

              const SizedBox(height: 15),

              /// Sub Product
              const Text("Sub Product *"),

              const SizedBox(height: 6),

              Obx(
                () => DropdownButtonFormField<int>(
                  value: controller.selectedSubProductId.value,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "No Items",
                  ),
                  items: controller.subProducts
                      .map(
                        (e) => DropdownMenuItem(
                          value: e.intLookupId,
                          child: Text(e.strLookupText ?? ""),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      controller.onSubProductSelected(value);
                    }
                  },
                ),
              ),

              const SizedBox(height: 15),

              /// Serial Number
              const Text("S/N *"),

              const SizedBox(height: 6),

              TextField(
                controller: controller.serialController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "S/N",
                ),
              ),

              const SizedBox(height: 15),

              /// Note
              const Text("Note"),

              const SizedBox(height: 6),

              TextField(
                controller: controller.noteController,
                maxLines: 2,
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),

              const SizedBox(height: 25),

              /// Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Get.back();
                    },
                    child: const Text("Close"),
                  ),

                  const SizedBox(width: 10),

                  ElevatedButton(
                    onPressed: () {
                      controller.submit();
                    },
                    child: const Text("Add"),
                  ),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }
}
