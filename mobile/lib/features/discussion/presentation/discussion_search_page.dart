import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../domain/discussion_model.dart';
import '../presentation/discussion_bloc.dart';
import '../presentation/discussion_event.dart';
import '../presentation/discussion_state.dart';

class DiscussionSearchPage extends StatefulWidget {
  const DiscussionSearchPage({super.key});

  @override
  State<DiscussionSearchPage> createState() => _DiscussionSearchPageState();
}

class _DiscussionSearchPageState extends State<DiscussionSearchPage> {
  final _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search discussions...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white70),
          ),
          style: const TextStyle(color: Colors.white),
          onSubmitted: (query) {
            context.read<DiscussionBloc>().add(SearchDiscussions(query));
          },
        ),
      ),
      body: BlocBuilder<DiscussionBloc, DiscussionState>(
        builder: (context, state) {
          if (state.status == DiscussionStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.searchResults.isEmpty) {
            return const Center(child: Text('No messages found.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.searchResults.length,
            itemBuilder: (context, index) {
              final message = state.searchResults[index];
              return _buildSearchResultItem(message);
            },
          );
        },
      ),
    );
  }

  Widget _buildSearchResultItem(DiscussionMessage message) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(
          message.content,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          'By ${message.userName ?? "User"} on ${DateFormat('MMM d, HH:mm').format(message.createdAt)}',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // In a real app, you might want to navigate to the thread and scroll to the message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Message details available in the group thread.'),
            ),
          );
        },
      ),
    );
  }
}
