import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'ai_bloc.dart';

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
            context.read<AIBloc>().add(const LoadAIInsights());
          },
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _buildWorkloadCard(state.workload),
              const SizedBox(height: 24),
              _buildAddManualSessionButton(context),
              const SizedBox(height: 24),
              if (state.reminders != null && state.reminders!.isNotEmpty) ...[
                _buildSectionHeader('Smart Reminders'),
                const SizedBox(height: 12),
                ...state.reminders!.map((r) => _buildReminderCard(r)),
                const SizedBox(height: 24),
              ],
              if (state.studySessions != null && state.studySessions!.isNotEmpty) ...[
                _buildSectionHeader('My Study Sessions'),
                const SizedBox(height: 12),
                ...state.studySessions!.map(
                  (s) => _buildMySessionCard(s, context),
                ),
                const SizedBox(height: 24),
              ],
              _buildSectionHeader('Top Priorities'),
              const SizedBox(height: 12),
              _buildPriorityTasksSection(),
              const SizedBox(height: 24),
              _buildSectionHeader('Study Recommendations'),
              const SizedBox(height: 12),
              if (state.suggestions.isEmpty)
                const Center(child: Text('No study slots found.'))
              else
                ...state.suggestions.map(
                  (s) => _buildStudySlotCard(s),
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
        backgroundColor: const Color(0xFF2196F3),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
    );
  }

  Widget _buildPriorityTasksSection() {
    final priorityTasks = [
      {'title': 'Complete Math Assignment', 'due': 'Today', 'priority': 'HIGH', 'reason': 'Due in 5 hours'},
      {'title': 'Physics Lab Report', 'due': 'Tomorrow', 'priority': 'HIGH', 'reason': 'High priority task'},
      {'title': 'Review Notes for Quiz', 'due': 'Friday', 'priority': 'MEDIUM', 'reason': 'Prepare for upcoming quiz'},
      {'title': 'Group Project Research', 'due': 'Next Week', 'priority': 'LOW', 'reason': 'Plan ahead'},
    ];
    
    if (priorityTasks.isEmpty) {
      return const Center(child: Text('No pending tasks!'));
    }
    
    return Column(
      children: priorityTasks.map((t) => _buildPriorityCard(t)).toList(),
    );
  }

  Widget _buildWorkloadCard(Map<String, dynamic>? workload) {
    if (workload == null) return const SizedBox.shrink();

    final level = workload['workloadLevel'] ?? 'MEDIUM';
    final recommendation = workload['recommendation'] ?? 'Moderate workload. Try to complete one major task today.';
    final pendingTasks = workload['pendingTasks'] ?? 1;
    final weeklyClasses = workload['weeklyClasses'] ?? 12;

    const orangeColor = Color(0xFFFF9800);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: orangeColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: orangeColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up, color: orangeColor, size: 24),
              const SizedBox(width: 12),
              Text(
                'Workload: $level',
                style: TextStyle(
                  color: orangeColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            recommendation,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            'Based on your $pendingTasks pending tasks and $weeklyClasses weekly classes.',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderCard(Map<String, dynamic> reminder) {
    final title = reminder['title'] ?? 'Assignment Due';
    final message = reminder['message'] ?? 'Deadline is within 24 hours.';
    final priority = reminder['priority'] ?? 'HIGH';
    
    const redColor = Color(0xFFF44336);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: redColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: redColor.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(Icons.alarm, color: redColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  message,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: redColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              priority,
              style: TextStyle(
                color: redColor,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityCard(Map<String, dynamic> task) {
    final priority = task['priority'];
    Color priorityColor;
    
    switch (priority) {
      case 'HIGH':
        priorityColor = Colors.red;
        break;
      case 'MEDIUM':
        priorityColor = Colors.orange;
        break;
      default:
        priorityColor = Colors.green;
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: priorityColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: priorityColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: priorityColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              priority == 'HIGH' ? Icons.priority_high : Icons.flag,
              color: priorityColor,
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
                Text(
                  'Due: ${task['due']} • ${task['reason']}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: priorityColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              priority,
              style: TextStyle(
                color: priorityColor,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudySlotCard(Map<String, String> slot) {
    const blueColor = Color(0xFF2196F3);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: blueColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: blueColor.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: blueColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.star, color: blueColor, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${slot['day']} • ${slot['start']} - ${slot['end']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Study: ${slot['subject'] ?? 'Review'}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: blueColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.timer, size: 12, color: blueColor),
                SizedBox(width: 4),
                Text(
                  'Recommended',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMySessionCard(Map<String, dynamic> session, BuildContext context) {
    const blueColor = Color(0xFF2196F3);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: blueColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: blueColor.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: blueColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.menu_book, color: blueColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session['subject'] ?? 'Study Session',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  '${session['date'] ?? 'Today'} • ${session['duration'] ?? '1 hour'}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Study session deleted!')),
              );
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
      builder: (dialogContext) => StatefulBuilder(
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
                        subtitle: Text(startTime.format(dialogContext)),
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: dialogContext,
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
                        subtitle: Text(endTime.format(dialogContext)),
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: dialogContext,
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
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(content: Text('Added: ${titleController.text}')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
              ),
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}
