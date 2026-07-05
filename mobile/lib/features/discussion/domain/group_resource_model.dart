import 'package:equatable/equatable.dart';

class GroupResource extends Equatable {
  final String id;
  final String title;
  final String link;
  final String groupId;
  final String userId;
  final DateTime createdAt;

  const GroupResource({
    required this.id,
    required this.title,
    required this.link,
    required this.groupId,
    required this.userId,
    required this.createdAt,
  });

  factory GroupResource.fromJson(Map<String, dynamic> json) {
    return GroupResource(
      id: json['id'],
      title: json['title'],
      link: json['link'],
      groupId: json['groupId'],
      userId: json['userId'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  @override
  List<Object?> get props => [id, title, link, groupId, userId, createdAt];
}
