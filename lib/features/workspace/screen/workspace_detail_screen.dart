import 'dart:convert';
import 'package:auto_flow/constants/app_paddings.dart';
import 'package:auto_flow/constants/app_textstyles.dart';
import 'package:auto_flow/features/detail/screen/detail_screen.dart';
import 'package:auto_flow/features/workspace/service/workspace_service.dart';
import 'package:auto_flow/models/api_models/workspace_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class WorkspaceDetailScreen extends StatefulWidget {
  final WorkspaceModel workspace;

  const WorkspaceDetailScreen({super.key, required this.workspace});

  @override
  State<WorkspaceDetailScreen> createState() => _WorkspaceDetailScreenState();
}

class _WorkspaceDetailScreenState extends State<WorkspaceDetailScreen> {
  late WorkspaceModel _workspace;
  bool _showAllMembers = false;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _workspace = widget.workspace;
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    const storage = FlutterSecureStorage();
    final String? userDataString = await storage.read(key: 'userData');
    if (userDataString != null) {
      final userMap = jsonDecode(userDataString);
      setState(() {
        _currentUserId = userMap['_id'] ?? userMap['id'];
      });
    }
  }

  void _copyAccessCode() {
    Clipboard.setData(ClipboardData(text: _workspace.accessCode));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Access code copied to clipboard!")),
    );
  }

  Future<void> _removeMember(String memberId, String memberName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Remove Member"),
        content: Text("Are you sure you want to remove $memberName?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Remove"),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final result = await WorkspaceService.removeMember(
        _workspace.id,
        memberId,
      );

      if (result['success'] == true) {
        setState(() {
          final updatedMembers = _workspace.members
              ?.where((m) => (m.id ?? m.studentId) != memberId)
              .toList();


          _workspace = WorkspaceModel(
            id: _workspace.id,
            name: _workspace.name,
            description: _workspace.description,
            accessCode: _workspace.accessCode,
            ownerId: _workspace.ownerId,
            memberIds: _workspace.memberIds,
            documents: _workspace.documents,
            createdAt: _workspace.createdAt,
            members: updatedMembers,
          );
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("$memberName removed successfully")),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? "Failed to remove member"),
            ),
          );
        }
      }
    }
  }

  Widget _buildMembersSection(BuildContext context, ColorScheme colorScheme) {
    final members = _workspace.members ?? [];
    final isOwner = _currentUserId == _workspace.ownerId; // Simple ID check

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "WORKSPACE MEMBERS (${members.length})",
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                letterSpacing: 1.2,
              ),
            ),
            if (isOwner && members.isNotEmpty)
              TextButton(
                onPressed: () {
                  setState(() {
                    _showAllMembers = !_showAllMembers;
                  });
                },
                child: Text(
                  _showAllMembers ? "Show Less" : "Manage Members",
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (!_showAllMembers)
          // Compact View
          Row(
            children: [
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: members.length > 8 ? 8 : members.length,
                  itemBuilder: (context, index) {
                    final member = members[index];
                    return Align(
                      widthFactor: 0.8,
                      child: Tooltip(
                        message: member.name,
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: colorScheme.primary,
                          child: Text(
                            member.name.substring(0, 2).toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (members.length > 8)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    "+${members.length - 8} more",
                    style: TextStyle(
                      color: colorScheme.outline,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          )
        else
          // Expanded View
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            constraints: const BoxConstraints(maxHeight: 300),
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.all(8),
              itemCount: members.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final member = members[index];
                final memberId = member.id ?? member.studentId ?? '';
                final isMe = memberId == _currentUserId;
                final isAdmin = memberId == _workspace.ownerId;

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: colorScheme.primaryContainer,
                    child: Text(
                      member.name.substring(0, 2).toUpperCase(),
                      style: TextStyle(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Row(
                    children: [
                      Flexible(
                        child: Text(
                          member.name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      if (isMe)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "You",
                            style: TextStyle(
                              fontSize: 10,
                              color: colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      if (isAdmin)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "Admin",
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.amber.shade800,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  subtitle: Text(member.email),
                  trailing: (isOwner && !isMe)
                      ? IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          onPressed: () => _removeMember(memberId, member.name),
                        )
                      : null,
                );
              },
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _workspace.name,
          style: AppTextStyles.midHeader(
            context,
          ).copyWith(color: colorScheme.onPrimary),
        ),
        centerTitle: true,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: colorScheme.onPrimary),
      ),
      body: SingleChildScrollView(
        padding: AppPaddings.all16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Info
            if (_workspace.description != null)
              Text(
                _workspace.description!,
                style: AppTextStyles.smallHeader(context).copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),

            const SizedBox(height: 24),

            // Access Code Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(Icons.vpn_key, color: colorScheme.onSecondaryContainer),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "ACCESS CODE",
                          style: TextStyle(
                            color: colorScheme.onSecondaryContainer,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _workspace.accessCode,
                          style: TextStyle(
                            color: colorScheme.onSecondaryContainer,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: _copyAccessCode,
                    color: colorScheme.onSecondaryContainer,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Members Section
            _buildMembersSection(context, colorScheme),

            const SizedBox(height: 32),

            // Documents Section
            Text(
              "Documents (${_workspace.documents?.length ?? 0})",
              style: AppTextStyles.subMidHeader(context),
            ),
            const SizedBox(height: 16),

            if (_workspace.documents == null || _workspace.documents!.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Text(
                    "No documents yet.",
                    style: TextStyle(color: colorScheme.outline),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _workspace.documents!.length,
                itemBuilder: (context, index) {
                  final doc = _workspace.documents![index];
                  return Card(
                    elevation: 0,
                    color: colorScheme.surfaceContainerLow,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: colorScheme.outlineVariant),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: colorScheme.primaryContainer,
                        child: Icon(
                          Icons.description,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                      title: Text(
                        doc.fileName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        "Score: ${doc.totalScore}/100",
                        style: TextStyle(
                          color: doc.totalScore > 70
                              ? Colors.green
                              : Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DetailScreen(analysis: doc),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
