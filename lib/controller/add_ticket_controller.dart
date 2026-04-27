import 'dart:developer';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ticket_app/model/ticket/response_model.dart';
import 'package:ticket_app/service/ticket_service.dart';
import 'package:ticket_app/utils/my_shared_preferences.dart';

import '../model/ticket/zone_model.dart';
import '../ui/dashboard/screens/new_ticket_screen.dart';

class AddTicketController extends GetxController {
  static AddTicketController get to => Get.isRegistered<AddTicketController>()
      ? Get.find<AddTicketController>()
      : Get.put(AddTicketController());

  final TextEditingController callerName = TextEditingController();
  final TextEditingController receivedBy = TextEditingController(
    text: mySharedPreferences.getUserData()!.email,
  );
  final TextEditingController faultNote = TextEditingController();
  final TextEditingController note = TextEditingController();
  final formKey = GlobalKey<FormState>();

  RxString? selectedTicketType = RxString('');
  RxString? selectedCustomer = RxString('');
  RxString? selectedSubProduct = RxString('');
  RxString? selectedDeviceRef = RxString('');
  RxString? selectedSerial = RxString('');
  RxInt? selectedFault = RxInt(0);
  RxString? selectedArea = RxString('');
  RxString? selectedSubArea = RxString('');
  RxString? selectedZone = RxString('');
  final RxBool lockFieldsAfterSerialSelection = false.obs;
  final RxBool lockFieldSerialNo = false.obs;

  RxList<LookupDatum> areas = <LookupDatum>[].obs;
  RxList<LookupDatum> subAreas = <LookupDatum>[].obs;
  Rxn<ZoneModel> zone = Rxn<ZoneModel>();
  RxList<String> ticketTypes = <String>[].obs;
  RxList<LookupDatum> customers = <LookupDatum>[].obs;
  RxList<LookupDatum> subProducts = <LookupDatum>[].obs;
  RxList<LookupDatum> deviceRefs = <LookupDatum>[].obs;
  RxList<LookupDatum> serials = <LookupDatum>[].obs;
  RxList<LookupDatum> faults = <LookupDatum>[].obs;

  final dropdownKey = GlobalKey<DropdownSearchState<LookupDatum>>();

  RxBool isLoading = false.obs;
  RxBool isLoadingSubmit = false.obs;
  RxBool isLoadingCustomerDependencies = false.obs;
  RxBool isResolvingDeviceData = false.obs;
  RxBool hasInitialDataLoaded = false.obs;
  RxString initializationError = ''.obs;

  int customerId = 0;
  int areaId = 0;
  int subAreaId = 0;
  int subProductFileId = 0;
  int _customerLoadRequestId = 0;
  int _serialLookupRequestId = 0;
  int _deviceRefLookupRequestId = 0;
  int _areaSelectionRequestId = 0;
  int _subAreaSelectionRequestId = 0;

  @override
  void onInit() {
    super.onInit();
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    isLoading.value = true;
    hasInitialDataLoaded.value = false;
    initializationError.value = '';

    try {
      await getTicketTypes();

      if (ticketTypes.isEmpty) {
        initializationError.value =
            'Unable to load the required screen data. Please try again.';
        return;
      }

      hasInitialDataLoaded.value = true;
    } catch (e, stack) {
      log('Error loading initial add-ticket data: $e');
      log('$stack');
      initializationError.value =
          'Unable to load the required screen data. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> retryInitialLoad() async {
    await loadInitialData();
  }

  Future<void> getTicketTypes() async {
    final res = await TicketService.getSystemConfiguration();
    ticketTypes.assignAll(res.systemConfigList);
  }

  Future<void> getCustomers({
    String searchText = "",
    int pageNumber = 1,
    int pageSize = 20,
  }) async {
    final res = await TicketService.getCustomers(
      searchText: searchText,
      pageNumber: pageNumber,
      pageSize: pageSize,
    );

    if (pageNumber == 1) {
      customers.clear();
    }

    if (res.lookupData.isNotEmpty) {
      customers.addAll(res.lookupData);
    }
  }

  Future<void> getSubProducts(
    int customerId, {
    int area = 0,
    int subarea = 0,
  }) async {
    subProducts.clear();
    final res = await TicketService.getSubProduct(
      customerId,
      area: area,
      subArea: subarea,
    );
    if (res.lookupData.isNotEmpty) {
      subProducts.assignAll(res.lookupData);
    }
  }

  Future<void> getDeviceRefs(int customerId) async {
    deviceRefs.clear();
    final res = await TicketService.getDeviceRef(customerId);
    if (res.lookupData.isNotEmpty) {
      deviceRefs.assignAll(res.lookupData);
    }
  }

  Future<void> getSerials(int customerId) async {
    serials.clear();
    final res = await TicketService.getSerial(
      customerId,
      area: areaId,
      subArea: subAreaId,
    );
    if (res.lookupData.isNotEmpty) {
      serials.assignAll(res.lookupData);
    }
  }

  Future<void> getAreas(int customerId) async {
    areas.clear();
    final res = await TicketService.getArea(customerId);
    if (res.lookupData.isNotEmpty) {
      areas.assignAll(res.lookupData);
    }
  }

  Future<void> getSubAreas(int areaId) async {
    subAreas.clear();
    final res = await TicketService.getSubArea(areaId);
    if (res.lookupData.isNotEmpty) {
      subAreas.assignAll(res.lookupData);
    }
  }

  Future<void> getZones(int areaId) async {
    zone.value = null;
    try {
      final res = await TicketService.getZone(areaId);
      if (res.intZoneId != 0) {
        zone.value = res;
        log('Zone loaded: ${res.strAreaName}');
      }
    } catch (e, stack) {
      log('Error fetching zone: $e');
      log('$stack');
    }
  }

  Future<void> getFaults(int subProductFileId) async {
    faults.clear();
    try {
      final res = await TicketService.getFault(subProductFileId);
      if (res.lookupData.isNotEmpty) {
        faults.assignAll(res.lookupData);
      }
    } catch (e) {
      log('Error fetching faults: $e');
    }
  }

  Future<void> getSubProductFileBySerial(String serialNoId) async {
    final requestId = ++_serialLookupRequestId;
    isResolvingDeviceData.value = true;
    try {
      final res = await TicketService.getSubProductFileBySerialNo(serialNoId);
      if (requestId != _serialLookupRequestId) {
        return;
      }

      if (res.intSubProductId != 0) {
        subProductFileId = res.intSubProductIdFile;
        final subProduct = subProducts.firstWhereOrNull(
          (e) => e.intLookupId == res.intSubProductId,
        );
        await getFaults(subProductFileId);
        if (requestId != _serialLookupRequestId) {
          return;
        }

        if (subProduct != null) {
          selectedSubProduct?.value = subProduct.strLookupText;
        }

        final area = areas.firstWhereOrNull(
          (e) => e.intLookupId == res.intAreaId,
        );
        if (area != null) {
          selectedArea?.value = area.strLookupText;
          areaId = area.intLookupId;

          await getSubAreas(res.intAreaId);
          if (requestId != _serialLookupRequestId) {
            return;
          }
          await getZones(res.intAreaId);
          if (requestId != _serialLookupRequestId) {
            return;
          }
        }

        final subArea = subAreas.firstWhereOrNull(
          (e) => e.intLookupId == res.intSubAreaId,
        );
        if (subArea != null) {
          selectedSubArea?.value = subArea.strLookupText;
          subAreaId = subArea.intLookupId;
        }

        lockFieldsAfterSerialSelection.value = true;

        log(
          'Loaded from serial: '
          'subProduct=${selectedSubProduct?.value}, '
          'subProductFile=${res.intSubProductIdFile}, '
          'area=${selectedArea?.value}, '
          'subArea=${selectedSubArea?.value}',
        );
      }
    } catch (e) {
      log('Error fetching sub-product file by serial: $e');
      _showErrorSnackbar(
        'Unable to load the serial details right now. Please try again.',
      );
    } finally {
      if (requestId == _serialLookupRequestId) {
        isResolvingDeviceData.value = false;
      }
    }
  }

  Future<void> getSubProductFileByDeviceRef(String deviceRefId) async {
    final requestId = ++_deviceRefLookupRequestId;
    isResolvingDeviceData.value = true;
    try {
      final res = await TicketService.getSubProductFileByCustomerRefNo(
        customerId,
        deviceRefId,
      );
      if (requestId != _deviceRefLookupRequestId) {
        return;
      }

      if (res.intSubProductId != 0) {
        subProductFileId = res.intSubproductFileId;
        final subProduct = subProducts.firstWhereOrNull(
          (e) => e.intLookupId == res.intSubProductId,
        );
        await getFaults(subProductFileId);
        if (requestId != _deviceRefLookupRequestId) {
          return;
        }

        if (subProduct != null) {
          selectedSubProduct?.value = subProduct.strLookupText;
        }

        final serialNo = serials.firstWhereOrNull(
          (e) =>
              e.strLookupId == res.strSerialNumber ||
              e.strLookupText == res.strSerialNumber,
        );
        if (serialNo != null) {
          selectedSerial!.value = serialNo.strLookupText;
        }

        final area = areas.firstWhereOrNull(
          (e) => e.intLookupId == res.intAreaId,
        );
        if (area != null) {
          selectedArea?.value = area.strLookupText;
          areaId = area.intLookupId;

          await getSubAreas(res.intAreaId);
          if (requestId != _deviceRefLookupRequestId) {
            return;
          }
          await getZones(res.intAreaId);
          if (requestId != _deviceRefLookupRequestId) {
            return;
          }
        }

        final subArea = subAreas.firstWhereOrNull(
          (e) => e.intLookupId == res.intSubAreaId,
        );
        if (subArea != null) {
          selectedSubArea?.value = subArea.strLookupText;
          subAreaId = subArea.intLookupId;
        }

        lockFieldsAfterSerialSelection.value = true;
        lockFieldSerialNo.value = true;
        log(
          'Loaded from device ref: '
          'subProduct=${selectedSubProduct?.value}, '
          'subProductFile=${res.intSubproductFileId}, '
          'area=${selectedArea?.value}, '
          'subArea=${selectedSubArea?.value}',
        );
      }
    } catch (e) {
      log('Error fetching sub-product file by device ref: $e');
      _showErrorSnackbar(
        'Unable to load the device reference details right now. Please try again.',
      );
    } finally {
      if (requestId == _deviceRefLookupRequestId) {
        isResolvingDeviceData.value = false;
      }
    }
  }

  void onTicketTypeSelected(String? value) {
    selectedTicketType?.value = value ?? '';
  }

  Future<void> onCustomerSelected(LookupDatum? customer) async {
    if (customer == null) {
      return;
    }

    final requestId = ++_customerLoadRequestId;
    selectedCustomer?.value = customer.strLookupText;
    customerId = customer.intLookupId;
    _resetDependentFields(clearCustomer: false);

    isLoadingCustomerDependencies.value = true;
    try {
      await Future.wait([
        getSubProducts(customerId),
        getDeviceRefs(customerId),
        getAreas(customerId),
        getSerials(customerId),
      ]);
      if (requestId != _customerLoadRequestId) {
        return;
      }
    } catch (e, stack) {
      log('Error loading customer dependencies: $e');
      log('$stack');
      _showErrorSnackbar(
        'Unable to load customer data right now. Please try selecting the customer again.',
      );
    } finally {
      if (requestId == _customerLoadRequestId) {
        isLoadingCustomerDependencies.value = false;
      }
    }
  }

  Future<void> onAreaSelected(String? value) async {
    selectedArea?.value = value ?? '';

    if (value == null || value.isEmpty) {
      return;
    }

    final area = areas.firstWhereOrNull((e) => e.strLookupText == value);
    if (area == null) {
      return;
    }

    final requestId = ++_areaSelectionRequestId;
    areaId = area.intLookupId;
    subAreaId = 0;
    subAreas.clear();
    zone.value = null;
    subProducts.clear();
    serials.clear();
    faults.clear();
    subProductFileId = 0;
    selectedSubArea?.value = '';
    selectedZone?.value = '';
    selectedSubProduct?.value = '';
    selectedSerial?.value = '';
    selectedDeviceRef?.value = '';
    selectedFault?.value = 0;
    lockFieldsAfterSerialSelection.value = false;
    lockFieldSerialNo.value = false;

    await getSubAreas(areaId);
    if (requestId != _areaSelectionRequestId) {
      return;
    }
    await getZones(areaId);
    if (requestId != _areaSelectionRequestId) {
      return;
    }
    await getSubProducts(customerId, area: areaId);
    if (requestId != _areaSelectionRequestId) {
      return;
    }
    await getSerials(customerId);
  }

  Future<void> onSubAreaSelected(String? value) async {
    selectedSubArea?.value = value ?? '';

    if (value == null || value.isEmpty) {
      return;
    }

    final subArea = subAreas.firstWhereOrNull(
      (e) => e.strLookupText == value,
    );

    if (subArea == null) {
      return;
    }

    final requestId = ++_subAreaSelectionRequestId;
    subAreaId = subArea.intLookupId;
    subProducts.clear();
    serials.clear();
    faults.clear();
    subProductFileId = 0;
    selectedSubProduct?.value = '';
    selectedSerial?.value = '';
    selectedDeviceRef?.value = '';
    selectedFault?.value = 0;
    lockFieldsAfterSerialSelection.value = false;
    lockFieldSerialNo.value = false;

    await getSubProducts(customerId, subarea: subAreaId);
    if (requestId != _subAreaSelectionRequestId) {
      return;
    }
    await getSerials(customerId);
  }

  void onZoneSelected(String? value) {
    selectedZone?.value = value ?? '';
  }

  void onSubProductSelected(String? value) {
    selectedSubProduct?.value = value ?? '';
    selectedFault?.value = 0;
    faults.clear();
  }

  void onDeviceRefSelected(String? value) {
    selectedDeviceRef?.value = value ?? '';
    selectedFault?.value = 0;
    faults.clear();
    subProductFileId = 0;

    if (selectedDeviceRef!.value.isNotEmpty) {
      getSubProductFileByDeviceRef(selectedDeviceRef!.value);
    }
  }

  Future<void> onSerialSelected(String? value) async {
    selectedSerial?.value = value ?? '';
    selectedFault?.value = 0;
    faults.clear();
    subProductFileId = 0;

    if (value == null || value.isEmpty) {
      return;
    }

    final serial = serials.firstWhereOrNull(
      (e) => e.strLookupId == value || e.strLookupText == value,
    );

    if (serial == null) {
      return;
    }

    final serialNo = serial.strLookupId ?? serial.strLookupText ?? '';
    if (serialNo.toString().isNotEmpty) {
      log('Fetching serial file for: $serialNo');
      await getSubProductFileBySerial(serialNo.toString());
    }
  }

  void onFaultSelected(int? value) {
    selectedFault?.value = value ?? 0;
  }

  Future<void> insertTicket() async {
    if (!hasInitialDataLoaded.value || isLoading.value) {
      _showErrorSnackbar(
        'The screen is still preparing required data. Please wait a moment.',
      );
      return;
    }

    if (isLoadingCustomerDependencies.value || isResolvingDeviceData.value) {
      _showErrorSnackbar(
        'Please wait until the related data finishes loading before saving.',
      );
      return;
    }

    try {
      isLoadingSubmit.value = true;
      final missingFields = <String>[];

      if (!formKey.currentState!.validate()) {
        if (callerName.text.isEmpty) missingFields.add('Caller Name');
        if (selectedTicketType?.value.isEmpty ?? true) {
          missingFields.add('Ticket Type');
        }
        if (customerId == 0 || selectedCustomer?.value.isEmpty == true) {
          missingFields.add('Customer');
        }
        if (selectedSubProduct?.value.isEmpty ?? true) {
          missingFields.add('Sub Product');
        }
        if (selectedSerial?.value.isEmpty ?? true) {
          missingFields.add('Serial No');
        }
        if (selectedArea?.value.isEmpty ?? true) missingFields.add('Area');
        if (selectedSubArea?.value.isEmpty ?? true) {
          missingFields.add('Sub Area');
        }
        if (faultNote.text.isEmpty) missingFields.add('Fault Note');
      }

      if (subProductFileId == 0) {
        missingFields.add('Valid device selection');
      }

      if (missingFields.isNotEmpty) {
        final fields = missingFields.join(', ');
        Get.snackbar(
          'Missing Required Fields',
          '$fields ${missingFields.length > 1 ? "are" : "is"} required.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange.shade100,
          colorText: Colors.black87,
          duration: const Duration(seconds: 4),
          icon: const Icon(Icons.warning_amber_rounded, color: Colors.orange),
          margin: const EdgeInsets.all(12),
          borderRadius: 12,
        );
        return;
      }

      final res = await TicketService.insertTicket(
        faultNote: faultNote.text.isNotEmpty ? faultNote.text : null,
        notes: note.text.isNotEmpty ? note.text : null,
        customerId: customerId,
        subProductFileId: subProductFileId,
        callerName: callerName.text,
        ticketType: selectedTicketType!.value,
        contentId: selectedFault?.value.toString(),
      );

      if (res.status == true) {
        log('Ticket created successfully: ID = ${res.ticketId}');
        await TicketService.assignTicket(ticketId: res.ticketId.toString());
        Get.off(() => AssignedTicketsScreen());

        Get.snackbar(
          'Success',
          'Ticket created successfully (ID: ${res.ticketId})',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green.shade100,
          colorText: Colors.black87,
          duration: const Duration(seconds: 4),
          icon: const Icon(Icons.check_circle, color: Colors.green),
          margin: const EdgeInsets.all(12),
          borderRadius: 12,
        );
        clearAll();
      } else {
        log('Failed to create ticket: ${res.message}');
        Get.snackbar(
          'Error',
          res.message.isNotEmpty ? res.message : 'Failed to insert ticket.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.black87,
          duration: const Duration(seconds: 4),
          icon: const Icon(Icons.error_outline, color: Colors.red),
          margin: const EdgeInsets.all(12),
          borderRadius: 12,
        );
      }
    } catch (e, stack) {
      log('Exception in insertTicket: $e');
      log('$stack');
      _showErrorSnackbar(
        'An unexpected error occurred while creating the ticket.',
      );
    } finally {
      isLoadingSubmit.value = false;
    }
  }

  @override
  void onClose() {
    callerName.dispose();
    receivedBy.dispose();
    faultNote.dispose();
    note.dispose();
    super.onClose();
  }

  void clearAll() {
    selectedTicketType?.value = '';
    isLoadingCustomerDependencies.value = false;
    isResolvingDeviceData.value = false;
    _customerLoadRequestId++;
    _serialLookupRequestId++;
    _deviceRefLookupRequestId++;
    _areaSelectionRequestId++;
    _subAreaSelectionRequestId++;
    _resetDependentFields();
    callerName.clear();
    note.clear();
    faultNote.clear();
    formKey.currentState?.reset();
    dropdownKey.currentState?.clear();
  }

  bool get isScreenReady => hasInitialDataLoaded.value && !isLoading.value;

  bool get hasCustomerSelected =>
      (selectedCustomer?.value.isNotEmpty ?? false) && customerId != 0;

  bool get shouldLockDependentFields =>
      !hasCustomerSelected ||
      isLoadingCustomerDependencies.value ||
      isResolvingDeviceData.value;

  void _resetDependentFields({bool clearCustomer = true}) {
    if (clearCustomer) {
      selectedCustomer?.value = '';
      customerId = 0;
    }

    selectedSubProduct?.value = '';
    selectedDeviceRef?.value = '';
    selectedSerial?.value = '';
    selectedFault?.value = 0;
    selectedArea?.value = '';
    selectedSubArea?.value = '';
    selectedZone?.value = '';

    lockFieldsAfterSerialSelection.value = false;
    lockFieldSerialNo.value = false;

    subProducts.clear();
    deviceRefs.clear();
    serials.clear();
    areas.clear();
    subAreas.clear();
    faults.clear();

    areaId = 0;
    subAreaId = 0;
    subProductFileId = 0;
    zone.value = null;
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red.shade100,
      colorText: Colors.black87,
      duration: const Duration(seconds: 4),
      icon: const Icon(Icons.error_outline, color: Colors.red),
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
    );
  }
}
