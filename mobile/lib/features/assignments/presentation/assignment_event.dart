import 'package:equatable/equatable.dart';

abstract class AssignmentEvent extends Equatable {
  const AssignmentEvent();

  @override
  List<Object?> get props => [];
}

class LoadAssignments extends AssignmentEvent {}

class CreateAssignment extends AssignmentEvent {
  final Map<String, dynamic> assignmentData;

  const CreateAssignment(this.assignmentData);

  @override
  List<Object?> get props => [assignmentData];
}

class UpdateAssignmentStatus extends AssignmentEvent {
  final String id;
  final String status;
  const UpdateAssignmentStatus(this.id, this.status);
  @override
  List<Object?> get props => [id, status];
}

class DeleteAssignment extends AssignmentEvent {
  final String id;
  const DeleteAssignment(this.id);
  @override
  List<Object?> get props => [id];
}

class FilterAssignments extends AssignmentEvent {
  final String statusFilter; // ALL, PENDING, COMPLETED
  const FilterAssignments(this.statusFilter);
  @override
  List<Object?> get props => [statusFilter];
}
