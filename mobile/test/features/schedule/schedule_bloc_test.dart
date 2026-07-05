import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/features/schedule/presentation/schedule_bloc.dart';
import 'package:mobile/features/schedule/presentation/schedule_event.dart';
import 'package:mobile/features/schedule/presentation/schedule_state.dart';
import 'package:mobile/features/schedule/data/schedule_repository.dart';
import 'package:mobile/features/schedule/domain/schedule_model.dart';

class MockScheduleRepository extends Mock implements ScheduleRepository {}

void main() {
  group('ScheduleBloc', () {
    late ScheduleRepository scheduleRepository;
    late ScheduleBloc scheduleBloc;

    setUp(() {
      scheduleRepository = MockScheduleRepository();
      scheduleBloc = ScheduleBloc(scheduleRepository: scheduleRepository);
    });

    test('initial state is ScheduleState()', () {
      expect(scheduleBloc.state, const ScheduleState());
    });

    final scheduleList = [
      const Schedule(
        id: '1',
        subject: 'Math',
        startTime: '09:00',
        endTime: '10:00',
        room: 'Room 101',
        dayOfWeek: 'Monday',
      ),
    ];

    blocTest<ScheduleBloc, ScheduleState>(
      'emits [loading, success] when LoadSchedule is successful',
      build: () {
        when(() => scheduleRepository.getSchedule()).thenAnswer((_) async => scheduleList);
        return scheduleBloc;
      },
      act: (bloc) => bloc.add(LoadSchedule()),
      expect: () => [
        const ScheduleState(status: ScheduleStatus.loading),
        ScheduleState(status: ScheduleStatus.success, schedules: scheduleList),
      ],
    );

    blocTest<ScheduleBloc, ScheduleState>(
      'emits [loading, error] when LoadSchedule fails',
      build: () {
        when(() => scheduleRepository.getSchedule()).thenThrow(Exception('Failed to load'));
        return scheduleBloc;
      },
      act: (bloc) => bloc.add(LoadSchedule()),
      expect: () => [
        const ScheduleState(status: ScheduleStatus.loading),
        const ScheduleState(status: ScheduleStatus.error, errorMessage: 'Exception: Failed to load'),
      ],
    );
  });
}
