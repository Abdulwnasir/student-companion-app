import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../presentation/ai_bloc.dart';
import '../presentation/ai_event.dart';
import '../presentation/ai_state.dart';
import '../domain/study_session_model.dart';

class AIInsightsPage extends StatelessWidget {
  const AIInsightsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AIBloc, AIState>(
      builder: (context, state) {
        if (state.status == AIStatus.loading && state.workload == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () async {
            context.read<AIBloc>().add(LoadAIInsights());
          },
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _buildWorkloadCard(context, state.workload),
              const SizedBox(height: 24),
              _buildAddManualSessionButton(context),
              const SizedBox(height: 24),
              if (state.reminders.isNotEmpty) ...[
                _buildSectionHeader('Smart Reminders'),
                const SizedBox(height: 12),
                ...state.reminders.map((r) => _buildReminderCard(context, r)),
                const SizedBox(height: 24),
              ],
              if (state.studySessions.isNotEmpty) ...[
                _buildSectionHeader('My Study Sessions'),
                const SizedBox(height: 12),
                ...state.studySessions.map(
                  (s) => _buildMySessionCard(context, s),
                ),
                const SizedBox(height: 24),
              ],
              _buildSectionHeader('Top Priorities'),
              const SizedBox(height: 12),
              if (state.prioritizedTasks.isEmpty)
                const Center(child: Text('No pending tasks!'))
              else
                ...state.prioritizedTasks.map(
                  (t) => _buildPriorityCard(context, t),
                ),
              const SizedBox(height: 24),
              _buildSectionHeader('Study Recommendations'),
              const SizedBox(height: 12),
              if (state.suggestions.isEmpty)
                const Center(child: Text('No study slots found.'))
              else
                ...state.suggestions.map(
                  (s) => _buildStudySlotCard(context, s),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAddManualSessionButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => _showManualSessionDialog(context),
      icon: const Icon(Icons.add_circle_outline),
      label: const Text('Add Manual Study Session'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
    );
  }

  Widget _buildWorkloadCard(
    BuildContext context,
    Map<String, dynamic>? workload,
  ) {
    if (workload == null) return const SizedBox.shrink();

    final level = workload['workloadLevel'] ?? 'LOW';
    final recommendation = workload['recommendation'] ?? '';
    final reasoning = workload['reasoning'] ?? '';

    Color color;
    IconData icon;
    switch (level) {
      case 'CRITICAL':
        color = Colors.red;
        icon = Icons.warning_amber_rounded;
        break;
      case 'MEDIUM':
        color = Colors.orange;
        icon = Icons.info_outline;
        break;
      default:
        color = Colors.green;
        icon = Icons.check_circle_outline;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 12),
              Text(
                'Workload: $level',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            recommendation,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 8),
          Text(
            reasoning,
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderCard(BuildContext context, dynamic reminder) {
    final urgency = reminder['urgency'];
    final color = urgency == 'OVERDUE' ? Colors.red : Colors.orange;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(Icons.notifications_active_outlined, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reminder['message'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  reminder['reasoning'],
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityCard(BuildContext context, dynamic task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.star_outline,
              color: AppTheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task['title'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.lightbulb_outline,
                      size: 12,
                      color: AppTheme.accent,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      task['reasoning'],
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudySlotCard(BuildContext context, dynamic slot) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '${slot['day']} - ${slot['type']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${slot['start']} - ${slot['end']}',
                style: const TextStyle(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Focus on: ${slot['subject']}',
                      style: const TextStyle(fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      slot['reasoning'],
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_task, color: AppTheme.primary),
                onPressed: () {
                  context.read<AIBloc>().add(
                    AddStudySession(
                      subject: slot['subject'],
                      dayOfWeek: slot['day'],
                      startTime: slot['start'],
                      endTime: slot['end'],
                      type: 'SUGGESTED',
                    ),
                  );
                },
                tooltip: 'Add to My Sessions',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMySessionCard(BuildContext context, StudySession session) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primary.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.menu_book,
              color: AppTheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.subject,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  '${session.dayOfWeek} • ${session.startTime} - ${session.endTime}',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
            onPressed: () {
              context.read<AIBloc>().add(DeleteStudySession(session.id));
            },
          ),
        ],
      ),
    );
  }

  void _showManualSessionDialog(BuildContext context) {
    final titleController = TextEditingController();
    String selectedDay = DateFormat('EEEE').format(DateTime.now());
    TimeOfDay startTime = const TimeOfDay(hour: 9, minute: 0);
    TimeOfDay endTime = const TimeOfDay(hour: 11, minute: 0);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Study Session'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Subject/Topic',
                    hintText: 'e.g., Math Finals Review',
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: selectedDay,
                  decoration: const InputDecoration(labelText: 'Day'),
                  items:
                      [
                            "Monday",
                            "Tuesday",
                            "Wednesday",
                            "Thursday",
                            "Friday",
                            "Saturday",
                            "Sunday",
                          ]
                          .map(
                            (d) => DropdownMenuItem(value: d, child: Text(d)),
                          )
                          .toList(),
                  onChanged: (v) => setDialogState(() => selectedDay = v!),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        title: const Text('Start'),
                        subtitle: Text(startTime.format(context)),
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: startTime,
                          );
                          if (picked != null) {
                            setDialogState(() => startTime = picked);
                          }
                        },
                      ),
                    ),
                    Expanded(
                      child: ListTile(
                        title: const Text('End'),
                        subtitle: Text(endTime.format(context)),
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: endTime,
                          );
                          if (picked != null) {
                            setDialogState(() => endTime = picked);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  final startStr =
                      '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
                  final endStr =
                      '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';

                  context.read<AIBloc>().add(
                    AddStudySession(
                      subject: titleController.text,
                      dayOfWeek: selectedDay,
                      startTime: startStr,
                      endTime: endStr,
                    ),
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}
