import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/features/assignments/data/assignment_repository.dart';
import 'package:mobile/features/assignments/presentation/assignment_event.dart';
import 'package:mobile/features/assignments/presentation/assignment_state.dart';

class AssignmentBloc extends Bloc<AssignmentEvent, AssignmentState> {
  final AssignmentRepository assignmentRepository;

  AssignmentBloc({required this.assignmentRepository}) : super(const AssignmentState()) {
    on<LoadAssignments>(_onLoadAssignments);
    on<CreateAssignment>(_onCreateAssignment);
    on<UpdateAssignmentStatus>(_onUpdateAssignmentStatus);
    on<DeleteAssignment>(_onDeleteAssignment);
  }

  Future<void> _onLoadAssignments(LoadAssignments event, Emitter<AssignmentState> emit) async {
    emit(state.copyWith(status: AssignmentStatus.loading));
    try {
      final assignments = await assignmentRepository.getAssignments();
      emit(state.copyWith(status: AssignmentStatus.success, assignments: assignments));
    } catch (e) {
      emit(state.copyWith(status: AssignmentStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> _onUpdateAssignmentStatus(UpdateAssignmentStatus event, Emitter<AssignmentState> emit) async {
    emit(state.copyWith(status: AssignmentStatus.loading));
    try {
      await assignmentRepository.updateAssignment(event.id, {'status': event.status});
      add(LoadAssignments());
    } catch (e) {
      emit(state.copyWith(status: AssignmentStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> _onDeleteAssignment(DeleteAssignment event, Emitter<AssignmentState> emit) async {
    emit(state.copyWith(status: AssignmentStatus.loading));
    try {
      await assignmentRepository.deleteAssignment(event.id);
      add(LoadAssignments());
    } catch (e) {
      emit(state.copyWith(status: AssignmentStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> _onCreateAssignment(CreateAssignment event, Emitter<AssignmentState> emit) async {
    emit(state.copyWith(status: AssignmentStatus.loading));
    try {
      await assignmentRepository.createAssignment(event.assignmentData);
      add(LoadAssignments()); // Refresh the list
    } catch (e) {
      emit(state.copyWith(status: AssignmentStatus.error, errorMessage: e.toString()));
    }
  }
}
