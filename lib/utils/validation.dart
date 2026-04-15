import 'package:get/get.dart';

class Validation {
  static bool isNotEmpty(String? s) => s != null && s.isNotEmpty;

  static bool isEmpty(String? s) => s == null || s.isEmpty;

  static String? isEmail(String? email) {
    String p =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regExp = RegExp(p);
    if (isEmpty(email)) {
      return "This is required".tr;
    } else if (!regExp.hasMatch(email!)) {
      return "Please enter valid email".tr;
    }
    return null;
  }

  static String? isPassword(String? password) {
    if (isEmpty(password)) {
      return "This is required".tr;
    } else if (password!.length < 8) {
      return "Please enter valid password".tr;
    }
    return null;
  }

  static String? isConfirmPassword(String? password, String? confirmPassword) {
    if (isEmpty(confirmPassword)) {
      return "This is required".tr;
    } else if (password != confirmPassword) {
      return "Password does not match".tr;
    }
    return null;
  }

  static String? isRequired(String? text) {
    if (isEmpty(text)) {
      return "This is required".tr;
    }
    return null;
  }

  static String? isPhone(String? text) {
    try {
      RegExp regExp = RegExp(r'^07[0-9]{8}$');
      if (isEmpty(text)) {
        return "This is required".tr;
      } else if (!regExp.hasMatch(text!)) {
        return "Please enter a valid phone number".tr;
      }
      return null;
    } catch (e) {
      return "Please enter a valid phone number".tr;
    }
  }
}
