import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/notification_repository.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository repository;

  NotificationBloc({required this.repository}) : super(const NotificationState()) {
    on<LoadNotifications>(_onLoadNotifications);
    on<MarkAsRead>(_onMarkAsRead);
    on<MarkAllAsRead>(_onMarkAllAsRead);
  }

  Future<void> _onLoadNotifications(LoadNotifications event, Emitter<NotificationState> emit) async {
    emit(state.copyWith(status: NotificationStatus.loading));
    try {
      final notifications = await repository.getNotifications();
      emit(state.copyWith(status: NotificationStatus.success, notifications: notifications));
    } catch (e) {
      emit(state.copyWith(status: NotificationStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> _onMarkAsRead(MarkAsRead event, Emitter<NotificationState> emit) async {
    try {
      await repository.markAsRead(event.id);
      add(LoadNotifications());
    } catch (e) {
      // Optimistically we could update state, but simply reloading for now
      emit(state.copyWith(status: NotificationStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> _onMarkAllAsRead(MarkAllAsRead event, Emitter<NotificationState> emit) async {
    try {
      await repository.markAllAsRead();
      add(LoadNotifications());
    } catch (e) {
      emit(state.copyWith(status: NotificationStatus.error, errorMessage: e.toString()));
    }
  }
}
