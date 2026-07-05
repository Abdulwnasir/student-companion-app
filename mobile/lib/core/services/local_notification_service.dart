import 'package:flutter/foundation.dart';

class LocalNotificationService {
  static Future<void> initialize() async {
    if (kIsWeb) {
      print('LocalNotificationService: Web mode');
    } else {
      print('LocalNotificationService: Mobile mode (notifications disabled)');
    }
  }

  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    print('🔔 NOTIFICATION: $title');
    print('   Message: $body');
  }

  static Future<void> showScheduleReminder(String title, String body) async {
    print('⏰ SCHEDULE REMINDER: $title');
    print('   Message: $body');
  }

  static Future<void> showAssignmentReminder(String title, String body) async {
    print('📝 ASSIGNMENT REMINDER: $title');
    print('   Message: $body');
  }
}
