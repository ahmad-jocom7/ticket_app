import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../utils/color_app.dart';
import '../../controller/add_ticket_controller.dart';
import '../../model/ticket/response_model.dart';
import '../../service/ticket_service.dart';

class AddTicketScreen extends StatelessWidget {
  AddTicketScreen({super.key});

  final controller = AddTicketController.to;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text(
          'Add Ticket',
        ),
        actions: [
          TextButton(
            onPressed: controller.clearAll,
            child: const Text("CLEAR", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: Color(0xFFE3F2FD),
                        child: Icon(
                          Icons.receipt_long,
                          color: ColorApp.primary,
                          size: 28,
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Ticket No. ( * )',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 30, thickness: 1),

                  // Ticket Type
                  Obx(
                    () => DropdownFieldWidget(
                      label: 'Ticket Type',
                      icon: Icons.confirmation_number_outlined,
                      value:
                          controller.selectedTicketType?.value.isEmpty == true
                          ? null
                          : controller.selectedTicketType?.value,
                      items: controller.ticketTypes,
                      onChanged: controller.onTicketTypeSelected,
                    ),
                  ),

                  // Customer
                  Obx(
                    () => DropdownFieldCustomerWidget(
                      label: 'Customer Name',
                      icon: Icons.person_outline,
                      value: controller.customers.firstWhereOrNull(
                        (e) =>
                            e.strLookupText ==
                            controller.selectedCustomer?.value,
                      ),
                      onChanged: (p0) {
                        controller.onCustomerSelected(p0);
                      },
                    ),
                  ),

                  // Caller Name
                  InputFieldWidget(
                    label: 'Caller Name',
                    icon: Icons.phone_outlined,
                    controller: controller.callerName,
                  ),

                  InputFieldWidget(
                    readOnly: true,
                    label: 'Received By',
                    icon: Icons.mail_outline,
                    controller: controller.receivedBy,
                  ),
                  Obx(
                    () => DropdownFieldWidget(
                      label: 'Device Ref. No.',
                      icon: Icons.devices_outlined,
                      value: controller.selectedDeviceRef?.value.isEmpty == true
                          ? null
                          : controller.selectedDeviceRef?.value,
                      items: controller.deviceRefs
                          .map((e) => e.strLookupText)
                          .toList(),
                      onChanged: controller.onDeviceRefSelected,
                    ),
                  ),
                  Obx(
                        () => DropdownFieldWidget(
                      readOnly: controller.lockFieldSerialNo.value,
                      label: 'S/N',
                      icon: Icons.numbers_outlined,
                      value: controller.selectedSerial?.value.isEmpty == true
                          ? null
                          : controller.selectedSerial?.value,
                      items: controller.serials
                          .map((e) => e.strLookupText)
                          .toList(),
                      onChanged: controller.onSerialSelected,
                    ),
                  ),
                  Obx(
                    () => DropdownFieldWidget(
                      label: 'Sub Product Name',
                      icon: Icons.widgets_outlined,
                      value:
                          controller.selectedSubProduct?.value.isEmpty == true
                          ? null
                          : controller.selectedSubProduct?.value,
                      items: controller.subProducts
                          .map((e) => e.strLookupText)
                          .toList(),
                      onChanged: controller.onSubProductSelected,
                      readOnly: controller.lockFieldsAfterSerialSelection.value,
                    ),
                  ),


                  const SizedBox(height: 10),

                  LocationSectionWidget(),
                  const SizedBox(height: 10),

                  // Serial

                  Obx(() {
                    return DropdownFieldWidget2(
                      key: ValueKey(controller.faults.length),
                      label: 'Fault',
                      icon: Icons.error_outline,
                      value:
                          controller.selectedFault?.value == null ||
                              controller.selectedFault?.value == 0
                          ? null
                          : controller.faults.firstWhereOrNull(
                              (e) =>
                                  e.intLookupId ==
                                  controller.selectedFault!.value,
                            ),
                      items: controller.faults,
                      onChanged: (selected) {
                        controller.onFaultSelected(selected?.intLookupId);
                      },
                    );
                  }),

                  InputFieldWidget(
                    label: 'Fault Note',
                    icon: Icons.sticky_note_2_outlined,
                    controller: controller.faultNote,
                  ),
                  InputFieldWidget(
                    label: 'Note',
                    icon: Icons.note_alt_outlined,
                    controller: controller.note,
                  ),

                  const SizedBox(height: 25),
                  SubmitButtonWidget(controller: controller),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

class DropdownFieldCustomerWidget extends StatelessWidget {
  final String label;
  final IconData icon;
  final LookupDatum? value;
  final Function(LookupDatum?) onChanged;

  const DropdownFieldCustomerWidget({
    super.key,
    required this.label,
    required this.icon,
    this.value,
    required this.onChanged,
  });

  final defaultPageSize = 20;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownSearch<LookupDatum>(
        items: (String? filter, LoadProps? loadProps) async {
          final skip = loadProps?.skip ?? 0; // how many items already loaded
          final take =
              loadProps?.take ?? defaultPageSize; // requested page size
          final pageNumber =
              (skip ~/ take) + 1; // convert skip/take -> pageNumber

          final res = await TicketService.getCustomers(
            searchText: filter ?? "",
            pageNumber: pageNumber,
            pageSize: take,
          );

          return res.lookupData;
        },
        compareFn: (a, b) => a.intLookupId == b.intLookupId,

        itemAsString: (LookupDatum? item) => item?.strLookupText ?? '',
        selectedItem: value != null
            ? LookupDatum(
                intLookupId: value!.strLookupId,
                strLookupId: value!.strLookupId,
                strLookupText: value!.strLookupText,
              )
            : null,
        onChanged: (LookupDatum? selected) {
          onChanged(selected);
        },

        popupProps: PopupProps.dialog(
          fit: FlexFit.loose,
          showSearchBox: true,
          disableFilter: true,
          dialogProps: DialogProps(
            backgroundColor: Colors.white, // 🎨 لون خلفية الـ dialog
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 3,
          ),

          infiniteScrollProps: InfiniteScrollProps(
            loadingMoreBuilder: (context, count) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              );
            },
          ),

          searchFieldProps: TextFieldProps(
            decoration: InputDecoration(
              hintText: 'Search $label...',
              prefixIcon: const Icon(Icons.search),
              contentPadding: const EdgeInsets.symmetric(horizontal: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          title: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),

        decoratorProps: DropDownDecoratorProps(
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon, color: ColorApp.primary),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFBBDEFB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFBBDEFB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: ColorApp.primary, width: 1.5),
            ),
          ),
        ),

        dropdownBuilder: (context, selectedItem) => Text(
          selectedItem?.strLookupText ?? '',
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}

class LocationSectionWidget extends StatelessWidget {
  LocationSectionWidget({super.key});

  final controller = AddTicketController.to;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: ColorApp.primary.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Sub Product Location",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1565C0),
              ),
            ),
            const SizedBox(height: 15),
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 600;

                return Obx(
                  () => Wrap(
                    spacing: 12,
                    runSpacing: 0,
                    children: [
                      // 🔹 Area Dropdown
                      SizedBox(
                        width: isWide
                            ? (constraints.maxWidth - 24) / 3
                            : constraints.maxWidth,
                        child: DropdownFieldWidget(
                          label: "Area",
                          icon: Icons.map_outlined,
                          value: controller.selectedArea?.value.isEmpty == true
                              ? null
                              : controller.selectedArea?.value,
                          items: controller.areas
                              .map((e) => e.strLookupText)
                              .toList(),
                          onChanged: controller.onAreaSelected,
                          readOnly:
                              controller.lockFieldsAfterSerialSelection.value,
                        ),
                      ),

                      // 🔹 Sub Area Dropdown
                      SizedBox(
                        width: isWide
                            ? (constraints.maxWidth - 24) / 3
                            : constraints.maxWidth,
                        child: DropdownFieldWidget(
                          label: "Sub Area",
                          icon: Icons.location_city_outlined,
                          value:
                              controller.selectedSubArea?.value.isEmpty == true
                              ? null
                              : controller.selectedSubArea?.value,
                          items: controller.subAreas
                              .map((e) => e.strLookupText)
                              .toList(),
                          onChanged: (p0) {
                            controller.onSubAreaSelected(p0);
                          },
                          readOnly:
                              controller.lockFieldsAfterSerialSelection.value,
                        ),
                      ),

                      // 🔹 Zone Dropdown
                      SizedBox(
                        width: isWide
                            ? (constraints.maxWidth - 24) / 3
                            : constraints.maxWidth,
                        child: DropdownFieldWidget(
                          readOnly: true,
                          label: "Zone",
                          icon: Icons.place_outlined,
                          value:
                              controller.zone.value?.intZoneId
                                      .toString()
                                      .isEmpty ==
                                  true
                              ? null
                              : controller.zone.value?.intZoneId.toString(),
                          items: controller.zone.value != null
                              ? [controller.zone.value!.intZoneId.toString()]
                              : [],
                          onChanged: controller.onZoneSelected,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class SubmitButtonWidget extends StatelessWidget {
  final AddTicketController controller;

  const SubmitButtonWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => SizedBox(
        width: double.infinity,
        height: 55,
        child: ElevatedButton.icon(
          onPressed: controller.isLoadingSubmit.value
              ? null
              : () async {
                  await controller.insertTicket();
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: ColorApp.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
          icon: controller.isLoadingSubmit.value
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.add_circle_outline, color: Colors.white),
          label: Text(
            controller.isLoadingSubmit.value ? 'Saving...' : 'Add Ticket',
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class DropdownFieldWidget extends StatelessWidget {
  final String label;
  final IconData icon;
  final String? value;
  final List<String> items;
  final Function(String?) onChanged;
  final bool readOnly;

  const DropdownFieldWidget({
    super.key,
    required this.label,
    required this.icon,
    this.value,
    required this.items,
    required this.onChanged,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownSearch<String>(
        items: (String? filter, _) {
          return items
              .where(
                (item) =>
                    filter == null ||
                    item.toLowerCase().contains(filter.toLowerCase()),
              )
              .toList();
        },
        itemAsString: (String? item) => item ?? '',
        selectedItem: value,
        onChanged: readOnly ? null : onChanged,
        enabled: items.isNotEmpty && !readOnly,

        popupProps: PopupProps.dialog(
          fit: FlexFit.loose,
          showSearchBox: true,
          dialogProps: DialogProps(
            backgroundColor: Colors.white, // 🎨 لون خلفية الـ dialog
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 3,
          ),
          searchFieldProps: TextFieldProps(
            decoration: InputDecoration(
              hintText: 'Search $label...',
              prefixIcon: const Icon(Icons.search),
              contentPadding: const EdgeInsets.symmetric(horizontal: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          title: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
        decoratorProps: DropDownDecoratorProps(
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon, color: ColorApp.primary),
            filled: true,
            fillColor: Colors.grey[50],
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFBBDEFB)),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFBBDEFB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFBBDEFB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: ColorApp.primary, width: 1.5),
            ),
          ),
        ),
        dropdownBuilder: (context, selectedItem) {
          return Text(
            selectedItem ?? '',
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 16),
          );
        },
      ),
    );
  }
}

class DropdownFieldWidget2 extends StatelessWidget {
  final String label;
  final IconData icon;
  final LookupDatum? value;
  final List<LookupDatum> items;
  final Function(LookupDatum?) onChanged;
  final bool readOnly;

  const DropdownFieldWidget2({
    super.key,
    required this.label,
    required this.icon,
    this.value,
    required this.items,
    required this.onChanged,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownSearch<LookupDatum>(
        items: (String? filter, _) {
          return items
              .where(
                (item) =>
                    filter == null ||
                    item.strLookupText.toLowerCase().contains(
                      filter.toLowerCase(),
                    ),
              )
              .toList();
        },

        compareFn: (a, b) => a.intLookupId == b.intLookupId,
        // ✅ مهم جدًا
        itemAsString: (LookupDatum? item) => item?.strLookupText ?? '',

        // ✅
        selectedItem: value,

        onChanged: readOnly ? null : onChanged,
        enabled: items.isNotEmpty && !readOnly,

        popupProps: PopupProps.dialog(
          fit: FlexFit.loose,
          showSearchBox: true,
          dialogProps: DialogProps(
            backgroundColor: Colors.white, // 🎨 لون خلفية الـ dialog
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 3,
          ),
          searchFieldProps: TextFieldProps(
            decoration: InputDecoration(
              hintText: 'Search $label...',
              prefixIcon: const Icon(Icons.search),
              contentPadding: const EdgeInsets.symmetric(horizontal: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          title: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),

        decoratorProps: DropDownDecoratorProps(
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon, color: ColorApp.primary),
            filled: true,
            fillColor: Colors.grey[50],
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFBBDEFB)),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFBBDEFB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFBBDEFB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: ColorApp.primary, width: 1.5),
            ),
          ),
        ),

        dropdownBuilder: (context, selectedItem) {
          return Text(
            selectedItem?.strLookupText ?? '', // ✅ عرض النص فقط
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 16),
          );
        },
      ),
    );
  }
}

class InputFieldWidget extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool readOnly;
  final TextEditingController controller;

  const InputFieldWidget({
    super.key,
    required this.label,
    required this.icon,
    this.readOnly = false,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        readOnly: readOnly,
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: ColorApp.primary),
          filled: true,
          fillColor: Colors.grey[50],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFBBDEFB)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFBBDEFB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: ColorApp.primary, width: 1.5),
          ),
        ),
      ),
    );
  }
}
