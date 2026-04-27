import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ticket_app/utils/validation.dart';

import '../../utils/color_app.dart';
import '../../controller/add_ticket_controller.dart';
import '../../model/ticket/response_model.dart';
import '../../service/ticket_service.dart';

class AddTicketScreen extends StatelessWidget {
  AddTicketScreen({super.key});

  final controller = AddTicketController.to;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Ticket'),
        actions: [
          Obx(
            () => TextButton(
              onPressed: controller.isScreenReady ? controller.clearAll : null,
              child: Text(
                "CLEAR",
                style: TextStyle(
                  color: controller.isScreenReady
                      ? Colors.white
                      : Colors.white70,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const _InitialLoadingView();
        }

        if (!controller.isScreenReady) {
          return _InitialErrorView(controller: controller);
        }

        return Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: controller.formKey,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: isDark
                        ? []
                        : [
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
                        backgroundColor: ColorApp.primary.withValues(
                          alpha: Theme.of(context).brightness == Brightness.dark
                              ? 0.18
                              : 0.1,
                        ),
                        child: Icon(
                          Icons.receipt_long,
                          color: ColorApp.primary,
                          size: 28,
                        ),
                      ),

                      SizedBox(width: 10),
                      Text(
                        'Ticket No. ( * )',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
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
                      required: true,
                    ),
                  ),

                  Obx(
                    () => DropdownFieldCustomerWidget(
                      label: 'Customer Name',
                      icon: Icons.person_outline,
                      value: controller.customers.firstWhereOrNull(
                        (e) =>
                            e.strLookupText ==
                            controller.selectedCustomer!.value,
                      ),
                      onChanged: controller.onCustomerSelected,
                      enabled:
                          !controller.isLoadingCustomerDependencies.value &&
                          !controller.isResolvingDeviceData.value,
                    ),
                  ),

                  InputFieldWidget(
                    required: true,
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
                  LocationSectionWidget(),
                  const SizedBox(height: 10),
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
                      readOnly: controller.shouldLockDependentFields,
                    ),
                  ),
                  Obx(
                    () => Row(
                      children: [
                        Expanded(
                          child: DropdownFieldWidget(
                            required: true,
                            readOnly:
                                controller.lockFieldSerialNo.value ||
                                controller.shouldLockDependentFields,
                            label: 'S/N',
                            icon: Icons.numbers_outlined,
                            value:
                                controller.selectedSerial?.value.isEmpty == true
                                ? null
                                : controller.selectedSerial?.value,
                            items: controller.serials
                                .map((e) => e.strLookupText)
                                .toList(),
                            onChanged: controller.onSerialSelected,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Obx(
                    () => DropdownFieldWidget(
                      required: true,
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
                      readOnly:
                          controller.lockFieldsAfterSerialSelection.value ||
                          controller.shouldLockDependentFields,
                    ),
                  ),

                  const SizedBox(height: 10),
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
                      readOnly: controller.isResolvingDeviceData.value,
                    );
                  }),

                  InputFieldWidget(
                    required: true,
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
            ),
            Obx(() {
              if (!controller.isLoadingCustomerDependencies.value &&
                  !controller.isResolvingDeviceData.value) {
                return const SizedBox.shrink();
              }

              return _FormLoadingOverlay(
                message: controller.isResolvingDeviceData.value
                    ? 'Loading device details...'
                    : 'Loading customer data...',
              );
            }),
          ],
        );
      }),
    );
  }
}

class DropdownFieldCustomerWidget extends StatelessWidget {
  final String label;
  final IconData icon;
  final LookupDatum? value;
  final Future<void> Function(LookupDatum?) onChanged;
  final bool enabled;

  DropdownFieldCustomerWidget({
    super.key,
    required this.label,
    required this.icon,
    this.value,
    required this.onChanged,
    this.enabled = true,
  });

  final defaultPageSize = 20;
  final controller = AddTicketController.to;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownSearch<LookupDatum>(
        validator: (value) => Validation.isRequired(value?.strLookupText),
        key: controller.dropdownKey,
        enabled: enabled,
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
                intLookupId: value!.intLookupId,
                strLookupId: value!.strLookupId,
                strLookupText: value!.strLookupText,
              )
            : null,
        onChanged: enabled
            ? (LookupDatum? selected) async {
                await onChanged(selected);
              }
            : null,

        popupProps: PopupProps.dialog(
          fit: FlexFit.loose,
          showSearchBox: true,
          disableFilter: true,
          dialogProps: DialogProps(
            backgroundColor: Theme.of(context).dialogTheme.backgroundColor,

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
            hintText: enabled ? null : 'Please wait...',
            prefixIcon: Icon(icon, color: ColorApp.primary),
            filled: true,
            fillColor: isDark ? theme.colorScheme.surface : Colors.grey.shade50,

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFBBDEFB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFBBDEFB)),
            ),
            disabledBorder: OutlineInputBorder(
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.2),
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
                          required: true,
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
                              controller.lockFieldsAfterSerialSelection.value ||
                              controller.shouldLockDependentFields,
                          hintText: controller.hasCustomerSelected
                              ? null
                              : 'Select customer first',
                        ),
                      ),

                      // 🔹 Sub Area Dropdown
                      SizedBox(
                        width: isWide
                            ? (constraints.maxWidth - 24) / 3
                            : constraints.maxWidth,
                        child: DropdownFieldWidget(
                          required: true,
                          label: "Sub Area",
                          icon: Icons.location_city_outlined,
                          value:
                              controller.selectedSubArea?.value.isEmpty == true
                              ? null
                              : controller.selectedSubArea?.value,
                          items: controller.subAreas
                              .map((e) => e.strLookupText)
                              .toList(),
                          onChanged: controller.onSubAreaSelected,
                          readOnly:
                              controller.lockFieldsAfterSerialSelection.value ||
                              controller.shouldLockDependentFields,
                          hintText: controller.hasCustomerSelected
                              ? null
                              : 'Select customer first',
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
                          hintText: controller.hasCustomerSelected
                              ? 'Auto-filled'
                              : 'Select customer first',
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
          onPressed: controller.isLoadingSubmit.value ||
                  controller.isLoadingCustomerDependencies.value ||
                  controller.isResolvingDeviceData.value
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
  final bool required;
  final String? hintText;

  const DropdownFieldWidget({
    super.key,
    required this.label,
    required this.icon,
    this.value,
    required this.items,
    required this.onChanged,
    this.readOnly = false,
    this.required = false,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownSearch<String>(
        validator: required == false
            ? null
            : (value) => Validation.isRequired(value),
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
            backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
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
            hintText: hintText,
            prefixIcon: Icon(icon, color: ColorApp.primary),
            filled: true,
            fillColor: isDark ? theme.colorScheme.surface : Colors.grey.shade50,

            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red.shade900),
            ),
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
  final String? hintText;

  const DropdownFieldWidget2({
    super.key,
    required this.label,
    required this.icon,
    this.value,
    required this.items,
    required this.onChanged,
    this.readOnly = false,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
        itemAsString: (LookupDatum? item) => item?.strLookupText ?? '',
        selectedItem: value,
        onChanged: readOnly ? null : onChanged,
        enabled: items.isNotEmpty && !readOnly,

        popupProps: PopupProps.dialog(
          fit: FlexFit.loose,
          showSearchBox: true,
          dialogProps: DialogProps(
            backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
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
            hintText: hintText,
            prefixIcon: Icon(icon, color: ColorApp.primary),
            filled: true,
            fillColor: isDark ? theme.colorScheme.surface : Colors.grey.shade50,
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
  final bool required;
  final TextEditingController controller;

  const InputFieldWidget({
    super.key,
    required this.label,
    required this.icon,
    this.readOnly = false,
    this.required = false,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        validator: required == false
            ? null
            : (value) => Validation.isRequired(value),

        onTapOutside: (_) {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        readOnly: readOnly,
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: ColorApp.primary),
          filled: true,
          fillColor: isDark ? theme.colorScheme.surface : Colors.grey.shade50,

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

class _InitialLoadingView extends StatelessWidget {
  const _InitialLoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Preparing the add ticket screen...'),
        ],
      ),
    );
  }
}

class _InitialErrorView extends StatelessWidget {
  final AddTicketController controller;

  const _InitialErrorView({required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.cloud_off_rounded,
                  size: 52,
                  color: Colors.orange.shade700,
                ),
                const SizedBox(height: 16),
                Text(
                  'Screen data could not be loaded',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  controller.initializationError.value.isEmpty
                      ? 'Please try again.'
                      : controller.initializationError.value,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(ColorApp.primary)
                  ),
                  onPressed: controller.retryInitialLoad,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FormLoadingOverlay extends StatelessWidget {
  final String message;

  const _FormLoadingOverlay({required this.message});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: AbsorbPointer(
        child: Container(
          color: Colors.black.withValues(alpha: 0.08),
          alignment: Alignment.center,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 14),
                Text(message),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CustomerDependencyHint extends StatelessWidget {
  final AddTicketController controller;

  const _CustomerDependencyHint({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final hint = !controller.hasCustomerSelected
          ? 'Choose a customer first to load area, device reference, serial, and sub product data.'
          : controller.isLoadingCustomerDependencies.value
          ? 'Loading customer-related fields...'
          : null;

      if (hint == null) {
        return const SizedBox(height: 8);
      }

      return Padding(
        padding: const EdgeInsets.only(top: 4, bottom: 8),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: ColorApp.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: ColorApp.primary.withValues(alpha: 0.2)),
          ),
          child: Text(
            hint,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      );
    });
  }
}


class _SectionStatusCard extends StatelessWidget {
  final String title;
  final String message;
  final bool isLoading;
  final bool isActive;

  const _SectionStatusCard({
    required this.title,
    required this.message,
    required this.isLoading,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = isLoading
        ? Colors.orange
        : isActive
        ? Colors.green
        : ColorApp.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: baseColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: baseColor.withValues(alpha: 0.2)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: isLoading
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: baseColor,
                      ),
                    )
                  : Icon(
                      isActive
                          ? Icons.check_circle_outline
                          : Icons.info_outline,
                      size: 18,
                      color: baseColor,
                    ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    message,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
