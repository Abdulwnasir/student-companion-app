import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class SimpleForum extends StatefulWidget {
  const SimpleForum({super.key});

  @override
  _SimpleForumState createState() => _SimpleForumState();
}

class _SimpleForumState extends State<SimpleForum> {
  List<dynamic> posts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPosts();
  }

  Future<void> fetchPosts() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');
      
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/forum/posts'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          posts = data['posts'] ?? [];
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> submitReport(String postId, String content, String reason) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');
      
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/moderation/report'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'contentId': postId,
          'contentType': 'POST',
          'content': content,
          'reason': reason,
          'description': 'Reported from mobile app',
        }),
      );
      
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Report submitted!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void showReportDialog(String postId, String content) {
    String? selectedReason;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Report Post'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Why are you reporting this?'),
            SizedBox(height: 10),
            ...['SPAM', 'HARASSMENT', 'INAPPROPRIATE', 'OTHER'].map((reason) => RadioListTile(
              title: Text(reason.toLowerCase()),
              value: reason,
              groupValue: selectedReason,
              onChanged: (value) {
                selectedReason = value as String?;
                Navigator.pop(context);
                submitReport(postId, content, selectedReason ?? 'OTHER');
              },
            )),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Forum'), backgroundColor: Colors.blue),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                return Card(
                  margin: EdgeInsets.all(8),
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              child: Text(post['user']?['name']?[0] ?? 'U'),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    post['user']?['name'] ?? 'Unknown',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    post['createdAt']?.substring(0, 10) ?? '',
                                    style: TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                            // REPORT BUTTON - THREE DOTS
                            PopupMenuButton(
                              icon: Icon(Icons.more_vert),
                              onSelected: (value) {
                                if (value == 'report') {
                                  showReportDialog(post['id'], post['content'] ?? '');
                                }
                              },
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 'report',
                                  child: Row(
                                    children: [
                                      Icon(Icons.flag, color: Colors.red),
                                      SizedBox(width: 8),
                                      Text('Report', style: TextStyle(color: Colors.red)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Text(post['content'] ?? 'No content'),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
