import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/features/assignments/presentation/assignment_bloc.dart';
import 'package:mobile/features/assignments/presentation/assignment_event.dart';
import 'package:mobile/features/assignments/presentation/assignment_state.dart';
import 'package:mobile/features/assignments/data/assignment_repository.dart';
import 'package:mobile/features/assignments/domain/assignment_model.dart';

class MockAssignmentRepository extends Mock implements AssignmentRepository {}

void main() {
  group('AssignmentBloc', () {
    late AssignmentRepository assignmentRepository;
    late AssignmentBloc assignmentBloc;

    setUp(() {
      assignmentRepository = MockAssignmentRepository();
      assignmentBloc = AssignmentBloc(assignmentRepository: assignmentRepository);
    });

    final assignmentList = [
      Assignment(
        id: '1',
        title: 'Project Alpha',
        description: 'Complete the design phase',
        dueDate: DateTime.now(),
        status: 'PENDING',
        priority: 'HIGH',
      ),
    ];

    test('initial state is AssignmentState()', () {
      expect(assignmentBloc.state, const AssignmentState());
    });

    blocTest<AssignmentBloc, AssignmentState>(
      'emits [loading, success] when LoadAssignments is successful',
      build: () {
        when(() => assignmentRepository.getAssignments()).thenAnswer((_) async => assignmentList);
        return assignmentBloc;
      },
      act: (bloc) => bloc.add(LoadAssignments()),
      expect: () => [
        const AssignmentState(status: AssignmentStatus.loading),
        AssignmentState(status: AssignmentStatus.success, assignments: assignmentList),
      ],
    );

    blocTest<AssignmentBloc, AssignmentState>(
      'emits [loading, error] when LoadAssignments fails',
      build: () {
        when(() => assignmentRepository.getAssignments()).thenThrow(Exception('Failed to load'));
        return assignmentBloc;
      },
      act: (bloc) => bloc.add(LoadAssignments()),
      expect: () => [
        const AssignmentState(status: AssignmentStatus.loading),
        const AssignmentState(status: AssignmentStatus.error, errorMessage: 'Exception: Failed to load'),
      ],
    );

    blocTest<AssignmentBloc, AssignmentState>(
      'emits [loading, success] when CreateAssignment is successful',
      build: () {
        when(() => assignmentRepository.createAssignment(any())).thenAnswer((_) async => {});
        when(() => assignmentRepository.getAssignments()).thenAnswer((_) async => assignmentList);
        return assignmentBloc;
      },
      act: (bloc) => bloc.add(const CreateAssignment({'title': 'New'})),
      expect: () => [
        const AssignmentState(status: AssignmentStatus.loading),
        AssignmentState(status: AssignmentStatus.success, assignments: assignmentList),
      ],
    );

    blocTest<AssignmentBloc, AssignmentState>(
      'emits [loading, success] when UpdateAssignmentStatus is successful',
      build: () {
        when(() => assignmentRepository.updateAssignment(any(), any())).thenAnswer((_) async => {});
        when(() => assignmentRepository.getAssignments()).thenAnswer((_) async => assignmentList);
        return assignmentBloc;
      },
      act: (bloc) => bloc.add(const UpdateAssignmentStatus('1', 'COMPLETED')),
      expect: () => [
        const AssignmentState(status: AssignmentStatus.loading),
        AssignmentState(status: AssignmentStatus.success, assignments: assignmentList),
      ],
    );
  });
}
