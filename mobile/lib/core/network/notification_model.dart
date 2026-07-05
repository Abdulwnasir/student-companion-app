import 'package:equatable/equatable.dart';

class NotificationModel extends Equatable {
  final String id;
  final String title;
  final String message;
  final DateTime createdAt;
  final bool isRead;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
    required this.isRead,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    String title = 'Notification';
    if (json['type'] == 'ALERT') title = 'Alert';
    if (json['type'] == 'REMINDER') title = 'Reminder';
    if (json['type'] == 'INFO') title = 'Info';

    return NotificationModel(
      id: json['id'],
      title: title,
      message: json['message'],
      createdAt: DateTime.parse(json['createdAt']),
      isRead: json['isRead'] ?? false,
    );
  }

  @override
  List<Object?> get props => [id, title, message, createdAt, isRead];
}
