import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/features/schedule/data/schedule_repository.dart';
import 'package:mobile/features/schedule/presentation/schedule_event.dart';
import 'package:mobile/features/schedule/presentation/schedule_state.dart';
import 'package:mobile/core/services/local_notification_service.dart';
import '../../auth/presentation/auth_bloc.dart';

class ScheduleBloc extends Bloc<ScheduleEvent, ScheduleState> {
  final ScheduleRepository scheduleRepository;
  final LocalNotificationService localNotificationService;
  final AuthBloc authBloc;

  ScheduleBloc({
    required this.scheduleRepository,
    required this.localNotificationService,
    required this.authBloc,
  }) : super(const ScheduleState()) {
    on<LoadSchedule>(_onLoadSchedule);
    on<AddSchedule>(_onAddSchedule);
    on<UpdateSchedule>(_onUpdateSchedule);
    on<DeleteSchedule>(_onDeleteSchedule);
  }

  Future<void> _onLoadSchedule(
    LoadSchedule event,
    Emitter<ScheduleState> emit,
  ) async {
    print('ScheduleBloc: Loading schedule...');
    emit(state.copyWith(status: ScheduleStatus.loading));
    try {
      final schedule = await scheduleRepository.getSchedule();
      print('ScheduleBloc: Received ${schedule.length} schedule items');

      // Schedule notifications for all items with reminders enabled
      for (final item in schedule) {
        if (item.reminderEnabled) {
          final user = authBloc.state.user;
          final reminderMinutes = user?.classReminderTime ?? item.reminderTime;

          // Logic to calculate the next occurrence of this class
          // This is a simplified version; real logic would depend on the dayOfWeek string
          // and parsing startTime
          try {
            // For demonstration, we schedule one for today if the time hasn't passed
            // In a full implementation, you'd calculate the next valid DateTime based on dayOfWeek
          } catch (_) {}
        }
      }

      print(
        'ScheduleBloc: Emitting success state with ${schedule.length} schedules',
      );
      emit(state.copyWith(status: ScheduleStatus.success, schedules: schedule));
    } catch (e) {
      print('ScheduleBloc: Error loading schedule: $e');
      emit(
        state.copyWith(
          status: ScheduleStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onAddSchedule(
    AddSchedule event,
    Emitter<ScheduleState> emit,
  ) async {
    emit(state.copyWith(status: ScheduleStatus.loading));
    try {
      await scheduleRepository.addSchedule(event.scheduleData);
      add(LoadSchedule());
    } catch (e) {
      emit(
        state.copyWith(
          status: ScheduleStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onUpdateSchedule(
    UpdateSchedule event,
    Emitter<ScheduleState> emit,
  ) async {
    emit(state.copyWith(status: ScheduleStatus.loading));
    try {
      await scheduleRepository.updateSchedule(event.id, event.scheduleData);
      add(LoadSchedule());
    } catch (e) {
      emit(
        state.copyWith(
          status: ScheduleStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onDeleteSchedule(
    DeleteSchedule event,
    Emitter<ScheduleState> emit,
  ) async {
    emit(state.copyWith(status: ScheduleStatus.loading));
    try {
      await scheduleRepository.deleteSchedule(event.id);
      add(LoadSchedule());
    } catch (e) {
      emit(
        state.copyWith(
          status: ScheduleStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
