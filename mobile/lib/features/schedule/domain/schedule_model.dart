import 'package:equatable/equatable.dart';

class Schedule extends Equatable {
  final String id;
  final String subject;
  final String startTime;
  final String endTime;
  final String dayOfWeek;
  final String room;
  final int priority;
  final bool reminderEnabled;
  final int reminderTime;

  const Schedule({
    required this.id,
    required this.subject,
    required this.startTime,
    required this.endTime,
    required this.dayOfWeek,
    required this.room,
    this.priority = 100,
    this.reminderEnabled = true,
    this.reminderTime = 30,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id'],
      subject: json['className'] ?? json['subject'] ?? json['title'] ?? '',
      startTime: json['startTime'],
      endTime: json['endTime'],
      dayOfWeek: json['dayOfWeek'],
      room: json['roomNumber'] ?? json['room'] ?? json['location'] ?? '',
      priority: json['priority'] ?? 100,
      reminderEnabled: json['reminderEnabled'] ?? json['reminder'] ?? true,
      reminderTime: json['reminderTime'] ?? 30,
    );
  }

  @override
  List<Object?> get props => [id, subject, startTime, endTime, dayOfWeek, room, priority, reminderEnabled, reminderTime];
}
