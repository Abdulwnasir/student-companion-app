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
import '../../auth/presentation/auth_bloc.dart';

class DiscussionThreadPage extends StatefulWidget {
  final DiscussionGroup group;

  const DiscussionThreadPage({super.key, required this.group});

  @override
  State<DiscussionThreadPage> createState() => _DiscussionThreadPageState();
}

class _DiscussionThreadPageState extends State<DiscussionThreadPage> {
  final _messageController = TextEditingController();
  File? _selectedFile;
  String _selectedPostType = 'Discussion';
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  final _postTypes = ['Discussion', 'Study Material', 'Question', 'Idea'];

  @override
  void initState() {
    super.initState();
    context.read<DiscussionBloc>().add(LoadMessages(widget.group.id));
    
    // Scroll to bottom when keyboard appears
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _scrollToBottom();
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles();
      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
        });
      }
    } catch (e) {
      _showError('Failed to pick file');
    }
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty || _selectedFile != null) {
      final content = _selectedPostType != 'Discussion' 
          ? '[$_selectedPostType] ${_messageController.text}'
          : _messageController.text;
          
      context.read<DiscussionBloc>().add(
        PostMessage(widget.group.id, content, _selectedFile),
      );
      _messageController.clear();
      setState(() {
        _selectedFile = null;
        _selectedPostType = 'Discussion';
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  void _showSuccess(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.green),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.watch<AuthBloc>().state.user;
    final currentUserId = currentUser?.id ?? '';

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.group.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (widget.group.description != null && widget.group.description!.isNotEmpty)
              Text(
                widget.group.description!,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                ),
              ),
          ],
        ),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'resources') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DiscussionResourcesPage(groupId: widget.group.id),
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
                      Icon(Icons.folder_shared, color: AppTheme.primary, size: 20),
                      SizedBox(width: 12),
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
          // Messages List
          Expanded(
            child: BlocBuilder<DiscussionBloc, DiscussionState>(
              builder: (context, state) {
                if (state.status == DiscussionStatus.loading && state.currentMessages.isEmpty) {
                  return _buildLoadingState();
                }

                if (state.currentMessages.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: state.currentMessages.length,
                  itemBuilder: (context, index) {
                    final message = state.currentMessages[index];
                    final isOwnMessage = message.userId == currentUserId;
                    return _buildMessageItem(message, isOwnMessage);
                  },
                );
              },
            ),
          ),
          // Input Area
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_selectedFile != null)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.insert_drive_file, size: 16, color: AppTheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _selectedFile!.path.split('/').last,
                      style: const TextStyle(fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  InkWell(
                    onTap: () => setState(() => _selectedFile = null),
                    child: const Icon(Icons.close, size: 16),
                  ),
                ],
              ),
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Post type dropdown
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.background,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedPostType,
                    icon: Icon(Icons.arrow_drop_down, color: AppTheme.textSecondary),
                    style: const TextStyle(fontSize: 12, color: AppTheme.textPrimary),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    items: _postTypes.map((type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedPostType = value);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Message input field
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.background,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TextField(
                    controller: _messageController,
                    focusNode: _focusNode,
                    decoration: InputDecoration(
                      hintText: 'Type your message here...',
                      hintStyle: TextStyle(
                        color: AppTheme.textSecondary.withOpacity(0.6),
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    maxLines: 4,
                    minLines: 1,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
              ),
              // Attach file button
              IconButton(
                icon: Icon(Icons.attach_file, color: AppTheme.textSecondary),
                onPressed: _pickFile,
              ),
              // Send button
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.send, color: Colors.white, size: 18),
                  onPressed: _sendMessage,
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading messages...'),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.forum_outlined,
              size: 48,
              color: AppTheme.primary.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No messages yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Be the first to start the conversation!',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageItem(DiscussionMessage message, bool isOwnMessage) {
    final messageType = _extractMessageType(message.content);
    final cleanContent = _extractCleanContent(message.content);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info row
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppTheme.primary.withOpacity(0.15),
                child: Text(
                  message.userName?.substring(0, 1).toUpperCase() ?? 'U',
                  style: TextStyle(
                    color: AppTheme.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.userName ?? 'User',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      DateFormat('MMM d, h:mm a').format(message.createdAt),
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              if (messageType != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getTypeColor(messageType),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    messageType,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          // Message bubble
          Container(
            margin: const EdgeInsets.only(left: 48),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isOwnMessage ? AppTheme.primary.withOpacity(0.1) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isOwnMessage ? AppTheme.primary.withOpacity(0.3) : Colors.grey.withOpacity(0.15),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cleanContent,
                  style: TextStyle(
                    fontSize: 15,
                    color: isOwnMessage ? AppTheme.primary : AppTheme.textPrimary,
                  ),
                ),
                if (message.fileUrl != null) ...[
                  const SizedBox(height: 12),
                  _buildFileAttachment(message.fileUrl!),
                ],
              ],
            ),
          ),
          // Comments section
          if (message.comments.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(left: 48, top: 8),
              child: Column(
                children: message.comments.map((c) => _buildCommentItem(c)).toList(),
              ),
            ),
          // Action buttons
          Padding(
            padding: const EdgeInsets.only(left: 48, top: 8),
            child: Row(
              children: [
                TextButton.icon(
                  onPressed: () => _showReplyDialog(message),
                  icon: Icon(Icons.reply, size: 16, color: AppTheme.textSecondary),
                  label: Text(
                    'Reply ${message.comments.isNotEmpty ? '(${message.comments.length})' : ''}',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                  ),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                const SizedBox(width: 16),
                TextButton.icon(
                  onPressed: () => _showReportDialog(message.id, 'MESSAGE', cleanContent),
                  icon: Icon(Icons.flag_outlined, size: 16, color: AppTheme.textSecondary),
                  label: Text(
                    'Report',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                  ),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentItem(DiscussionComment comment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: AppTheme.primary.withOpacity(0.1),
                child: Text(
                  comment.userName?.substring(0, 1).toUpperCase() ?? 'U',
                  style: TextStyle(
                    color: AppTheme.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
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
                          DateFormat('h:mm a').format(comment.createdAt),
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      comment.content,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Comment action buttons
          Padding(
            padding: const EdgeInsets.only(left: 38, top: 4),
            child: TextButton.icon(
              onPressed: () => _showReportDialog(comment.id, 'COMMENT', comment.content),
              icon: Icon(Icons.flag_outlined, size: 14, color: AppTheme.textSecondary),
              label: Text(
                'Report',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 11),
              ),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileAttachment(String url) {
    final fileName = url.split('/').last;
    return InkWell(
      onTap: () => _downloadAndOpenFile(url),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppTheme.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.insert_drive_file, color: AppTheme.primary, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                fileName,
                style: TextStyle(
                  color: AppTheme.primary,
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.download, color: AppTheme.primary, size: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadAndOpenFile(String url) async {
    try {
      final fileName = url.split('/').last;
      final tempDir = await getTemporaryDirectory();
      final savePath = '${tempDir.path}/$fileName';

      final baseUrl = dotenv.env['API_BASE_URL']?.replaceAll('/api', '') ??
          'http://192.168.137.102:3000';
      final fullUrl = '$baseUrl$url';

      await sl<dio_lib.Dio>().download(fullUrl, savePath);
      await OpenFile.open(savePath);
      _showSuccess('File downloaded successfully');
    } catch (e) {
      _showError('Error opening file: $e');
    }
  }

  Future<void> _showReplyDialog(DiscussionMessage message) async {
    final replyController = TextEditingController();
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reply to Message'),
        content: TextField(
          controller: replyController,
          decoration: InputDecoration(
            hintText: 'Write your reply...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          maxLines: 3,
          autofocus: true,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                    replyController.text.trim(),
                  ),
                );
                Navigator.pop(context);
                _scrollToBottom();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Post Reply'),
          ),
        ],
      ),
    );
  }

  String? _extractMessageType(String content) {
    if (content.startsWith('[') && content.contains('] ')) {
      return content.substring(1, content.indexOf('] '));
    }
    return null;
  }

  String _extractCleanContent(String content) {
    if (content.startsWith('[') && content.contains('] ')) {
      return content.substring(content.indexOf('] ') + 2);
    }
    return content;
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'Study Material':
        return Colors.green;
      case 'Question':
        return Colors.blue;
      case 'Idea':
        return Colors.purple;
      default:
        return AppTheme.primary;
    }
  }

  Future<void> _showReportDialog(String contentId, String contentType, String content) async {
    final reasonController = TextEditingController();
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Content'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Please provide a reason for reporting this content:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                hintText: 'Reason (e.g., spam, inappropriate)...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
              maxLines: 3,
              autofocus: true,
            ),
          ],
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (reasonController.text.trim().isNotEmpty) {
                Navigator.pop(context);
                await _submitReport(contentId, contentType, content, reasonController.text.trim());
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Report'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitReport(String contentId, String contentType, String content, String reason) async {
    try {
      await sl<dio_lib.Dio>().post('/moderation/report', data: {
        'contentId': contentId,
        'contentType': contentType,
        'content': content,
        'reason': reason,
      });
      _showSuccess('Content reported successfully');
    } catch (e) {
      if (e is dio_lib.DioException && e.response?.data != null) {
        final message = e.response?.data['message'] ?? 'Failed to report content';
        _showError(message);
      } else {
        _showError('Failed to report content');
      }
    }
  }
}
