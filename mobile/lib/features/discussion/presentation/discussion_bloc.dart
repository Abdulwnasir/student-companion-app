import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/discussion_repository.dart';
import 'discussion_event.dart';
import 'discussion_state.dart';

class DiscussionBloc extends Bloc<DiscussionEvent, DiscussionState> {
  final DiscussionRepository repository;

  DiscussionBloc({required this.repository}) : super(const DiscussionState()) {
    on<LoadGroups>(_onLoadGroups);
    on<CreateGroup>(_onCreateGroup);
    on<LoadMessages>(_onLoadMessages);
    on<PostMessage>(_onPostMessage);
    on<PostComment>(_onPostComment);
    on<SearchDiscussions>(_onSearchDiscussions);
    on<LoadGroupResources>(_onLoadGroupResources);
    on<AddGroupResource>(_onAddGroupResource);
    on<DeleteGroupResource>(_onDeleteGroupResource);
  }

  Future<void> _onLoadGroups(LoadGroups event, Emitter<DiscussionState> emit) async {
    print('Loading groups...');
    emit(state.copyWith(status: DiscussionStatus.loading));
    try {
      final groups = await repository.getGroups();
      print('Loaded ${groups.length} groups');
      emit(state.copyWith(status: DiscussionStatus.success, groups: groups));
    } catch (e) {
      print('Error loading groups: $e');
      emit(state.copyWith(status: DiscussionStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> _onCreateGroup(CreateGroup event, Emitter<DiscussionState> emit) async {
    try {
      await repository.createGroup(event.name, event.description);
      add(LoadGroups());
    } catch (e) {
      emit(state.copyWith(status: DiscussionStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> _onLoadMessages(LoadMessages event, Emitter<DiscussionState> emit) async {
    emit(state.copyWith(status: DiscussionStatus.loading));
    try {
      final messages = await repository.getGroupMessages(event.groupId);
      emit(state.copyWith(status: DiscussionStatus.success, currentMessages: messages));
    } catch (e) {
      emit(state.copyWith(status: DiscussionStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> _onPostMessage(PostMessage event, Emitter<DiscussionState> emit) async {
    try {
      await repository.postMessage(event.groupId, event.content, event.file);
      add(LoadMessages(event.groupId));
    } catch (e) {
      emit(state.copyWith(status: DiscussionStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> _onPostComment(PostComment event, Emitter<DiscussionState> emit) async {
    try {
      await repository.postComment(event.messageId, event.content);
      add(LoadMessages(event.groupId));
    } catch (e) {
      emit(state.copyWith(status: DiscussionStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> _onSearchDiscussions(SearchDiscussions event, Emitter<DiscussionState> emit) async {
    emit(state.copyWith(status: DiscussionStatus.loading));
    try {
      final results = await repository.searchDiscussions(event.query);
      emit(state.copyWith(status: DiscussionStatus.success, searchResults: results));
    } catch (e) {
      emit(state.copyWith(status: DiscussionStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> _onLoadGroupResources(LoadGroupResources event, Emitter<DiscussionState> emit) async {
    emit(state.copyWith(status: DiscussionStatus.loading));
    try {
      final resources = await repository.getGroupResources(event.groupId);
      emit(state.copyWith(status: DiscussionStatus.success, resources: resources));
    } catch (e) {
      emit(state.copyWith(status: DiscussionStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> _onAddGroupResource(AddGroupResource event, Emitter<DiscussionState> emit) async {
    try {
      await repository.addResource(event.groupId, event.title, event.link);
      add(LoadGroupResources(event.groupId));
    } catch (e) {
      emit(state.copyWith(status: DiscussionStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> _onDeleteGroupResource(DeleteGroupResource event, Emitter<DiscussionState> emit) async {
    try {
      await repository.deleteResource(event.resourceId);
      add(LoadGroupResources(event.groupId));
    } catch (e) {
      emit(state.copyWith(status: DiscussionStatus.error, errorMessage: e.toString()));
    }
  }
}
