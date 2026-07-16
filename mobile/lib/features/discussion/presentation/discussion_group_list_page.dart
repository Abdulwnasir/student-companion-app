import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../core/theme/app_theme.dart';
import '../domain/discussion_model.dart';
import 'discussion_bloc.dart';
import 'discussion_event.dart';
import 'discussion_state.dart';
import 'discussion_search_page.dart';
import 'discussion_thread_page.dart';
import 'package:mobile/core/network/api_config.dart';
import '../../auth/presentation/login_page.dart'; // Add this import

class DiscussionGroupListPage extends StatefulWidget {
  const DiscussionGroupListPage({super.key});

  @override
  State<DiscussionGroupListPage> createState() =>
      _DiscussionGroupListPageState();
}

class _DiscussionGroupListPageState extends State<DiscussionGroupListPage> {
  @override
  void initState() {
    super.initState();
    context.read<DiscussionBloc>().add(LoadGroups());
    _checkLoginStatus(); // Check login status when page loads
  }

  // Add this method to check login status
  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    
    if (token == null) {
      // Show login dialog after a short delay
      Future.delayed(const Duration(milliseconds: 500), () {
        _showLoginRequiredDialog();
      });
    } else {
      _showSnackBar('✅ Welcome back! You are logged in', Colors.green);
    }
  }

  // Show login required dialog
  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 10),
            Text('Login Required'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('You need to login before you can report content.'),
            SizedBox(height: 10),
            Text(
              'Use these test credentials:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text('Email: student@university.edu'),
            Text('Password: Student123'),
            SizedBox(height: 5),
            Text('OR'),
            SizedBox(height: 5),
            Text('Email: admin@university.edu'),
            Text('Password: Admin123'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to login page
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );
            },
            child: const Text('Go to Login'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discussions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DiscussionSearchPage()),
              );
            },
          ),
          // ADD LOGIN STATUS CHECK BUTTON
          IconButton(
            icon: const Icon(Icons.verified_user, color: Colors.white),
            onPressed: _checkLoginStatus,
            tooltip: 'Check Login Status',
          ),
          // ADD REPORT TEST BUTTON IN APP BAR
          IconButton(
            icon: const Icon(Icons.flag, color: Colors.white),
            onPressed: () {
              _showTestReportDialog();
            },
            tooltip: 'Test Report',
          ),
        ],
      ),
      body: BlocBuilder<DiscussionBloc, DiscussionState>(
        builder: (context, state) {
          if (state.status == DiscussionStatus.loading &&
              state.groups.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.groups.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: state.groups.length,
            itemBuilder: (context, index) {
              final DiscussionGroup group = state.groups[index];
              return _buildGroupCard(context, group);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateGroupDialog(context),
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.forum_outlined,
            size: 64,
            color: AppTheme.primary.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          const Text(
            'No discussion groups yet.\nCreate one to start collaborating!',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _checkLoginStatus,
            icon: const Icon(Icons.login),
            label: const Text('Check Login Status'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupCard(BuildContext context, DiscussionGroup group) {
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
                builder: (_) => DiscussionThreadPage(group: group),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              group.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          // ADD REPORT BUTTON (Three dots menu)
                          PopupMenuButton(
                            icon: const Icon(Icons.more_vert, size: 20, color: Colors.grey),
                            onSelected: (value) {
                              if (value == 'report') {
                                _showReportGroupDialog(group);
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'report',
                                child: Row(
                                  children: [
                                    Icon(Icons.flag, color: Colors.red, size: 20),
                                    SizedBox(width: 8),
                                    Text('Report Group', style: TextStyle(color: Colors.red)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (group.description != null)
                        Text(
                          group.description!,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      if (group.scope != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withOpacity(0.03),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppTheme.primary.withOpacity(0.05),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'TARGET SCOPE',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                ..._buildHierarchyItems(group),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildHierarchyItems(DiscussionGroup group) {
    if (group.scope == 'UNIVERSITY') {
      return [
        _buildContextRow(
          Icons.public,
          'University',
          'University Wide',
          Colors.blue,
        ),
      ];
    }

    final scopeLabel = group.scope == 'DEPARTMENT'
        ? 'Department'
        : group.scope == 'BATCH'
        ? 'Batch'
        : group.scope == 'SECTION'
        ? 'Section'
        : 'Target';
    final icon = group.scope == 'DEPARTMENT'
        ? Icons.business
        : group.scope == 'BATCH'
        ? Icons.calendar_today
        : group.scope == 'SECTION'
        ? Icons.people
        : Icons.place;
    final color = group.scope == 'DEPARTMENT'
        ? Colors.indigo
        : group.scope == 'BATCH'
        ? Colors.amber[700]!
        : group.scope == 'SECTION'
        ? Colors.teal
        : Colors.grey;

    return [
      _buildContextRow(icon, scopeLabel, group.targetId ?? 'Unknown', color),
    ];
  }

  Widget _buildContextRow(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 11,
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.normal,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // REPORTING METHODS

  void _showTestReportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.flag, color: Colors.red),
            SizedBox(width: 10),
            Text('Test Report'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select a reason to test the report feature:'),
            const SizedBox(height: 10),
            ...['SPAM', 'HARASSMENT', 'INAPPROPRIATE', 'OTHER'].map((reason) => 
              ListTile(
                leading: const Icon(Icons.warning, color: Colors.orange),
                title: Text(reason.toLowerCase()),
                onTap: () {
                  Navigator.pop(context);
                  _submitReport('test-group-001', 'Test Discussion Group', reason);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReportGroupDialog(DiscussionGroup group) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.flag, color: Colors.red),
            SizedBox(width: 10),
            Text('Report Discussion Group'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Report: ${group.name}'),
            const SizedBox(height: 10),
            const Text('Why are you reporting this group?'),
            const SizedBox(height: 10),
            ...['SPAM', 'HARASSMENT', 'INAPPROPRIATE', 'MISINFORMATION', 'OTHER'].map((reason) => 
              ListTile(
                leading: const Icon(Icons.warning, color: Colors.orange),
                title: Text(reason.toLowerCase()),
                onTap: () {
                  Navigator.pop(context);
                  _submitReport(group.id, group.name, reason);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitReport(String contentId, String content, String reason) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');
      
      // If no token, try to get one from stored credentials or show login
      if (token == null) {
        _showSnackBar('❌ Not logged in! Please login first', Colors.orange);
        _showLoginRequiredDialog();
        return;
      }
      
      _showSnackBar('📤 Submitting report...', Colors.blue);
      
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/moderation/report'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'contentId': contentId,
          'contentType': 'DISCUSSION_GROUP',
          'content': content,
          'reason': reason,
          'description': 'Reported from mobile app - Discussion Group',
        }),
      );
      
      print('Report Response Status: ${response.statusCode}');
      print('Report Response Body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          _showSnackBar('✅ Report submitted successfully!', Colors.green);
        } else {
          _showSnackBar('❌ Failed: ${data['message']}', Colors.red);
        }
      } else if (response.statusCode == 401) {
        _showSnackBar('❌ Session expired. Please login again.', Colors.orange);
        _showLoginRequiredDialog();
      } else {
        _showSnackBar('❌ Error: ${response.statusCode}', Colors.red);
      }
    } catch (e) {
      print('Error submitting report: $e');
      _showSnackBar('❌ Network Error: Make sure backend is running at 192.168.137.102:3000', Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _showCreateGroupDialog(BuildContext context) async {
    final nameController = TextEditingController();
    final descController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Group'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Group Name'),
            ),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                context.read<DiscussionBloc>().add(
                  CreateGroup(nameController.text, descController.text),
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
