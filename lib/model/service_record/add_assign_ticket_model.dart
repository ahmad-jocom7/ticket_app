class AddAssignTicketModel {
  int assignTicketId;
  bool status;
  String message;

  AddAssignTicketModel({
    required this.assignTicketId,
    required this.status,
    required this.message,
  });

  factory AddAssignTicketModel.fromJson(Map<String, dynamic> json) =>
      AddAssignTicketModel(
        assignTicketId: json["AssignTicket_ID"],
        status: json["status"],
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
    "AssignTicket_ID": assignTicketId,
    "status": status,
    "message": message,
  };
}
