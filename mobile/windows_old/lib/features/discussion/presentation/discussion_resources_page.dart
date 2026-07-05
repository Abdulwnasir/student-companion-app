import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/discussion/presentation/discussion_bloc.dart';
import 'package:mobile/features/discussion/presentation/discussion_event.dart';
import 'package:mobile/features/discussion/presentation/discussion_state.dart';

class DiscussionResourcesPage extends StatefulWidget {
  final String groupId;

  const DiscussionResourcesPage({super.key, required this.groupId});

  @override
  State<DiscussionResourcesPage> createState() =>
      _DiscussionResourcesPageState();
}

class _DiscussionResourcesPageState extends State<DiscussionResourcesPage> {
  @override
  void initState() {
    super.initState();
    context.read<DiscussionBloc>().add(LoadGroupResources(widget.groupId));
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not launch $url')));
    }
  }

  void _showAddResourceDialog() {
    final titleController = TextEditingController();
    final linkController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Resource'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'e.g. Course Syllabus',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: linkController,
              decoration: const InputDecoration(
                labelText: 'Link',
                hintText: 'https://...',
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
              if (titleController.text.isNotEmpty &&
                  linkController.text.isNotEmpty) {
                context.read<DiscussionBloc>().add(
                  AddGroupResource(
                    widget.groupId,
                    titleController.text,
                    linkController.text,
                  ),
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resources'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'resources_fab',
        onPressed: _showAddResourceDialog,
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.add),
      ),
      body: BlocBuilder<DiscussionBloc, DiscussionState>(
        builder: (context, state) {
          if (state.status == DiscussionStatus.loading &&
              state.resources.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.resources.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.folder_open, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No resources yet',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.resources.length,
            itemBuilder: (context, index) {
              final resource = state.resources[index];
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.link, color: AppTheme.primary),
                  ),
                  title: Text(
                    resource.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    resource.link,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.blue),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.grey),
                    onPressed: () {
                      // Confirm deletion
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete Resource?'),
                          content: const Text(
                            'Are you sure you want to remove this resource?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                context.read<DiscussionBloc>().add(
                                  DeleteGroupResource(
                                    resource.id,
                                    widget.groupId,
                                  ),
                                );
                                Navigator.pop(context);
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  onTap: () => _launchUrl(resource.link),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
