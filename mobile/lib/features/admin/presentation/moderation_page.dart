import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/auth/presentation/auth_bloc.dart';
import 'package:mobile/injection_container.dart';
import 'package:dio/dio.dart';

class ModerationPage extends StatefulWidget {
  const ModerationPage({super.key});

  @override
  State<ModerationPage> createState() => _ModerationPageState();
}

class _ModerationPageState extends State<ModerationPage> {
  List<dynamic> _pendingReports = [];
  bool _isLoading = true;
  final Dio _dio = sl<Dio>();

  @override
  void initState() {
    super.initState();
    _loadPendingReports();
  }

  Future<void> _loadPendingReports() async {
    setState(() => _isLoading = true);
    try {
      final response = await _dio.get('/moderation/pending');
      setState(() {
        _pendingReports = response.data['reports'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Failed to load reports');
    }
  }

  Future<void> _reviewReport(String reportId, String status, String notes) async {
    try {
      await _dio.put('/moderation/review/$reportId', data: {
        'status': status,
        'reviewNotes': notes,
      });
      _loadPendingReports();
      _showSuccess('Content ${status.toLowerCase()}');
    } catch (e) {
      _showError('Failed to review');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthBloc>().state.user;
    final isAdmin = user?.isAdmin ?? false;

    if (!isAdmin) {
      return const Center(child: Text('Access Denied'));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Content Moderation'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pendingReports.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, size: 64, color: Colors.green),
                      SizedBox(height: 16),
                      Text('No pending reports'),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _pendingReports.length,
                  itemBuilder: (context, index) {
                    final report = _pendingReports[index];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Content ID: ${report['contentId']}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text('Type: ${report['contentType']}'),
                            Text('Reason: ${report['reason']}'),
                            if (report['description'] != null)
                              Text('Details: ${report['description']}'),
                            Text('Reported: ${report['createdAt']}'),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () => _reviewReport(report['id'], 'APPROVED', 'Content approved'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                    ),
                                    child: const Text('Approve'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () => _reviewReport(report['id'], 'REJECTED', 'Content rejected'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),
                                    child: const Text('Reject'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
