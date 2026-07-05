import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/schedule/presentation/schedule_bloc.dart';
import 'package:mobile/features/schedule/presentation/schedule_event.dart';
import 'package:mobile/features/schedule/presentation/schedule_state.dart';
import 'package:mobile/features/assignments/presentation/assignment_bloc.dart';
import 'package:mobile/features/assignments/presentation/assignment_event.dart';
import 'package:mobile/features/assignments/presentation/assignment_state.dart';
import 'package:mobile/features/assignments/domain/assignment_model.dart';
import 'package:mobile/features/schedule/domain/schedule_model.dart';
import 'package:mobile/features/assignments/presentation/assignment_list_page.dart';
import 'package:mobile/features/auth/presentation/auth_bloc.dart';
import 'package:mobile/features/auth/presentation/auth_state.dart';
import 'package:mobile/features/auth/presentation/profile_page.dart';
import 'package:mobile/features/notifications/presentation/notifications_page.dart';
import 'package:mobile/features/ai_assistant/presentation/ai_assistant_page.dart';
import 'package:mobile/features/ai_assistant/presentation/ai_bloc.dart';
import 'package:mobile/features/dashboard/presentation/main_page.dart';
import 'package:mobile/features/announcements/presentation/announcement_bloc.dart';
import 'package:mobile/features/announcements/presentation/announcement_state.dart';
import 'package:mobile/features/announcements/presentation/announcement_event.dart';
import 'package:mobile/features/announcements/domain/announcement_model.dart';
import 'package:mobile/features/announcements/presentation/announcement_detail_page.dart';
import 'package:mobile/services/notification_service.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final NotificationService _notificationService = NotificationService();
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    print('=== DashboardPage initState - Loading data ===');
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ScheduleBloc>().add(LoadSchedule());
        context.read<AssignmentBloc>().add(LoadAssignments());
        context.read<AIBloc>().add(const LoadAIInsights());
        context.read<AnnouncementBloc>().add(LoadAnnouncements());
        
        if (!_isListening) {
          _notificationService.startPolling(context);
          _isListening = true;
        }
      }
    });
  }

  @override
  void dispose() {
    _notificationService.stopPolling();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            _notificationService.checkForNewNotifications();
            context.read<AnnouncementBloc>().add(LoadAnnouncements());
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildAnnouncementsSection(context),
                const SizedBox(height: 24),
                _buildWorkloadBrief(context),
                const SizedBox(height: 32),
                _buildAISuggestionsSection(context),
                const SizedBox(height: 32),
                _buildScheduleSection(context),
                const SizedBox(height: 32),
                _buildAssignmentsSection(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final userName = state.user?.name ?? 'Student';
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, $userName!',
                    style: AppTheme.lightTheme.textTheme.displayLarge?.copyWith(fontSize: 24),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('EEEE, MMMM d').format(DateTime.now()),
                    style: AppTheme.lightTheme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            Row(
              children: [
                ValueListenableBuilder<int>(
                  valueListenable: _notificationService.unreadCount,
                  builder: (context, count, child) {
                    return Stack(
                      children: [
                        IconButton(
                          onPressed: () {
                            print('🔔 Bell icon tapped!');
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const NotificationsPage()),
                            ).then((_) {
                              _notificationService.checkForNewNotifications();
                            });
                          },
                          icon: const Icon(Icons.notifications_outlined, size: 28),
                        ),
                        if (count > 0)
                          Positioned(
                            right: 6,
                            top: 6,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Text(
                                count > 99 ? '99+' : '$count',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                const SizedBox(width: 12),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProfilePage()),
                    );
                  },
                  child: const CircleAvatar(
                    radius: 24,
                    backgroundColor: AppTheme.primary,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildWorkloadBrief(BuildContext context) {
    return BlocBuilder<AIBloc, AIState>(
      builder: (context, state) {
        if (state.workload == null) return const SizedBox.shrink();
        final workload = state.workload!;
        final level = workload['workloadLevel'] ?? 'LOW';
        
        return InkWell(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const AIAssistantPage()));
          },
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.bolt, color: AppTheme.primary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Workload: $level',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        workload['recommendation'] ?? 'Keep up the good work!',
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildScheduleSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Today\'s Schedule', style: AppTheme.lightTheme.textTheme.titleLarge),
            TextButton(
              onPressed: () {
                MainPage.of(context)?.setSelectedIndex(1);
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        BlocBuilder<ScheduleBloc, ScheduleState>(
          builder: (context, state) {
            return _buildAgenda(state);
          },
        ),
      ],
    );
  }

  Widget _buildAssignmentsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Pending Assignments', style: AppTheme.lightTheme.textTheme.titleLarge),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AssignmentListPage()),
                );
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        BlocBuilder<AssignmentBloc, AssignmentState>(
          builder: (context, state) {
            if (state.status == AssignmentStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            final pendingAssignments = state.assignments.where((a) => a.status.toUpperCase() == 'PENDING').toList();

            final sortedAssignments = List<Assignment>.from(pendingAssignments)
              ..sort((a, b) {
                const pMap = {'HIGH': 3, 'MEDIUM': 2, 'LOW': 1};
                final pA = pMap[a.priority.toUpperCase()] ?? 0;
                final pB = pMap[b.priority.toUpperCase()] ?? 0;
                if (pA != pB) return pB.compareTo(pA);
                return a.dueDate.compareTo(b.dueDate);
              });

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sortedAssignments.take(3).length,
              itemBuilder: (context, index) {
                final assignment = sortedAssignments[index];
                return _buildAssignmentItem(assignment);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildAgenda(ScheduleState state) {
    if (state.status == ScheduleStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.schedules.isEmpty) {
      return _buildEmptyState('Nothing scheduled for today');
    }
    
    final today = DateFormat('EEEE').format(DateTime.now());
    final todaysSchedules = state.schedules.where((s) => s.dayOfWeek == today).toList();

    if (todaysSchedules.isEmpty) {
      return _buildEmptyState('Nothing scheduled for today');
    }

    final sortedSchedules = List<Schedule>.from(todaysSchedules)
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    return Column(
      children: sortedSchedules.map((s) => _buildScheduleItem(s)).toList(),
    );
  }

  Widget _buildScheduleItem(dynamic schedule) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.class_, color: AppTheme.primary),
        ),
        title: Text(schedule.subject, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${schedule.startTime} - ${schedule.endTime}'),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.secondary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            schedule.room,
            style: const TextStyle(color: AppTheme.secondary, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildAssignmentItem(dynamic assignment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(assignment.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Due: ${DateFormat('MMM d').format(assignment.dueDate)}'),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }

  Widget _buildAISuggestionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AIAssistantPage())),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('AI Study Suggestions', style: AppTheme.lightTheme.textTheme.titleLarge),
              const Icon(Icons.auto_awesome, color: AppTheme.accent, size: 20),
            ],
          ),
        ),
        const SizedBox(height: 16),
        BlocBuilder<AIBloc, AIState>(
          builder: (context, state) {
            if (state.status == AIStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.suggestions.isEmpty) {
              return _buildEmptyState('No suggestions yet. Log your classes to see them!');
            }
            return SizedBox(
              height: 150,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: state.suggestions.length,
                itemBuilder: (context, index) {
                  final suggestion = state.suggestions[index];
                  return Container(
                    width: 200,
                    margin: const EdgeInsets.only(right: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppTheme.accent.withOpacity(0.8), AppTheme.accent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.accent.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          suggestion['day'] ?? 'Focus Time',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${suggestion['start']} - ${suggestion['end']}',
                          style: const TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                        const Spacer(),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Icon(Icons.arrow_forward_ios, color: Colors.white, size: 12),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Center(
        child: Text(message, style: const TextStyle(color: AppTheme.textSecondary)),
      ),
    );
  }

  Widget _buildAnnouncementsSection(BuildContext context) {
    print('=== _buildAnnouncementsSection called ===');
    return BlocBuilder<AnnouncementBloc, AnnouncementState>(
      builder: (context, state) {
        print('AnnouncementState status: ${state.status}');
        print('Announcements count: ${state.announcements.length}');
        
        if (state.status == AnnouncementStatus.loading && state.announcements.isEmpty) {
          print('Showing loading indicator');
          return const Center(child: CircularProgressIndicator());
        }
        
        if (state.announcements.isEmpty) {
          print('No announcements to show');
          return const SizedBox.shrink();
        }

        print('Showing ${state.announcements.length} announcements');
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Announcements',
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${state.announcements.length} Active',
                  style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 160,
              child: PageView.builder(
                controller: PageController(viewportFraction: 0.9),
                itemCount: state.announcements.length,
                itemBuilder: (context, index) {
                  final announcement = state.announcements[index];
                  return _buildAnnouncementCard(context, announcement);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAnnouncementCard(BuildContext context, Announcement announcement) {
    Color cardColor;
    IconData icon;
    switch (announcement.type.toUpperCase()) {
      case 'ALERT':
        cardColor = Colors.redAccent;
        icon = Icons.warning_amber_rounded;
        break;
      case 'EVENT':
        cardColor = Colors.blueAccent;
        icon = Icons.event;
        break;
      default:
        cardColor = AppTheme.primary;
        icon = Icons.info_outline;
    }

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AnnouncementDetailPage(announcement: announcement),
          ),
        );
      },
      borderRadius: BorderRadius.circular(24),
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: cardColor.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    announcement.source.replaceFirst('_', ' '),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 1.2,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Expires: ${DateFormat('MMM d').format(announcement.deadline)}',
                  style: const TextStyle(color: Colors.white60, fontSize: 10),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              announcement.title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              announcement.content,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
