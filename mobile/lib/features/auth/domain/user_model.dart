import 'package:equatable/equatable.dart';

enum UserRole {
  student,
  admin,
}

class User extends Equatable {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final bool isApproved;
  final String reminderFrequency;
  final int classReminderTime;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.isApproved,
    this.reminderFrequency = 'DAILY',
    this.classReminderTime = 30,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role']?.toUpperCase() == 'ADMIN' ? UserRole.admin : UserRole.student,
      isApproved: json['isApproved'] ?? false,
      reminderFrequency: json['reminderFrequency'] ?? 'DAILY',
      classReminderTime: json['classReminderTime'] ?? 30,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role == UserRole.admin ? 'ADMIN' : 'STUDENT',
      'isApproved': isApproved,
      'reminderFrequency': reminderFrequency,
      'classReminderTime': classReminderTime,
    };
  }

  bool get isAdmin => role == UserRole.admin;
  bool get isStudent => role == UserRole.student;

  String get roleDisplay {
    return role == UserRole.admin ? 'Administrator' : 'Student';
  }

  @override
  List<Object?> get props => [id, name, email, role, isApproved, reminderFrequency, classReminderTime];
}
