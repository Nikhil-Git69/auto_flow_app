import 'dart:convert';
import 'dart:developer';

import 'package:auto_flow/constants/app_textstyles.dart';
import 'package:auto_flow/core/custom_widgets/custom_button.dart';
import 'package:auto_flow/features/workspace/service/workspace_service.dart';
import 'package:auto_flow/models/api_models/analysis_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';

import 'package:auto_flow/models/api_models/workspace_model.dart';

class CommentsScreen extends StatefulWidget {
  final String workspaceId;
  final AnalysisModel analysis;

  const CommentsScreen({
    super.key,
    required this.workspaceId,
    required this.analysis,
  });

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final TextEditingController _commentController = TextEditingController();
  final _storage = const FlutterSecureStorage();
  List<CommentModel> _comments = [];
  bool _isLoading = false;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _comments = widget.analysis.comments ?? [];
    _getCurrentUserId();
    _refreshComments();
  }

  Future<void> _getCurrentUserId() async {
    _currentUserId = await _storage.read(key: 'userId');
    setState(() {});
  }

  Future<void> _refreshComments() async {
    setState(() {
      _isLoading = true;
    });
    try {
      // Fetch fresh workspace data to get latest comments
      final result = await WorkspaceService.getWorkspaceById(
        widget.workspaceId,
      );

      if (!mounted) return;

      if (result['success'] == true && result['data'] != null) {
        final workspace = WorkspaceModel.fromJson(result['data']);
        final doc = workspace.documents?.firstWhere(
          (d) => d.analysisId == widget.analysis.analysisId,
          orElse: () => widget
              .analysis, // Assuming AnalysisModel can be treated as DocumentModel here
        );

        if (doc != null && mounted) {
          setState(() {
            _comments = doc.comments ?? [];
          });
        }
      }
    } catch (e) {
      log("Error refreshing comments: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) return;

    final text = _commentController.text.trim();
    _commentController.clear();
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    final result = await WorkspaceService.addDocumentComment(
      widget.workspaceId,
      widget.analysis.analysisId ?? '',
      text,
    );

    if (!mounted) return;

    if (result['success'] == true && result['data'] != null) {
      try {
        final workspaceMap =
            result['data']; // It's likely a Map if from JSON, but Service might return Object?
        // WorkspaceService.addDocumentComment returns raw 'data' from response.
        // Let's check WorkspaceService again. It returns data: response['data'].

        final workspace = WorkspaceModel.fromJson(workspaceMap);
        final doc = workspace.documents?.firstWhere(
          (d) => d.analysisId == widget.analysis.analysisId,
          orElse: () => widget
              .analysis, // Assuming AnalysisModel can be treated as DocumentModel here
        );

        if (doc != null && mounted) {
          setState(() {
            _comments = doc.comments ?? [];
            _isLoading = false;
          });
        } else {
          _refreshComments(); // Fallback
        }
      } catch (e) {
        log("Error parsing response: $e");
        if (mounted) await _refreshComments();
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Failed to add comment')),
        );
      }
    }
  }

  Future<void> _editComment(CommentModel comment) async {
    final editController = TextEditingController(text: comment.text);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Edit Comment"),
        content: TextField(
          controller: editController,
          decoration: const InputDecoration(
            hintText: "Update your comment...",
            border: OutlineInputBorder(),
          ),
          maxLines: null,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Save"),
          ),
        ],
      ),
    );

    if (confirmed != true || editController.text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    final result = await WorkspaceService.editDocumentComment(
      widget.workspaceId,
      widget.analysis.analysisId ?? '',
      comment.id,
      editController.text.trim(),
    );

    if (!mounted) return;

    if (result['success'] == true) {
      await _refreshComments();
    } else {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Failed to edit comment')),
      );
    }
  }

  Future<void> _deleteComment(String commentId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Comment"),
        content: const Text("Are you sure you want to delete this comment?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isLoading = true;
    });

    final result = await WorkspaceService.deleteDocumentComment(
      widget.workspaceId,
      widget.analysis.analysisId ?? '',
      commentId,
    );

    if (!mounted) return;

    if (result['success'] == true) {
      // Backend returns workspace on delete too
      if (result['data'] != null) {
        try {
          final workspace = WorkspaceModel.fromJson(
            result['data'],
          ); // Assuming data is map
          final doc = workspace.documents?.firstWhere(
            (d) => d.analysisId == widget.analysis.analysisId,
            orElse: () => widget
                .analysis, // Assuming AnalysisModel can be treated as DocumentModel here
          );
          if (mounted) {
            setState(() {
              _comments = doc?.comments ?? [];
              _isLoading = false;
            });
          }
        } catch (e) {
          log("Error parsing response on delete: $e");
          if (mounted) await _refreshComments();
        }
      } else {
        if (mounted) await _refreshComments();
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed to delete comment'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text("Comments", style: AppTextStyles.midHeader(context)),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _comments.isEmpty
                ? Center(
                    child: Text(
                      "No comments yet.\nStart the conversation!",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _comments.length,
                    itemBuilder: (context, index) {
                      final comment = _comments[index];
                      final isMe = comment.userId == _currentUserId;
                      return _buildCommentTile(context, comment, isMe);
                    },
                  ),
          ),
          if (_isLoading) const LinearProgressIndicator(),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  offset: const Offset(0, -2),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: "Write a comment...",
                      filled: true,
                      fillColor: colorScheme.surfaceContainerHighest
                          .withOpacity(0.3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _isLoading ? null : _addComment,
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentTile(
    BuildContext context,
    CommentModel comment,
    bool isMe,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final timeStr = DateFormat.yMMMd().add_Hm().format(comment.createdAt);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: colorScheme.primaryContainer,
              child: Text(
                comment.userName.isNotEmpty
                    ? comment.userName[0].toUpperCase()
                    : '?',
                style: TextStyle(
                  color: colorScheme.onPrimaryContainer,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                if (!isMe)
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 2),
                    child: Text(
                      comment.userName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isMe
                        ? colorScheme.primaryContainer
                        : colorScheme.surfaceContainerHighest.withOpacity(0.5),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: isMe
                          ? const Radius.circular(16)
                          : const Radius.circular(4),
                      bottomRight: isMe
                          ? const Radius.circular(4)
                          : const Radius.circular(16),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        comment.text,
                        style: TextStyle(
                          color: isMe
                              ? colorScheme.onPrimaryContainer
                              : colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        timeStr,
                        style: TextStyle(
                          fontSize: 10,
                          color: colorScheme.outline,
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => _editComment(comment),
                          child: Text(
                            "Edit",
                            style: TextStyle(
                              fontSize: 10,
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => _deleteComment(comment.id),
                          child: Text(
                            "Delete",
                            style: TextStyle(
                              fontSize: 10,
                              color: colorScheme.error,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isMe) const SizedBox(width: 8),
        ],
      ),
    );
  }
}
