import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/auth/presentation/auth_bloc.dart';
import 'package:mobile/features/auth/presentation/auth_event.dart';
import 'package:mobile/features/auth/presentation/auth_state.dart';
import 'package:mobile/core/theme/theme_cubit.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String? _reminderFrequency;
  int? _classReminderTime;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthBloc>().state.user;
    _reminderFrequency = user?.reminderFrequency ?? 'DAILY';
    _classReminderTime = user?.classReminderTime ?? 30;
  }

  void _saveSettings() {
    context.read<AuthBloc>().add(
      UpdateUserSettings({
        'reminderFrequency': _reminderFrequency,
        'classReminderTime': _classReminderTime,
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.authenticated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Settings saved successfully!')),
            );
          } else if (state.status == AuthStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Failed to save settings'),
              ),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('Reminders'),
                const SizedBox(height: 16),
                _buildFrequencyDropdown(),
                const SizedBox(height: 24),
                _buildClassReminderDropdown(),
                const SizedBox(height: 24),
                _buildThemeSection(),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: state.status == AuthStatus.loading
                        ? null
                        : _saveSettings,
                    child: state.status == AuthStatus.loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Save Preferences'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppTheme.primary,
      ),
    );
  }

  Widget _buildFrequencyDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Task Reminder Frequency',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _reminderFrequency,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 16),
          ),
          items: const [
            DropdownMenuItem(value: 'DAILY', child: Text('Daily')),
            DropdownMenuItem(value: 'WEEKLY', child: Text('Weekly')),
            DropdownMenuItem(
              value: 'TWICE_WEEKLY',
              child: Text('Twice a Week'),
            ),
            DropdownMenuItem(value: 'NONE', child: Text('None')),
          ],
          onChanged: (val) => setState(() => _reminderFrequency = val),
        ),
      ],
    );
  }

  Widget _buildClassReminderDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Class Reminder (minutes before)',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          initialValue: _classReminderTime,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 16),
          ),
          items: const [
            DropdownMenuItem(value: 10, child: Text('10 minutes')),
            DropdownMenuItem(value: 30, child: Text('30 minutes')),
            DropdownMenuItem(value: 60, child: Text('1 hour')),
          ],
          onChanged: (val) => setState(() => _classReminderTime = val),
        ),
      ],
    );
  }

  Widget _buildThemeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Appearance'),
        const SizedBox(height: 16),
        BlocBuilder<ThemeCubit, ThemeState>(
          builder: (context, themeState) {
            final isDark = themeState.themeMode == ThemeMode.dark;
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).dividerColor.withOpacity(0.1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        isDark ? Icons.dark_mode : Icons.light_mode,
                        color: AppTheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Theme',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                    ],
                  ),
                  Switch(
                    value: isDark,
                    onChanged: (value) {
                      context.read<ThemeCubit>().toggleTheme();
                    },
                    activeThumbColor: AppTheme.primary,
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
