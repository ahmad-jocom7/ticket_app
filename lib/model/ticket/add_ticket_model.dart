class AddTicketModel {
  int ticketId;
  dynamic statusCode;
  bool status;
  String message;

  AddTicketModel({
    required this.ticketId,
    required this.statusCode,
    required this.status,
    required this.message,
  });

  factory AddTicketModel.fromJson(Map<String, dynamic> json) => AddTicketModel(
    ticketId: json["Ticket_ID"],
    statusCode: json["status_code"],
    status: json["status"],
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "Ticket_ID": ticketId,
    "status_code": statusCode,
    "status": status,
    "message": message,
  };
}
