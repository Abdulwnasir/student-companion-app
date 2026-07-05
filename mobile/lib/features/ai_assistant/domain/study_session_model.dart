import 'package:equatable/equatable.dart';

class StudySession extends Equatable {
  final String id;
  final String subject;
  final String dayOfWeek;
  final String startTime;
  final String endTime;
  final String type;
  final String? note;

  const StudySession({
    required this.id,
    required this.subject,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.type = 'MANUAL',
    this.note,
  });

  factory StudySession.fromJson(Map<String, dynamic> json) {
    return StudySession(
      id: json['id'],
      subject: json['subject'],
      dayOfWeek: json['dayOfWeek'],
      startTime: json['startTime'],
      endTime: json['endTime'],
      type: json['type'] ?? 'MANUAL',
      note: json['note'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subject': subject,
      'dayOfWeek': dayOfWeek,
      'startTime': startTime,
      'endTime': endTime,
      'type': type,
      'note': note,
    };
  }

  @override
  List<Object?> get props => [id, subject, dayOfWeek, startTime, endTime, type, note];
}
