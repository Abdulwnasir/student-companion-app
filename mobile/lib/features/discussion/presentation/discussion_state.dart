import 'package:equatable/equatable.dart';
import '../domain/discussion_model.dart';
import '../domain/group_resource_model.dart';

enum DiscussionStatus { initial, loading, success, error }

class DiscussionState extends Equatable {
  final DiscussionStatus status;
  final List<DiscussionGroup> groups;
  final List<DiscussionMessage> currentMessages;
  final List<DiscussionMessage> searchResults;
  final List<GroupResource> resources;
  final String? errorMessage;

  const DiscussionState({
    this.status = DiscussionStatus.initial,
    this.groups = const [],
    this.currentMessages = const [],
    this.searchResults = const [],
    this.resources = const [],
    this.errorMessage,
  });

  DiscussionState copyWith({
    DiscussionStatus? status,
    List<DiscussionGroup>? groups,
    List<DiscussionMessage>? currentMessages,
    List<DiscussionMessage>? searchResults,
    List<GroupResource>? resources,
    String? errorMessage,
  }) {
    return DiscussionState(
      status: status ?? this.status,
      groups: groups ?? this.groups,
      currentMessages: currentMessages ?? this.currentMessages,
      searchResults: searchResults ?? this.searchResults,
      resources: resources ?? this.resources,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, groups, currentMessages, searchResults, resources, errorMessage];
}
