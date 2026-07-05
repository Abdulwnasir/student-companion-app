import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/custom_text_field.dart';
import '../presentation/assignment_bloc.dart';
import '../presentation/assignment_event.dart';
import '../presentation/assignment_state.dart';

class AddAssignmentPage extends StatefulWidget {
  const AddAssignmentPage({super.key});

  @override
  State<AddAssignmentPage> createState() => _AddAssignmentPageState();
}

class _AddAssignmentPageState extends State<AddAssignmentPage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dueDateController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _selectedPriority = 'MEDIUM';
  String _selectedStatus = 'PENDING';
  int _reminderMinutes = 30;

  final List<String> _priorities = ['LOW', 'MEDIUM', 'HIGH'];
  final List<String> _statuses = ['PENDING', 'COMPLETED', 'DISCARDED'];
  final List<int> _reminderOptions = [10, 30, 60, 1440];

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dueDateController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() => _selectedTime = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Task'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: BlocListener<AssignmentBloc, AssignmentState>(
        listener: (context, state) {
          if (state.status == AssignmentStatus.success) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Task added successfully!')),
            );
          } else if (state.status == AssignmentStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Failed to add task'),
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextField(
                  label: 'Task Title',
                  hint: 'Homework, Project, etc.',
                  controller: _titleController,
                  validator: (v) =>
                      v != null && v.isNotEmpty ? null : 'Enter title',
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Description',
                  hint: 'Optional details...',
                  controller: _descriptionController,
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _selectedPriority,
                  decoration: const InputDecoration(
                    labelText: 'Priority',
                    border: OutlineInputBorder(),
                  ),
                  items: _priorities
                      .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedPriority = val!),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: AbsorbPointer(
                    child: CustomTextField(
                      label: 'Due Date',
                      hint: 'YYYY-MM-DD',
                      controller: _dueDateController,
                      prefixIcon: Icons.calendar_today,
                      validator: (v) =>
                          v != null && v.isNotEmpty ? null : 'Select due date',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.access_time),
                  title: const Text('Due Time'),
                  subtitle: Text(_selectedTime?.format(context) ?? 'Not set'),
                  onTap: () => _selectTime(context),
                  trailing: const Icon(Icons.chevron_right),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  initialValue: _reminderMinutes,
                  decoration: const InputDecoration(
                    labelText: 'Reminder (before due)',
                  ),
                  items: _reminderOptions.map((m) {
                    String label = m < 60
                        ? '$m minutes'
                        : (m == 60 ? '1 hour' : '1 day');
                    return DropdownMenuItem(value: m, child: Text(label));
                  }).toList(),
                  onChanged: (val) => setState(() => _reminderMinutes = val!),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Initial Status',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                // Status chips on the same line - original colors
                Row(
                  children: _statuses.asMap().entries.map((entry) {
                    final index = entry.key;
                    final status = entry.value;
                    final isSelected = _selectedStatus == status;
                    
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: index == 0 ? 0 : 4,
                          right: index == _statuses.length - 1 ? 0 : 4,
                        ),
                        child: ChoiceChip(
                          label: Text(status),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _selectedStatus = status);
                            }
                          },
                          selectedColor: Colors.blue,
                          backgroundColor: Colors.grey.shade200,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),
                BlocBuilder<AssignmentBloc, AssignmentState>(
                  builder: (context, state) {
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: state.status == AssignmentStatus.loading
                            ? null
                            : () {
                                if (_formKey.currentState!.validate()) {
                                  context.read<AssignmentBloc>().add(
                                    CreateAssignment({
                                      'title': _titleController.text,
                                      'description': _descriptionController.text,
                                      'deadline': _selectedDate
                                          ?.toUtc()
                                          .toIso8601String(),
                                      'dueTime': _selectedTime != null
                                          ? '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
                                          : null,
                                      'reminderTime': _reminderMinutes,
                                      'status': _selectedStatus,
                                      'priority': _selectedPriority,
                                    }),
                                  );
                                }
                              },
                        child: state.status == AssignmentStatus.loading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Add Task'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
