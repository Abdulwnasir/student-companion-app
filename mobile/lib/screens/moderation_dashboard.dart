import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class ModerationDashboard extends StatefulWidget {
  const ModerationDashboard({super.key});

  @override
  State<ModerationDashboard> createState() => _ModerationDashboardState();
}

class _ModerationDashboardState extends State<ModerationDashboard> {
  List<dynamic> pendingReports = [];
  bool isLoading = true;
  Map<String, dynamic> stats = {};

  @override
  void initState() {
    super.initState();
    fetchPendingReports();
    fetchStats();
  }

  Future<void> fetchPendingReports() async {
    setState(() {
      isLoading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      if (token == null) {
        _showError('Please login as admin');
        return;
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/moderation/pending'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['success'] == true) {
        setState(() {
          pendingReports = data['requests'];
          isLoading = false;
        });
      } else {
        _showError(data['message'] ?? 'Failed to load reports');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      _showError('Network error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchStats() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/moderation/stats'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['success'] == true) {
        setState(() {
          stats = data['stats'];
        });
      }
    } catch (e) {
      print('Error fetching stats: $e');
    }
  }

  Future<void> reviewReport(String requestId, String action, String reviewNotes) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/moderation/review'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'requestId': requestId,
          'action': action,
          'reviewNotes': reviewNotes,
        }),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['success'] == true) {
        _showSuccess('Report ${action.toLowerCase()}d successfully');
        fetchPendingReports();
        fetchStats();
      } else {
        _showError(data['message'] ?? 'Failed to review report');
      }
    } catch (e) {
      _showError('Network error: $e');
    }
  }

  void _showApproveDialog(String requestId) {
    TextEditingController notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Approve Report'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('This will DELETE the content. Add review notes:'),
              const SizedBox(height: 10),
              TextField(
                controller: notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Reason for approval...',
                ),
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
                Navigator.pop(context);
                reviewReport(requestId, 'APPROVE', notesController.text);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Approve & Delete'),
            ),
          ],
        );
      },
    );
  }

  void _showRejectDialog(String requestId) {
    TextEditingController notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reject Report'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('This will KEEP the content. Add review notes:'),
              const SizedBox(height: 10),
              TextField(
                controller: notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Reason for rejection...',
                ),
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
                Navigator.pop(context);
                reviewReport(requestId, 'REJECT', notesController.text);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Reject & Keep'),
            ),
          ],
        );
      },
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Moderation Dashboard'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.pending_actions), text: 'Pending'),
              Tab(icon: Icon(Icons.bar_chart), text: 'Statistics'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : pendingReports.isEmpty
                    ? const Center(child: Text('No pending reports'))
                    : ListView.builder(
                        itemCount: pendingReports.length,
                        itemBuilder: (context, index) {
                          final report = pendingReports[index];
                          return Card(
                            margin: const EdgeInsets.all(8),
                            child: ExpansionTile(
                              title: Text('Report #${report['id'].substring(0, 8)}'),
                              subtitle: Text('Reason: ${report['reason']}'),
                              leading: const Icon(Icons.report, color: Colors.orange),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Content Type: ${report['contentType']}'),
                                      const SizedBox(height: 8),
                                      Text('Content:', style: TextStyle(fontWeight: FontWeight.bold)),
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        margin: const EdgeInsets.only(top: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(report['content'] ?? 'No content'),
                                      ),
                                      const SizedBox(height: 8),
                                      Text('Reported by: ${report['reporter']['name']}'),
                                      Text('Email: ${report['reporter']['email']}'),
                                      const SizedBox(height: 8),
                                      Text('Description: ${report['description']}'),
                                      const SizedBox(height: 16),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: ElevatedButton(
                                              onPressed: () => _showApproveDialog(report['id']),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red,
                                              ),
                                              child: const Text('APPROVE (Delete)'),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: ElevatedButton(
                                              onPressed: () => _showRejectDialog(report['id']),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.green,
                                              ),
                                              child: const Text('REJECT (Keep)'),
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
                        },
                      ),
            stats.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                const Text('Moderation Statistics', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                const Divider(),
                                _buildStatRow('Total Reports', stats['total']?.toString() ?? '0', Colors.blue),
                                _buildStatRow('Pending', stats['pending']?.toString() ?? '0', Colors.orange),
                                _buildStatRow('Approved (Deleted)', stats['approved']?.toString() ?? '0', Colors.red),
                                _buildStatRow('Rejected (Kept)', stats['rejected']?.toString() ?? '0', Colors.green),
                                _buildStatRow("Today's Reports", stats['todayReports']?.toString() ?? '0', Colors.purple),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                const Text('Reports by Type', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                const Divider(),
                                _buildStatRow('Messages', stats['byType']?['messages']?.toString() ?? '0', Colors.teal),
                                _buildStatRow('Comments', stats['byType']?['comments']?.toString() ?? '0', Colors.teal),
                                _buildStatRow('Announcements', stats['byType']?['announcements']?.toString() ?? '0', Colors.teal),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            fetchPendingReports();
            fetchStats();
          },
          child: const Icon(Icons.refresh),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
