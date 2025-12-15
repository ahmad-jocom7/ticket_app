class LoginResponse {
  final int status;
  final String message;
  final UserModel? user;

  LoginResponse({
    required this.status,
    required this.message,
    this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      status: json['status'] ?? 0,
      message: json['message'] ?? '',
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'user': user?.toJson(),
    };
  }
}

class UserModel {
  final int userId;
  final int employeeId;
  final int roleId;
  final String email;

  UserModel({
    required this.userId,
    required this.employeeId,
    required this.roleId,
    required this.email,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['user_id'] ?? 0,
      employeeId: json['employee_id'] ?? 0,
      roleId: json['role_id'] ?? 0,
      email: json['email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'employee_id': employeeId,
      'role_id': roleId,
      'email': email,
    };
  }
}
