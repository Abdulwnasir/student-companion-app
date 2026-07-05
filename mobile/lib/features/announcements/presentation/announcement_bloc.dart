import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/announcement_repository.dart';
import 'announcement_event.dart';
import 'announcement_state.dart';

class AnnouncementBloc extends Bloc<AnnouncementEvent, AnnouncementState> {
  final AnnouncementRepository announcementRepository;

  AnnouncementBloc({required this.announcementRepository})
      : super(const AnnouncementState()) {
    on<LoadAnnouncements>(_onLoadAnnouncements);
  }

  Future<void> _onLoadAnnouncements(
      LoadAnnouncements event, Emitter<AnnouncementState> emit) async {
    print('📢 AnnouncementBloc: Loading announcements...');
    emit(state.copyWith(status: AnnouncementStatus.loading));
    try {
      final announcements = await announcementRepository.getActiveAnnouncements();
      print('📢 AnnouncementBloc: Got ${announcements.length} announcements');
      emit(state.copyWith(
        status: AnnouncementStatus.success,
        announcements: announcements,
      ));
    } catch (e) {
      print('❌ AnnouncementBloc Error: $e');
      emit(state.copyWith(
        status: AnnouncementStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
}
