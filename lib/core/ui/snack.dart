import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../errors/app_exception.dart';

/// App-wide, context-free feedback. Uses GetX so services / view-models can
/// report a failure without threading a BuildContext everywhere.
class Snack {
  const Snack._();

  static void success(String message, {String title = 'Done'}) {
    _show(title, message, const Color(0xFF2E7D32), Icons.check_circle_outline);
  }

  static void error(Object error, {String title = 'Something went wrong'}) {
    final msg = error is AppException ? error.message : error.toString();
    _show(title, msg, const Color(0xFFC62828), Icons.error_outline);
  }

  static void info(String message, {String title = 'Info'}) {
    _show(title, message, const Color(0xFF1565C0), Icons.info_outline);
  }

  static void _show(String title, String message, Color color, IconData icon) {
    if (Get.isSnackbarOpen) Get.closeAllSnackbars();
    Get.rawSnackbar(
      titleText: Text(
        title,
        style: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
      ),
      messageText: Text(
        message,
        style: const TextStyle(color: Colors.white, fontSize: 13),
      ),
      icon: Icon(icon, color: Colors.white),
      backgroundColor: color,
      borderRadius: 12,
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 16),
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 4),
      isDismissible: true,
    );
  }
}
