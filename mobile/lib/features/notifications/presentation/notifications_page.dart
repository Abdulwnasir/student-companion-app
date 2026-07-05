import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/network/api_config.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<dynamic> _notifications = [];
  bool _isLoading = true;
  String? _errorMessage;
  final storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final token = await storage.read(key: 'jwt_token');
      print('📱 NotificationsPage - Loading notifications...');
      
      if (token == null) {
        setState(() {
          _errorMessage = 'Please login to see notifications';
          _isLoading = false;
        });
        return;
      }
      
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/notifications'),
        headers: {'Authorization': 'Bearer $token'},
      );
      
      print('📱 NotificationsPage - Response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _notifications = data['notifications'] ?? [];
          _isLoading = false;
        });
        print('📱 Loaded ${_notifications.length} notifications');
      } else {
        setState(() {
          _errorMessage = 'Failed to load notifications';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('📱 Error: $e');
      setState(() {
        _errorMessage = 'Network error';
        _isLoading = false;
      });
    }
  }

  Future<void> _markAsRead(String id) async {
    try {
      final token = await storage.read(key: 'jwt_token');
      await http.put(
        Uri.parse('${ApiConfig.baseUrl}/notifications/$id/read'),
        headers: {'Authorization': 'Bearer $token'},
      );
      _loadNotifications();
    } catch (e) {
      print('Error marking as read: $e');
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      final token = await storage.read(key: 'jwt_token');
      await http.put(
        Uri.parse('${ApiConfig.baseUrl}/notifications/read-all'),
        headers: {'Authorization': 'Bearer $token'},
      );
      _loadNotifications();
    } catch (e) {
      print('Error marking all as read: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        actions: [
          if (_notifications.isNotEmpty)
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text('Mark all read', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(_errorMessage!, style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadNotifications,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    
    if (_notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('No notifications yet', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
            const SizedBox(height: 8),
            Text('When you receive notifications, they will appear here', 
              style: TextStyle(color: Colors.grey[500], fontSize: 12)),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _notifications.length,
      itemBuilder: (context, index) {
        final notification = _notifications[index];
        final isRead = notification['isRead'] == true;
        final createdAt = DateTime.parse(notification['createdAt']);
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          color: isRead ? null : AppTheme.primary.withOpacity(0.05),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getTypeColor(notification['type']).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getTypeIcon(notification['type']),
                color: _getTypeColor(notification['type']),
                size: 24,
              ),
            ),
            title: Text(
              notification['title'] ?? 'Notification',
              style: TextStyle(
                fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(notification['message'] ?? 'No content'),
                const SizedBox(height: 4),
                Text(
                  DateFormat('MMM d, h:mm a').format(createdAt),
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
              ],
            ),
            trailing: isRead
                ? null
                : IconButton(
                    icon: const Icon(Icons.check_circle_outline, color: Colors.green),
                    onPressed: () => _markAsRead(notification['id']),
                  ),
            onTap: () {
              if (!isRead) {
                _markAsRead(notification['id']);
              }
              _showDetails(notification);
            },
          ),
        );
      },
    );
  }

  void _showDetails(dynamic notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(notification['title'] ?? 'Notification'),
        content: Text(notification['message'] ?? 'No content'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type.toUpperCase() ?? 'INFO') {
      case 'ASSIGNMENT': return Icons.assignment;
      case 'SCHEDULE': return Icons.calendar_today;
      case 'AI': return Icons.auto_awesome;
      case 'DISCUSSION': return Icons.forum;
      case 'MATERIAL': return Icons.menu_book;
      case 'REMINDER': return Icons.notifications_active;
      case 'ALERT': return Icons.warning_amber_rounded;
      default: return Icons.info_outline;
    }
  }

  Color _getTypeColor(String type) {
    switch (type.toUpperCase() ?? 'INFO') {
      case 'ASSIGNMENT': return Colors.orange;
      case 'SCHEDULE': return Colors.blue;
      case 'AI': return Colors.purple;
      case 'DISCUSSION': return Colors.green;
      case 'MATERIAL': return Colors.teal;
      case 'REMINDER': return Colors.red;
      case 'ALERT': return Colors.red;
      default: return AppTheme.primary;
    }
  }
}
