import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showSuccess(String message) {
  Get.snackbar(
    'Success',
    message,
    snackPosition: SnackPosition.TOP,
    backgroundColor: Colors.green.shade100,
    colorText: Colors.black87,
    duration: const Duration(seconds: 4),
    icon: const Icon(Icons.check_circle, color: Colors.green),
    margin: const EdgeInsets.all(12),
    borderRadius: 12,
  );
}

void showError(String message) {
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
