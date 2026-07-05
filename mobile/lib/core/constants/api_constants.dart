// lib/core/constants/api_constants.dart
class ApiConstants {
  // Permanent setup using ADB Reverse:
  // Run `adb reverse tcp:3000 tcp:3000` in your terminal when connected to physical device
  static const String baseUrl = 'http://192.168.137.102:3000';
  
  // API Endpoints with correct paths from your backend
  static const String departments = '/api/organization/departments';
  static const String batches = '/api/organization/batches';
  static const String sections = '/api/organization/sections';
}
