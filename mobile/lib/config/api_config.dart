class ApiConfig {
  // Permanent setup using ADB Reverse:
  // Run `adb reverse tcp:3000 tcp:3000` in your terminal when connected to physical device
  static const String baseUrl = 'http://192.168.137.102:3000/api';
  
  // For Android emulator (if using emulator instead of real phone)
  // static const String baseUrl = 'http://192.168.137.102:3000/api';
  
  // For iOS emulator
  // static const String baseUrl = 'http://10.156.104.98:3000/api';
}
