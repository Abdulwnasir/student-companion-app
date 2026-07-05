import 'package:equatable/equatable.dart';
import '../domain/assignment_model.dart';

enum AssignmentStatus { initial, loading, success, error }

class AssignmentState extends Equatable {
  final AssignmentStatus status;
  final List<Assignment> assignments;
  final String? errorMessage;

  const AssignmentState({
    this.status = AssignmentStatus.initial,
    this.assignments = const [],
    this.errorMessage,
  });

  @override
  List<Object?> get props => [status, assignments, errorMessage];

  AssignmentState copyWith({
    AssignmentStatus? status,
    List<Assignment>? assignments,
    String? errorMessage,
  }) {
    return AssignmentState(
      status: status ?? this.status,
      assignments: assignments ?? this.assignments,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
