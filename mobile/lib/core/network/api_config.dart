import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static String get baseUrl {
    // Get from .env file or use default (192.168.137.102 assumes `adb reverse tcp:3000 tcp:3000`)
    return dotenv.env['API_BASE_URL'] ?? 'http://192.168.137.102:3000/api';
  }
  
  static String get authUrl => '$baseUrl/auth';
  static String get loginUrl => '$baseUrl/auth/login';
  static String get registerUrl => '$baseUrl/auth/register';
  static String get scheduleUrl => '$baseUrl/schedules';
  static String get assignmentUrl => '$baseUrl/assignments';
  static String get aiUrl => '$baseUrl/ai';
  static String get discussionUrl => '$baseUrl/discussions';
  static String get materialUrl => '$baseUrl/materials';
  static String get notificationUrl => '$baseUrl/notifications';
  static String get announcementUrl => '$baseUrl/announcements';
}
