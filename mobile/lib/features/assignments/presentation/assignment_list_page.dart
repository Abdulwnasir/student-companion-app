import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/theme/app_theme.dart';
import '../domain/assignment_model.dart';
import '../presentation/assignment_bloc.dart';
import '../presentation/assignment_event.dart';
import '../presentation/assignment_state.dart';
import '../presentation/add_assignment_page.dart';
import '../presentation/assignment_detail_page.dart';
import '../../../core/widgets/confirmation_dialog.dart';

class AssignmentListPage extends StatefulWidget {
  const AssignmentListPage({super.key});

  @override
  State<AssignmentListPage> createState() => _AssignmentListPageState();
}

class _AssignmentListPageState extends State<AssignmentListPage> {
  String _statusFilter = 'PENDING';
  bool _showCalendar = false;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    context.read<AssignmentBloc>().add(LoadAssignments());
  }

  List<Assignment> _getEventsForDay(
    DateTime day,
    List<Assignment> assignments,
  ) {
    return assignments.where((a) => isSameDay(a.dueDate, day)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Assignments'),
        actions: [
          IconButton(
            icon: Icon(_showCalendar ? Icons.list : Icons.calendar_month),
            onPressed: () => setState(() => _showCalendar = !_showCalendar),
            tooltip: _showCalendar ? 'List View' : 'Calendar View',
          ),
        ],
      ),
      body: BlocBuilder<AssignmentBloc, AssignmentState>(
        builder: (context, state) {
          if (state.status == AssignmentStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == AssignmentStatus.error) {
            return Center(
              child: Text(state.errorMessage ?? 'Error loading tasks'),
            );
          }

          if (_showCalendar) {
            return _buildCalendarView(state.assignments);
          }

          final filteredAssignments = _statusFilter == 'ALL'
              ? state.assignments
              : state.assignments
                    .where((a) => a.status == _statusFilter)
                    .toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: ['PENDING', 'COMPLETED', 'ALL'].map((label) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(label),
                          selected: _statusFilter == label,
                          onSelected: (selected) {
                            if (selected) setState(() => _statusFilter = label);
                          },
                          selectedColor: AppTheme.primary.withOpacity(0.2),
                          labelStyle: TextStyle(
                            color: _statusFilter == label
                                ? AppTheme.primary
                                : AppTheme.textSecondary,
                            fontWeight: _statusFilter == label
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              Expanded(
                child: filteredAssignments.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(24),
                        itemCount: filteredAssignments.length,
                        itemBuilder: (context, index) {
                          final assignment = filteredAssignments[index];
                          return _buildDismissibleAssignmentCard(
                            context,
                            assignment,
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddAssignmentPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCalendarView(List<Assignment> assignments) {
    final selectedEvents = _getEventsForDay(
      _selectedDay ?? _focusedDay,
      assignments,
    );

    return Column(
      children: [
        TableCalendar(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
          onFormatChanged: (format) {
            setState(() {
              _calendarFormat = format;
            });
          },
          eventLoader: (day) => _getEventsForDay(day, assignments),
          calendarStyle: const CalendarStyle(
            selectedDecoration: BoxDecoration(
              color: AppTheme.primary,
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              color: AppTheme.accent,
              shape: BoxShape.circle,
            ),
            markerDecoration: BoxDecoration(
              color: AppTheme.secondary,
              shape: BoxShape.circle,
            ),
          ),
        ),
        const Divider(),
        Expanded(
          child: selectedEvents.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: selectedEvents.length,
                  itemBuilder: (context, index) {
                    return _buildDismissibleAssignmentCard(
                      context,
                      selectedEvents[index],
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.assignment_turned_in_outlined,
              size: 64,
              color: Colors.grey.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No assignments found',
              style: TextStyle(color: Colors.grey.withOpacity(0.8)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDismissibleAssignmentCard(
    BuildContext context,
    Assignment assignment,
  ) {
    return Dismissible(
      key: Key(assignment.id),
      direction: assignment.status == 'PENDING'
          ? DismissDirection.startToEnd
          : DismissDirection.none,
      background: Container(
        alignment: Alignment.centerLeft,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.check, color: Colors.white),
      ),
      onDismissed: (direction) {
        context.read<AssignmentBloc>().add(
          UpdateAssignmentStatus(assignment.id, 'COMPLETED'),
        );
      },
      child: _buildAssignmentCard(context, assignment),
    );
  }

  Widget _buildAssignmentCard(BuildContext context, Assignment assignment) {
    final priorityColor = _getPriorityColor(assignment.priority);
    final isOverdue =
        assignment.dueDate.isBefore(DateTime.now()) &&
        assignment.status != 'COMPLETED';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AssignmentDetailPage(assignment: assignment),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 20,
                      decoration: BoxDecoration(
                        color: priorityColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        assignment.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          decoration: assignment.status == 'COMPLETED'
                              ? TextDecoration.lineThrough
                              : null,
                          color: assignment.status == 'COMPLETED'
                              ? Colors.grey
                              : AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    _buildStatusBadge(assignment.status, isOverdue),
                  ],
                ),
                if (assignment.description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    assignment.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: isOverdue
                              ? AppTheme.error
                              : AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Due ${DateFormat('MMM dd, yyyy').format(assignment.dueDate)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isOverdue
                                ? AppTheme.error
                                : AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    if (assignment.status == 'PENDING')
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          size: 20,
                          color: Colors.grey,
                        ),
                        onPressed: () async {
                          final confirmed = await ConfirmationDialog.show(
                            context,
                            title: 'Delete Task',
                            content:
                                'Are you sure you want to permanently delete this task?',
                            confirmLabel: 'Delete',
                            isDestructive: true,
                          );
                          if (confirmed == true && mounted) {
                            context.read<AssignmentBloc>().add(
                              DeleteAssignment(assignment.id),
                            );
                          }
                        },
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status, bool isOverdue) {
    Color color = AppTheme.primary;
    String label = status;

    if (isOverdue) {
      color = AppTheme.error;
      label = 'OVERDUE';
    } else if (status == 'COMPLETED') {
      color = AppTheme.secondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toUpperCase()) {
      case 'HIGH':
        return Colors.red;
      case 'MEDIUM':
        return Colors.orange;
      case 'LOW':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
