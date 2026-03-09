class DeviceHistoryModel {
  List<TicketHistory>? ticketsHistory;

  DeviceHistoryModel({this.ticketsHistory});

  DeviceHistoryModel.fromJson(Map<String, dynamic> json) {
    if (json['tickets_history'] != null) {
      ticketsHistory = (json['tickets_history'] as List)
          .map((e) => TicketHistory.fromJson(e))
          .toList();
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (ticketsHistory != null) {
      data['tickets_history'] =
          ticketsHistory!.map((e) => e.toJson()).toList();
    }
    return data;
  }
}

class TicketHistory {
  int? ticketId;
  String? ticketDate;
  String? ticketFaultNote;
  String? ticketNote;
  int? assignEmployeeId;
  String? assignEmployeeName;
  String? recordDate;
  String? recordSolution;
  String? repairNote;
  String? serviceResult;

  TicketHistory({
    this.ticketId,
    this.ticketDate,
    this.ticketFaultNote,
    this.ticketNote,
    this.assignEmployeeId,
    this.assignEmployeeName,
    this.recordDate,
    this.recordSolution,
    this.repairNote,
    this.serviceResult,
  });

  TicketHistory.fromJson(Map<String, dynamic> json) {
    ticketId = json['ticketId'];
    ticketDate = json['ticketDate'];
    ticketFaultNote = json['ticketFaultNote'];
    ticketNote = json['ticketNote'];
    assignEmployeeId = json['assignEmployeeId'];
    assignEmployeeName = json['assignEmployeeName'];
    recordDate = json['recordDate'];
    recordSolution = json['recordSolution'];
    repairNote = json['repair_note'];
    serviceResult = json['service_result'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['ticketId'] = ticketId;
    data['ticketDate'] = ticketDate;
    data['ticketFaultNote'] = ticketFaultNote;
    data['ticketNote'] = ticketNote;
    data['assignEmployeeId'] = assignEmployeeId;
    data['assignEmployeeName'] = assignEmployeeName;
    data['recordDate'] = recordDate;
    data['recordSolution'] = recordSolution;
    data['repair_note'] = repairNote;
    data['service_result'] = serviceResult;
    return data;
  }
}