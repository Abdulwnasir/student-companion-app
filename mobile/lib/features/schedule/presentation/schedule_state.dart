import 'package:equatable/equatable.dart';
import '../domain/schedule_model.dart';

enum ScheduleStatus { initial, loading, success, error }

class ScheduleState extends Equatable {
  final ScheduleStatus status;
  final List<Schedule> schedules;
  final String? errorMessage;

  const ScheduleState({
    this.status = ScheduleStatus.initial,
    this.schedules = const [],
    this.errorMessage,
  });

  @override
  List<Object?> get props => [status, schedules, errorMessage];

  ScheduleState copyWith({
    ScheduleStatus? status,
    List<Schedule>? schedules,
    String? errorMessage,
  }) {
    return ScheduleState(
      status: status ?? this.status,
      schedules: schedules ?? this.schedules,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
