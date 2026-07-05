import 'package:equatable/equatable.dart';
import '../domain/announcement_model.dart';

enum AnnouncementStatus { initial, loading, success, error }

class AnnouncementState extends Equatable {
  final AnnouncementStatus status;
  final List<Announcement> announcements;
  final String? errorMessage;

  const AnnouncementState({
    this.status = AnnouncementStatus.initial,
    this.announcements = const [],
    this.errorMessage,
  });

  AnnouncementState copyWith({
    AnnouncementStatus? status,
    List<Announcement>? announcements,
    String? errorMessage,
  }) {
    return AnnouncementState(
      status: status ?? this.status,
      announcements: announcements ?? this.announcements,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, announcements, errorMessage];
}
