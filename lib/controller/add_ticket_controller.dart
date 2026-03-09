import 'dart:developer';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ticket_app/utils/my_shared_preferences.dart';
import 'package:ticket_app/model/ticket/response_model.dart';
import 'package:ticket_app/service/ticket_service.dart';

import '../model/ticket/zone_model.dart';
import '../ui/dashboard/screens/new_ticket_screen.dart';

class AddTicketController extends GetxController {
  // Singleton GetX controller
  static AddTicketController get to => Get.isRegistered<AddTicketController>()
      ? Get.find<AddTicketController>()
      : Get.put(AddTicketController());

  final TextEditingController callerName = TextEditingController();
  final TextEditingController receivedBy = TextEditingController(
    text: mySharedPreferences.getUserData()!.email,
  );
  final TextEditingController faultNote = TextEditingController();
  final TextEditingController note = TextEditingController();

  RxString? selectedTicketType = RxString('');
  RxString? selectedCustomer = RxString('');
  RxString? selectedSubProduct = RxString('');
  RxString? selectedDeviceRef = RxString('');
  RxString? selectedSerial = RxString('');
  // RxString? selectedFault = RxString('');
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

  int customerId = 0;
  int areaId = 0;
  int subAreaId = 0;
  int subProductFileId = 0;

  @override
  void onInit() {
    super.onInit();
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    isLoading.value = true;
    try {
      await Future.wait([getTicketTypes(), getCustomers()]);
    } finally {
      isLoading.value = false;
    }
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
    String storedProcedure = "ddl_subProductByCustomer",
  }) async {
    subProducts.clear();
    final res = await TicketService.getSubProduct(
      customerId,
      area: area,
      subArea: subarea,
      // storedProcedure: storedProcedure,
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
    zone.value = null; // تنظيف القيم السابقة
    try {
      final res = await TicketService.getZone(areaId);

      if (res.intZoneId != 0) {
        zone.value = res;
        log('✅ Zone loaded: ${res.strAreaName}');
      }
    } catch (e, stack) {
      log('❌ Error fetching zone: $e');
      log("$stack");
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
      log('❌ Error fetching faults: $e');
    }
  }

  Future<void> getSubProductFileBySerial(String serialNoId) async {
    try {
      final res = await TicketService.getSubProductFileBySerialNo(serialNoId);

      if (res.intSubProductId != 0) {
        subProductFileId = res.intSubProductIdFile;
        final subProduct = subProducts.firstWhereOrNull(
          (e) => e.intLookupId == res.intSubProductId,
        );
        await getFaults(subProductFileId);

        if (subProduct != null) {
          selectedSubProduct?.value = subProduct.strLookupText;
        }
        final area = areas.firstWhereOrNull(
          (e) => e.intLookupId == res.intAreaId,
        );
        if (area != null) {
          selectedArea?.value = area.strLookupText;

          await getSubAreas(res.intAreaId);
          await getZones(res.intAreaId);
        }

        final subArea = subAreas.firstWhereOrNull(
          (e) => e.intLookupId == res.intSubAreaId,
        );
        if (subArea != null) {
          selectedSubArea?.value = subArea.strLookupText;
        }

        lockFieldsAfterSerialSelection.value = true;

        log(
          '✅ Loaded from SerialNo: '
          'SubProduct=${selectedSubProduct?.value}, '
          'SubProductFile=${res.intSubProductIdFile}, '
          'Area=${selectedArea?.value}, '
          'SubArea=${selectedSubArea?.value}',
        );
      }
    } catch (e) {
      log('❌ Error fetching SubProductFile by SerialNo: $e');
    }
  }

  Future<void> getSubProductFileByDeviceRef(String deviceRefId) async {
    try {
      final res = await TicketService.getSubProductFileByCustomerRefNo(
        customerId,
        deviceRefId,
      );

      if (res.intSubProductId != 0) {
        subProductFileId = res.intSubproductFileId;
        final subProduct = subProducts.firstWhereOrNull(
          (e) => e.intLookupId == res.intSubProductId,
        );
        await getFaults(subProductFileId);

        if (subProduct != null) {
          selectedSubProduct?.value = subProduct.strLookupText;
        }
        final serialNo = serials.firstWhereOrNull(
          (e) => e.strLookupId == res.strSerialNumber,
        );

        if (serialNo != null) {
          selectedSerial!.value = subProduct!.intLookupId.toString();
        }

        final area = areas.firstWhereOrNull(
          (e) => e.intLookupId == res.intAreaId,
        );
        if (area != null) {
          selectedArea?.value = area.strLookupText;

          await getSubAreas(res.intAreaId);
          await getZones(res.intAreaId);
        }

        final subArea = subAreas.firstWhereOrNull(
          (e) => e.intLookupId == res.intSubAreaId,
        );
        if (subArea != null) {
          selectedSubArea?.value = subArea.strLookupText;
        }

        lockFieldsAfterSerialSelection.value = true;
        lockFieldSerialNo.value = true;
        log(
          '✅ Loaded from SerialNo: '
          'SubProduct=${selectedSubProduct?.value}, '
          'SubProductFile=${res.intSubproductFileId}, '
          'Area=${selectedArea?.value}, '
          'SubArea=${selectedSubArea?.value}',
        );
      }
    } catch (e) {
      log('❌ Error fetching SubProductFile by SerialNo: $e');
    }
  }

  void onTicketTypeSelected(String? value) {
    selectedTicketType?.value = value ?? '';
  }

  void onCustomerSelected(LookupDatum? customer) async {
    if (customer == null) return;

    selectedCustomer?.value = customer.strLookupText;
    customerId = customer.intLookupId;

    subProducts.clear();
    deviceRefs.clear();
    serials.clear();
    areas.clear();
    subAreas.clear();
    zone.value = null;
    selectedSubProduct?.value = '';
    selectedDeviceRef?.value = '';
    selectedSerial?.value = '';
    selectedFault?.value = 0;
    // selectedFault?.value = "";
    selectedArea?.value = '';
    selectedSubArea?.value = '';
    selectedZone?.value = '';
    lockFieldsAfterSerialSelection.value = false;
    lockFieldSerialNo.value = false;

    await getSubProducts(customerId);
    await getDeviceRefs(customerId);
    await getAreas(customerId);
    await getSerials(customerId);
  }

  void onAreaSelected(String? value) async {
    selectedArea?.value = value ?? '';

    if (value != null && value.isNotEmpty) {
      final area = areas.firstWhereOrNull((e) => e.strLookupText == value);

      if (area != null) {
        areaId = area.intLookupId;
        subAreas.clear();
        zone.value = null;
        subProducts.clear();
        serials.clear();

        selectedSubArea?.value = '';
        selectedZone?.value = '';
        selectedSubProduct?.value = '';
        selectedSerial?.value = '';
        await getSubAreas(areaId);
        await getZones(areaId);
        await getSubProducts(customerId, area: areaId);
        await getSerials(customerId);
      }
    }
  }

  void onSubAreaSelected(String? value) async {
    selectedSubArea?.value = value ?? '';

    if (value != null && value.isNotEmpty) {
      final subArea = subAreas.firstWhereOrNull(
        (e) => e.strLookupText == value,
      );

      if (subArea != null) {
        subAreaId = subArea.intLookupId;

        subProducts.clear();
        serials.clear();
        selectedSubProduct?.value = "";
        selectedSerial?.value = "";

        await getSubProducts(customerId, subarea: subAreaId);
        await getSerials(customerId);
      }
    }
  }

  void onZoneSelected(String? value) {
    selectedZone?.value = value ?? '';
  }

  void onSubProductSelected(String? value) async {
    selectedSubProduct?.value = value ?? '';

    if (value != null && value.isNotEmpty) {
      // final subProduct = subProducts.firstWhereOrNull(
      //   (e) => e.strLookupText == value,
      // );

      // if (subProduct != null) {
      //   final subProductId = subProduct.intLookupId;
      // }
    }
  }

  void onDeviceRefSelected(String? value) {
    selectedDeviceRef?.value = value ?? '';
    getSubProductFileByDeviceRef(selectedDeviceRef!.value);
  }

  void onSerialSelected(String? value) async {
    selectedSerial?.value = value ?? '';

    if (value != null && value.isNotEmpty) {
      final serial = serials.firstWhereOrNull(
        (e) => e.strLookupId == value || e.strLookupText == value,
      );

      if (serial != null) {
        final serialNo = serial.strLookupId ?? serial.strLookupText ?? '';
        if (serialNo.isNotEmpty) {
          log('➡️ Fetching serial file for: $serialNo');
          await getSubProductFileBySerial(serialNo);
        }
      }
    }
  }

  void onFaultSelected(int? value) {
    selectedFault?.value = value ?? 0;
  }

  Future<void> insertTicket() async {
    try {
      isLoadingSubmit.value = true;
      List<String> missingFields = [];

      if (callerName.text.isEmpty) missingFields.add("Caller Name");
      if (selectedTicketType?.value.isEmpty ?? true) {
        missingFields.add("Ticket Type");
      }
      if (customerId == 0 || selectedCustomer?.value.isEmpty == true) {
        missingFields.add("Customer");
      }
      if (selectedSubProduct?.value.isEmpty ?? true) {
        missingFields.add("Sub Product");
      }
      if (selectedSerial?.value.isEmpty ?? true) missingFields.add("Serial No");
      if (selectedArea?.value.isEmpty ?? true) missingFields.add("Area");
      if (selectedSubArea?.value.isEmpty ?? true) missingFields.add("Sub Area");
      if (faultNote?.text.isEmpty ?? true) missingFields.add("Fault Note");

      if (missingFields.isNotEmpty) {
        String fields = missingFields.join(", ");

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
        log('🎫 Ticket Created Successfully: ID = ${res.ticketId}');
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
        log('⚠️ Failed to create ticket: ${res.message}');
        Get.snackbar(
          '❌ Error',
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
      log('❌ Exception in insertTicket: $e');
      log('$stack');
      Get.snackbar(
        'Error',
        'An unexpected error occurred while creating the ticket.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.black87,
        duration: const Duration(seconds: 4),
        icon: const Icon(Icons.error_outline, color: Colors.red),
        margin: const EdgeInsets.all(12),
        borderRadius: 12,
      );
    } finally {
      isLoadingSubmit.value = false;
    }
  }

  @override
  void onClose() {
    // callerName.dispose();
    // receivedBy.dispose();
    // faultNote.dispose();
    // note.dispose();
    super.onClose();
  }

  void clearAll() {
    selectedTicketType?.value = '';
    selectedCustomer?.value = '';
    selectedSubProduct?.value = '';
    selectedDeviceRef?.value = '';
    selectedSerial?.value = '';
    selectedFault?.value = 0;
    // selectedFault?.value = "";
    selectedArea?.value = '';
    selectedSubArea?.value = '';
    selectedZone?.value = '';
    callerName.clear();
    // receivedBy.clear();
    note.clear();
    faultNote.clear();
    faultNote.clear();
    subProducts.clear();
    deviceRefs.clear();
    serials.clear();
    areas.clear();
    subAreas.clear();
    zone.value = null;

    dropdownKey.currentState?.clear();

  }
}
