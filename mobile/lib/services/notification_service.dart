import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mobile/core/network/api_config.dart';
import 'package:mobile/features/notifications/presentation/notifications_page.dart';
import 'package:mobile/main.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final storage = FlutterSecureStorage();
  Timer? _pollTimer;
  int _lastUnreadCount = 0;
  final ValueNotifier<int> unreadCount = ValueNotifier<int>(0);

  void startPolling(BuildContext context) {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      await checkForNewNotifications();
    });
    checkForNewNotifications();
  }

  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  Future<void> checkForNewNotifications() async {
    try {
      print('🔔 Checking for new notifications...');
      final token = await storage.read(key: 'jwt_token');
      if (token == null) {
        print('🔔 No token found');
        return;
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/notifications/unread-count'),
        headers: {'Authorization': 'Bearer $token'},
      );
      
      print('🔔 Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final count = data['count'] ?? 0;
        print('🔔 Unread count: $count');
        
        unreadCount.value = count;
        
        if (count > _lastUnreadCount && _lastUnreadCount != 0) {
          final newCount = count - _lastUnreadCount;
          print('🔔 New notifications detected: $newCount');
          _showNotificationPopup('New Notification', 'You have $newCount new notification(s)');
        }
        
        _lastUnreadCount = count;
      }
    } catch (e) {
      print('🔔 Error checking notifications: $e');
    }
  }

  void _showNotificationPopup(String title, String message) {
    print('🔔 Attempting to show popup: $title - $message');
    
    final context = navigatorKey.currentContext;
    if (context == null) {
      print('🔔 No context available for popup');
      return;
    }
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.notifications_active, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(message),
                    ],
                  ),
                ),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            backgroundColor: Colors.blue.shade800,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'VIEW',
              textColor: Colors.white,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NotificationsPage()),
                );
              },
            ),
          ),
        );
      }
    });
  }
}
