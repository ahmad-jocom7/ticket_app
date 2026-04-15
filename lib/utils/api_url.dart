class ApiUrl {
  // static const String baseUrl = "http://10.0.0.63:83/api/";
  // static const String baseUrl = "http://10.0.0.63:9096/api/";
  static const String baseUrl = "https://ticketing_api.jocom.jo/api/";

  static const String login = "Login/LoginApp";

  static const String getAssignedTickets =
      "Ticket/getAssignedTicketsByEmployee";
  static const String getAcceptedTickets =
      "Ticket/getAssignedTicketsByEmployee";
  static const String
  getTicketsHistory = "Ticket/GetEmployeeTicketsMonth";
  static const String updateAssignTicket = "Ticket/UpdateAssignTicket";
  static const String openServiceRecord = "ServiceRecord/OpenServiceRecord";
  static const String closeServiceRecord = "ServiceRecord/CloseServiceRecord";
  static const String getHardwareContent = "ddl/FillDDLParam";
  static const String getUnsolvedReason = "ddl/FillDDL";
  static const String getServiceRecordById = "ServiceRecord/GetById";

  static const String getSystemConfiguration =
      "SystemSetting/GetSystemConfigration";
  static const String getCustomers = "ddl/FillDDLParamPagination";
  static const String getSubProduct = "ddl/FillDDLParam";
  static const String getDeviceRef = "ddl/FillDDLParamIdString";
  static const String getSubProductFileByCustomerRefNo =
      "SubProductFile/GetSubProductFileByCustomerRefNo";
  static const String getArea = "ddl/FillDDLParam";
  static const String getSubArea = "ddl/FillDDLParam";
  static const String getZone = "Area/GetAreaById";
  static const String getSubProductFileBySerialNo =
      "SubProductFile/GetSubProductFileBySerialNo";
  static const String getFault = "ddl/FillDDLParam";
  static const String addTicket = "Ticket/InsertTicket";
  static const String assignTicket = "Ticket/InsertAssignTicket";
}
