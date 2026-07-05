import 'package:equatable/equatable.dart';

class Assignment extends Equatable {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final String? dueTime; // Format: HH:mm
  final int? reminderTime; // Minutes before due
  final String status;
  final String priority; // HIGH, MEDIUM, LOW

  const Assignment({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    this.dueTime,
    this.reminderTime,
    required this.status,
    this.priority = 'MEDIUM',
  });

  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      dueDate: DateTime.parse(json['dueDate'] ?? json['deadline'] ?? DateTime.now().toIso8601String()),
      dueTime: json['dueTime'],
      reminderTime: json['reminderTime'],
      status: json['status'] ?? 'PENDING',
      priority: json['priority'] ?? 'MEDIUM',
    );
  }

  @override
  List<Object?> get props => [id, title, description, dueDate, dueTime, reminderTime, status, priority];
}
