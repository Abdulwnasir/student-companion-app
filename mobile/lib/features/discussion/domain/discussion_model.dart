import 'package:equatable/equatable.dart';

class DiscussionGroup extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String createdBy; // Changed from creatorId to match API
  final DateTime createdAt;
  final String? scope; // Add scope from API
  final String? targetId; // Add targetId from API
  final String? organizationContext; // For UI display

  const DiscussionGroup({
    required this.id,
    required this.name,
    this.description,
    required this.createdBy, // Updated field name
    required this.createdAt,
    this.scope,
    this.targetId,
    this.organizationContext,
  });

  factory DiscussionGroup.fromJson(Map<String, dynamic> json) {
    // Build organization context from scope and targetId
    final scope = json['scope'] as String?;
    final targetId = json['targetId'] as String?;
    String? orgContext;

    if (scope == 'UNIVERSITY') {
      orgContext = 'University Wide';
    } else if (scope == 'DEPARTMENT' && targetId != null) {
      orgContext = 'Department - $targetId';
    } else if (scope == 'BATCH' && targetId != null) {
      orgContext = 'Batch - $targetId';
    } else if (scope == 'SECTION' && targetId != null) {
      orgContext = 'Section - $targetId';
    }

    return DiscussionGroup(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      createdBy: json['createdBy'] as String, // Changed from creatorId
      createdAt: DateTime.parse(json['createdAt'] as String),
      scope: scope,
      targetId: targetId,
      organizationContext: orgContext,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    createdBy,
    createdAt,
    scope,
    targetId,
    organizationContext,
  ];
}

class DiscussionMessage extends Equatable {
  final String id;
  final String content;
  final String? fileUrl;
  final String groupId;
  final String userId;
  final String? userName;
  final List<DiscussionComment> comments;
  final DateTime createdAt;

  const DiscussionMessage({
    required this.id,
    required this.content,
    this.fileUrl,
    required this.groupId,
    required this.userId,
    this.userName,
    this.comments = const [],
    required this.createdAt,
  });

  factory DiscussionMessage.fromJson(Map<String, dynamic> json) {
    return DiscussionMessage(
      id: json['id'] as String,
      content: json['content'] as String,
      fileUrl: json['fileUrl'] as String?,
      groupId: json['groupId'] as String,
      userId: json['userId'] as String,
      userName: json['user']?['name'] as String?,
      comments: (json['comments'] as List? ?? [])
          .map((c) => DiscussionComment.fromJson(c))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  @override
  List<Object?> get props => [
    id,
    content,
    fileUrl,
    groupId,
    userId,
    userName,
    comments,
    createdAt,
  ];
}

class DiscussionComment extends Equatable {
  final String id;
  final String content;
  final String messageId;
  final String userId;
  final String? userName;
  final DateTime createdAt;

  const DiscussionComment({
    required this.id,
    required this.content,
    required this.messageId,
    required this.userId,
    this.userName,
    required this.createdAt,
  });

  factory DiscussionComment.fromJson(Map<String, dynamic> json) {
    return DiscussionComment(
      id: json['id'] as String,
      content: json['content'] as String,
      messageId: json['messageId'] as String,
      userId: json['userId'] as String,
      userName: json['user']?['name'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  @override
  List<Object?> get props => [
    id,
    content,
    messageId,
    userId,
    userName,
    createdAt,
  ];
}
