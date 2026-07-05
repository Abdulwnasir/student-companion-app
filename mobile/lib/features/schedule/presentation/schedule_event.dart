import 'package:equatable/equatable.dart';

abstract class ScheduleEvent extends Equatable {
  const ScheduleEvent();

  @override
  List<Object?> get props => [];
}

class LoadSchedule extends ScheduleEvent {}

class AddSchedule extends ScheduleEvent {
  final Map<String, dynamic> scheduleData;
  const AddSchedule(this.scheduleData);
  @override
  List<Object?> get props => [scheduleData];
}

class UpdateSchedule extends ScheduleEvent {
  final String id;
  final Map<String, dynamic> scheduleData;
  const UpdateSchedule(this.id, this.scheduleData);
  @override
  List<Object?> get props => [id, scheduleData];
}

class DeleteSchedule extends ScheduleEvent {
  final String id;
  const DeleteSchedule(this.id);
  @override
  List<Object?> get props => [id];
}
