import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/features/discussion/presentation/discussion_bloc.dart';
import 'package:mobile/features/discussion/presentation/discussion_event.dart';
import 'package:mobile/features/discussion/presentation/discussion_state.dart';
import 'package:mobile/features/discussion/data/discussion_repository.dart';
import 'package:mobile/features/discussion/domain/discussion_model.dart';

class MockDiscussionRepository extends Mock implements DiscussionRepository {}

void main() {
  group('DiscussionBloc', () {
    late DiscussionRepository repository;
    late DiscussionBloc discussionBloc;

    setUp(() {
      repository = MockDiscussionRepository();
      discussionBloc = DiscussionBloc(repository: repository);
    });

    final groups = [
      DiscussionGroup(id: '1', name: 'Group 1', description: 'Desc 1', creatorId: 'user1', createdAt: DateTime.now()),
    ];

    final messages = [
      DiscussionMessage(id: '1', groupId: '1', userId: 'user1', userName: 'User 1', content: 'Hello', createdAt: DateTime.now()),
    ];

    test('initial state is DiscussionState()', () {
      expect(discussionBloc.state, const DiscussionState());
    });

    blocTest<DiscussionBloc, DiscussionState>(
      'emits [loading, success] when LoadGroups is successful',
      build: () {
        when(() => repository.getGroups()).thenAnswer((_) async => groups);
        return discussionBloc;
      },
      act: (bloc) => bloc.add(LoadGroups()),
      expect: () => [
        const DiscussionState(status: DiscussionStatus.loading),
        DiscussionState(status: DiscussionStatus.success, groups: groups),
      ],
    );

    blocTest<DiscussionBloc, DiscussionState>(
      'emits [loading, success] when LoadMessages is successful',
      build: () {
        when(() => repository.getGroupMessages(any())).thenAnswer((_) async => messages);
        return discussionBloc;
      },
      act: (bloc) => bloc.add(const LoadMessages('1')),
      expect: () => [
        const DiscussionState(status: DiscussionStatus.loading),
        DiscussionState(status: DiscussionStatus.success, currentMessages: messages),
      ],
    );

    blocTest<DiscussionBloc, DiscussionState>(
      'emits [loading, success] after CreateGroup is successful',
      build: () {
        when(() => repository.createGroup(any(), any())).thenAnswer((_) async => {});
        when(() => repository.getGroups()).thenAnswer((_) async => groups);
        return discussionBloc;
      },
      act: (bloc) => bloc.add(const CreateGroup('New', 'Desc')),
      expect: () => [
        const DiscussionState(status: DiscussionStatus.loading),
        DiscussionState(status: DiscussionStatus.success, groups: groups),
      ],
    );

    blocTest<DiscussionBloc, DiscussionState>(
      'emits [loading, success] when SearchDiscussions is successful',
      build: () {
        when(() => repository.searchDiscussions(any())).thenAnswer((_) async => messages);
        return discussionBloc;
      },
      act: (bloc) => bloc.add(const SearchDiscussions('query')),
      expect: () => [
        const DiscussionState(status: DiscussionStatus.loading),
        DiscussionState(status: DiscussionStatus.success, searchResults: messages),
      ],
    );
  });
}
