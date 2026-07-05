import 'package:equatable/equatable.dart';

class Announcement extends Equatable {
  final String id;
  final String title;
  final String content;
  final String type; // EVENT, INFO, ALERT
  final String source; // CLUBS, REGISTRAR, DEPARTMENT, ADMINISTRATION
  final DateTime deadline;
  final String creatorId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Announcement({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
    required this.source,
    required this.deadline,
    required this.creatorId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Untitled',
      content: json['content']?.toString() ?? '',
      type: json['type']?.toString() ?? 'INFO',
      source: json['source']?.toString() ?? 'ADMINISTRATION',
      deadline: json['deadline'] != null 
          ? DateTime.parse(json['deadline'].toString()) 
          : DateTime.now().add(const Duration(days: 7)),
      creatorId: json['creatorId']?.toString() ?? '',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'].toString()) 
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'].toString()) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'type': type,
      'source': source,
      'deadline': deadline.toIso8601String(),
      'creatorId': creatorId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  bool get isActive => deadline.isAfter(DateTime.now());
  
  String get formattedDeadline {
    final now = DateTime.now();
    final difference = deadline.difference(now);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} left';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} left';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} left';
    } else {
      return 'Expired';
    }
  }

  @override
  List<Object?> get props => [
    id, 
    title, 
    content, 
    type, 
    source, 
    deadline, 
    creatorId, 
    createdAt, 
    updatedAt
  ];
}
