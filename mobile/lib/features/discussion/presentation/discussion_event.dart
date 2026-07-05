import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class DiscussionEvent extends Equatable {
  const DiscussionEvent();
  @override
  List<Object?> get props => [];
}

class LoadGroups extends DiscussionEvent {}

class CreateGroup extends DiscussionEvent {
  final String name;
  final String description;
  const CreateGroup(this.name, this.description);
  @override
  List<Object?> get props => [name, description];
}

class LoadMessages extends DiscussionEvent {
  final String groupId;
  const LoadMessages(this.groupId);
  @override
  List<Object?> get props => [groupId];
}

class PostMessage extends DiscussionEvent {
  final String groupId;
  final String content;
  final File? file;
  const PostMessage(this.groupId, this.content, this.file);
  @override
  List<Object?> get props => [groupId, content, file];
}

class PostComment extends DiscussionEvent {
  final String messageId;
  final String groupId; // To reload messages
  final String content;
  const PostComment(this.messageId, this.groupId, this.content);
  @override
  List<Object?> get props => [messageId, groupId, content];
}

class SearchDiscussions extends DiscussionEvent {
  final String query;
  const SearchDiscussions(this.query);
  @override
  List<Object?> get props => [query];
}

class LoadGroupResources extends DiscussionEvent {
  final String groupId;
  const LoadGroupResources(this.groupId);
  @override
  List<Object?> get props => [groupId];
}

class AddGroupResource extends DiscussionEvent {
  final String groupId;
  final String title;
  final String link;
  const AddGroupResource(this.groupId, this.title, this.link);
  @override
  List<Object?> get props => [groupId, title, link];
}

class DeleteGroupResource extends DiscussionEvent {
  final String resourceId;
  final String groupId;
  const DeleteGroupResource(this.resourceId, this.groupId);
  @override
  List<Object?> get props => [resourceId, groupId];
}
