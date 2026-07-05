import 'package:flutter/material.dart';
import '../widgets/post_card.dart';  // Add this import

class ForumScreen extends StatefulWidget {
  const ForumScreen({super.key});

  @override
  _ForumScreenState createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen> {
  List<Map<String, dynamic>> posts = []; // Your posts data
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPosts();
  }

  Future<void> fetchPosts() async {
    // Your existing code to fetch posts
    // Example:
    // final response = await http.get(...);
    // setState(() { posts = data; isLoading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Forum Discussions'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                return PostCard(
                  post: posts[index],
                  onReported: () {
                    // Show success message when report is submitted
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Thank you for reporting this content'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
