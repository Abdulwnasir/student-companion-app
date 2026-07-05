import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/features/notifications/presentation/notification_bloc.dart';
import 'package:mobile/features/notifications/presentation/notification_event.dart';
import 'package:mobile/features/notifications/presentation/notification_state.dart';
import 'package:mobile/features/notifications/data/notification_repository.dart';
import 'package:mobile/core/network/notification_model.dart';

class MockNotificationRepository extends Mock implements NotificationRepository {}

void main() {
  group('NotificationBloc', () {
    late NotificationRepository repository;
    late NotificationBloc notificationBloc;

    setUp(() {
      repository = MockNotificationRepository();
      notificationBloc = NotificationBloc(repository: repository);
    });

    final notifications = [
      NotificationModel(id: '1', title: 'Test', message: 'Message', createdAt: DateTime.now(), isRead: false),
    ];

    test('initial state is NotificationState()', () {
      expect(notificationBloc.state, const NotificationState());
    });

    blocTest<NotificationBloc, NotificationState>(
      'emits [loading, success] when LoadNotifications is successful',
      build: () {
        when(() => repository.getNotifications()).thenAnswer((_) async => notifications);
        return notificationBloc;
      },
      act: (bloc) => bloc.add(LoadNotifications()),
      expect: () => [
        const NotificationState(status: NotificationStatus.loading),
        NotificationState(status: NotificationStatus.success, notifications: notifications),
      ],
    );

    blocTest<NotificationBloc, NotificationState>(
      'emits [loading, success] after MarkAsRead is successful',
      build: () {
        when(() => repository.markAsRead(any())).thenAnswer((_) async => {});
        when(() => repository.getNotifications()).thenAnswer((_) async => notifications);
        return notificationBloc;
      },
      act: (bloc) => bloc.add(const MarkAsRead('1')),
      expect: () => [
        const NotificationState(status: NotificationStatus.loading),
        NotificationState(status: NotificationStatus.success, notifications: notifications),
      ],
    );

    blocTest<NotificationBloc, NotificationState>(
      'emits [loading, success] after MarkAllAsRead is successful',
      build: () {
        when(() => repository.markAllAsRead()).thenAnswer((_) async => {});
        when(() => repository.getNotifications()).thenAnswer((_) async => notifications);
        return notificationBloc;
      },
      act: (bloc) => bloc.add(MarkAllAsRead()),
      expect: () => [
        const NotificationState(status: NotificationStatus.loading),
        NotificationState(status: NotificationStatus.success, notifications: notifications),
      ],
    );
  });
}
