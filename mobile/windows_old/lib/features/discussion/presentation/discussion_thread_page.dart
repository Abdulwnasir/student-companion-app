import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:dio/dio.dart' as dio_lib;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../core/theme/app_theme.dart';
import '../domain/discussion_model.dart';
import '../presentation/discussion_bloc.dart';
import '../presentation/discussion_event.dart';
import '../presentation/discussion_state.dart';
import '../presentation/discussion_resources_page.dart';
import '../../../injection_container.dart';

class DiscussionThreadPage extends StatefulWidget {
  final DiscussionGroup group;

  const DiscussionThreadPage({super.key, required this.group});

  @override
  State<DiscussionThreadPage> createState() => _DiscussionThreadPageState();
}

class _DiscussionThreadPageState extends State<DiscussionThreadPage> {
  final _messageController = TextEditingController();
  File? _selectedFile;

  @override
  void initState() {
    super.initState();
    context.read<DiscussionBloc>().add(LoadMessages(widget.group.id));
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty || _selectedFile != null) {
      context.read<DiscussionBloc>().add(
        PostMessage(widget.group.id, _messageController.text, _selectedFile),
      );
      _messageController.clear();
      setState(() {
        _selectedFile = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.group.name),
            Text(
              widget.group.description ?? "",
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'resources') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        DiscussionResourcesPage(groupId: widget.group.id),
                  ),
                );
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'resources',
                  child: Row(
                    children: [
                      Icon(Icons.folder_shared, color: AppTheme.primary),
                      SizedBox(width: 8),
                      Text('Resources'),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<DiscussionBloc, DiscussionState>(
              builder: (context, state) {
                if (state.status == DiscussionStatus.loading &&
                    state.currentMessages.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  reverse: false,
                  itemCount: state.currentMessages.length,
                  itemBuilder: (context, index) {
                    final message = state.currentMessages[index];
                    return _buildMessageItem(message);
                  },
                );
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageItem(DiscussionMessage message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppTheme.primary.withOpacity(0.1),
                child: Text(
                  message.userName?.substring(0, 1).toUpperCase() ?? 'U',
                  style: const TextStyle(
                    color: AppTheme.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                message.userName ?? 'User',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                DateFormat('HH:mm').format(message.createdAt),
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(message.content, style: const TextStyle(fontSize: 15)),
                if (message.fileUrl != null) ...[
                  const SizedBox(height: 12),
                  _buildFileAttachment(message.fileUrl!),
                ],
              ],
            ),
          ),
          if (message.comments.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 32, top: 12),
              child: Column(
                children: message.comments
                    .map((c) => _buildCommentItem(c))
                    .toList(),
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(left: 32, top: 8),
            child: TextButton(
              onPressed: () => _showReplyDialog(message),
              child: const Text('Reply', style: TextStyle(fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentItem(DiscussionComment comment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                comment.userName ?? 'User',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                DateFormat('HH:mm').format(comment.createdAt),
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(comment.content, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Future<void> _downloadAndOpenFile(String url) async {
    try {
      final fileName = url.split('/').last;
      final tempDir = await getTemporaryDirectory();
      final savePath = '${tempDir.path}/$fileName';

      final baseUrl =
          dotenv.env['API_BASE_URL']?.replaceAll('/api', '') ??
          'http://localhost:3000';
      final fullUrl = '$baseUrl$url';

      await sl<dio_lib.Dio>().download(fullUrl, savePath);
      await OpenFile.open(savePath);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error opening file: $e')));
    }
  }

  Widget _buildFileAttachment(String url) {
    final fileName = url.split('/').last;
    return InkWell(
      onTap: () => _downloadAndOpenFile(url),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.primary.withOpacity(0.1)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.insert_drive_file,
              color: AppTheme.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              fileName,
              style: const TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.1))),
      ),
      child: Column(
        children: [
          if (_selectedFile != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  const Icon(Icons.attach_file, size: 16),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_selectedFile!.path.split('/').last)),
                  IconButton(
                    icon: const Icon(Icons.close, size: 16),
                    onPressed: () => setState(() => _selectedFile = null),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              // IconButton(
              //   icon: const Icon(Icons.attach_file),
              //   onPressed: _pickFile,
              //   color: AppTheme.textSecondary,
              // ),
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Share something...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: AppTheme.background,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _sendMessage,
                icon: const Icon(Icons.send),
                color: AppTheme.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showReplyDialog(DiscussionMessage message) async {
    final replyController = TextEditingController();
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reply'),
        content: TextField(
          controller: replyController,
          decoration: const InputDecoration(hintText: 'Write your reply...'),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (replyController.text.trim().isNotEmpty) {
                context.read<DiscussionBloc>().add(
                  PostComment(
                    message.id,
                    widget.group.id,
                    replyController.text,
                  ),
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Reply'),
          ),
        ],
      ),
    );
  }
}
