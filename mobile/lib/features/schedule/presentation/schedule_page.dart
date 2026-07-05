import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/theme/app_theme.dart';
import '../domain/schedule_model.dart';
import 'schedule_bloc.dart';
import 'schedule_event.dart';
import 'schedule_state.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  bool _isCalendarView = false;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    print('=== SCHEDULE PAGE INIT - Loading schedules ===');
    context.read<ScheduleBloc>().add(LoadSchedule());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Schedule'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_isCalendarView ? Icons.list : Icons.calendar_today),
            onPressed: () {
              setState(() {
                _isCalendarView = !_isCalendarView;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<ScheduleBloc>().add(LoadSchedule());
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Refreshing schedule...')),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<ScheduleBloc, ScheduleState>(
        builder: (context, state) {
          print('📅 ScheduleBloc status: ${state.status}');
          print('📅 Number of schedules: ${state.schedules.length}');

          if (state.status == ScheduleStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == ScheduleStatus.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.errorMessage ?? 'Error loading schedule'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ScheduleBloc>().add(LoadSchedule());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state.schedules.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text('No classes scheduled'),
                  const SizedBox(height: 8),
                  Text(
                    'Your schedule will appear here',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return _isCalendarView
              ? _buildCalendarView(state.schedules)
              : _buildListView(state.schedules);
        },
      ),
    );
  }

  Widget _buildCalendarView(List<Schedule> schedules) {
    // Group schedules by date
    final Map<DateTime, List<Schedule>> schedulesByDate = {};
    final now = DateTime.now();

    for (var schedule in schedules) {
      // Convert day of week to actual dates (next 7 days)
      final dayIndex = [
        'Sunday',
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
      ].indexOf(schedule.dayOfWeek);
      if (dayIndex != -1) {
        final daysUntilNext = (dayIndex - now.weekday + 7) % 7;
        final scheduleDate = now.add(
          Duration(days: daysUntilNext == 0 ? 7 : daysUntilNext),
        );

        final dateKey = DateTime(
          scheduleDate.year,
          scheduleDate.month,
          scheduleDate.day,
        );
        if (!schedulesByDate.containsKey(dateKey)) {
          schedulesByDate[dateKey] = [];
        }
        schedulesByDate[dateKey]!.add(schedule);
      }
    }

    return Column(
      children: [
        TableCalendar(
          firstDay: DateTime.now(),
          lastDay: DateTime.now().add(const Duration(days: 30)),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
          calendarStyle: CalendarStyle(
            selectedDecoration: BoxDecoration(
              color: AppTheme.primary,
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            markerDecoration: BoxDecoration(
              color: AppTheme.accent,
              shape: BoxShape.circle,
            ),
          ),
          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            titleTextStyle: TextStyle(
              color: AppTheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          eventLoader: (day) {
            final dateKey = DateTime(day.year, day.month, day.day);
            return schedulesByDate[dateKey] ?? [];
          },
        ),
        const Divider(),
        Expanded(
          child: _selectedDay == null
              ? Center(
                  child: Text(
                    'Select a date to view classes',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                )
              : _buildDaySchedule(
                  schedulesByDate[DateTime(
                        _selectedDay!.year,
                        _selectedDay!.month,
                        _selectedDay!.day,
                      )] ??
                      [],
                ),
        ),
      ],
    );
  }

  Widget _buildDaySchedule(List<Schedule> daySchedules) {
    if (daySchedules.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_note, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No classes on this day',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ],
        ),
      );
    }

    // Sort by start time
    daySchedules.sort((a, b) => a.startTime.compareTo(b.startTime));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: daySchedules.length,
      itemBuilder: (context, index) {
        final schedule = daySchedules[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppTheme.primary.withOpacity(0.1),
              child: const Icon(Icons.book, color: AppTheme.primary),
            ),
            title: Text(
              schedule.subject,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '${schedule.startTime} - ${schedule.endTime}${schedule.room.isNotEmpty ? ' • ${schedule.room}' : ''}',
            ),
            trailing: schedule.reminderEnabled
                ? const Icon(Icons.notifications_active, color: AppTheme.accent)
                : null,
          ),
        );
      },
    );
  }

  Widget _buildListView(List<Schedule> schedules) {
    // Group schedules by day
    final Map<String, List<Schedule>> schedulesByDay = {};
    for (var schedule in schedules) {
      if (!schedulesByDay.containsKey(schedule.dayOfWeek)) {
        schedulesByDay[schedule.dayOfWeek] = [];
      }
      schedulesByDay[schedule.dayOfWeek]!.add(schedule);
    }

    // Order of days
    const dayOrder = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: dayOrder.length,
      itemBuilder: (context, index) {
        final day = dayOrder[index];
        final daySchedules = schedulesByDay[day] ?? [];

        if (daySchedules.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 16, bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                day,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            ...daySchedules.map(
              (schedule) => Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.primary.withOpacity(0.1),
                    child: const Icon(Icons.book, color: AppTheme.primary),
                  ),
                  title: Text(
                    schedule.subject,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${schedule.startTime} - ${schedule.endTime}${schedule.room.isNotEmpty ? ' • ${schedule.room}' : ''}',
                  ),
                  trailing: schedule.reminderEnabled
                      ? const Icon(
                          Icons.notifications_active,
                          color: AppTheme.accent,
                        )
                      : null,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
