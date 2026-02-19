import 'dart:developer';
import 'package:auto_flow/constants/app_paddings.dart';
import 'package:auto_flow/constants/app_textstyles.dart';
import 'package:auto_flow/core/custom_widgets/custom_button.dart';
import 'package:auto_flow/core/custom_widgets/custom_textfields.dart';
import 'package:auto_flow/features/workspace/screen/workspace_detail_screen.dart';
import 'package:auto_flow/features/workspace/service/workspace_service.dart';
import 'package:auto_flow/models/api_models/workspace_model.dart';
import 'package:flutter/material.dart';

class WorkspaceScreen extends StatefulWidget {
  const WorkspaceScreen({super.key});

  @override
  State<WorkspaceScreen> createState() => _WorkspaceScreenState();
}

class _WorkspaceScreenState extends State<WorkspaceScreen> {
  List<WorkspaceModel> _workspaces = [];
  bool _isLoading = false;

  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _joinCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchWorkspaces();
  }

  Future<void> _fetchWorkspaces() async {
    setState(() => _isLoading = true);
    final result = await WorkspaceService.getAllWorkspaces();

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success'] == true) {
      setState(() {
        _workspaces = result['data'];
      });
    } else {
      _showSnack(result['message'] ?? "Failed to load workspaces");
    }
  }

  Future<void> _createWorkspace() async {
    if (_nameController.text.isEmpty) {
      _showSnack("Workspace name is required");
      return;
    }

    Navigator.pop(context); // Close dialog
    setState(() => _isLoading = true);

    final result = await WorkspaceService.createWorkspace(
      _nameController.text.trim(),
      _descController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success'] == true) {
      _showSnack("Workspace created!");
      _fetchWorkspaces();
      _nameController.clear();
      _descController.clear();
    } else {
      _showSnack(result['message'] ?? "Failed to create workspace");
    }
  }

  Future<void> _joinWorkspace() async {
    if (_joinCodeController.text.isEmpty ||
        _joinCodeController.text.length != 6) {
      _showSnack("Please enter a valid 6-character code");
      return;
    }

    Navigator.pop(context); // Close dialog
    setState(() => _isLoading = true);

    final result = await WorkspaceService.joinWorkspace(
      _joinCodeController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success'] == true) {
      _showSnack("Joined workspace!");
      _fetchWorkspaces();
      _joinCodeController.clear();
    } else {
      _showSnack(result['message'] ?? "Failed to join workspace");
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  void _showCreateDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Create Workspace"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustTextfield(
              controller: _nameController,
              labelText: "Name",
              icon: Icons.work_outline,
            ),
            const SizedBox(height: 16),
            CustTextfield(
              controller: _descController,
              labelText: "Description (Optional)",
              icon: Icons.description_outlined,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          CustomButton(text: "Create", onPressed: _createWorkspace, width: 100),
        ],
      ),
    );
  }

  void _showJoinDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Join Workspace"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Enter the 6-character access code shared by the owner.",
            ),
            const SizedBox(height: 16),
            CustTextfield(
              controller: _joinCodeController,
              labelText: "Access Code",
              icon: Icons.key_outlined,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          CustomButton(text: "Join", onPressed: _joinWorkspace, width: 100),
        ],
      ),
    );
  }

  void _showOptionsBottomSheet(WorkspaceModel ws) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                ws.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  "Delete Workspace",
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete(ws);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDelete(WorkspaceModel ws) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Workspace?"),
        content: Text(
          "Are you sure you want to delete '${ws.name}'? This action cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() => _isLoading = true);

              final result = await WorkspaceService.deleteWorkspace(ws.id);

              if (!mounted) return;
              setState(() => _isLoading = false);

              if (result['success'] == true) {
                _showSnack("Workspace deleted");
                _fetchWorkspaces();
              } else {
                _showSnack(result['message'] ?? "Failed to delete");
              }
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          "Workspaces",
          style: AppTextStyles.midHeader(
            context,
          ).copyWith(color: colorScheme.primary),
        ),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchWorkspaces,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _workspaces.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.workspaces_outlined,
                    size: 64,
                    color: colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "No Workspaces Found",
                    style: AppTextStyles.subMidHeader(context),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Create one or join existing.",
                    style: AppTextStyles.smallHeader(
                      context,
                    ).copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: AppPaddings.all16,
              itemCount: _workspaces.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final ws = _workspaces[index];
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => WorkspaceDetailScreen(workspace: ws),
                      ),
                    );
                  },
                  onLongPress: () => _showOptionsBottomSheet(ws),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colorScheme.outlineVariant),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.shadow.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.workspaces,
                                color: colorScheme.onPrimaryContainer,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ws.name,
                                    style: AppTextStyles.subMidHeader(
                                      context,
                                    ).copyWith(fontSize: 18),
                                  ),
                                  if (ws.description != null &&
                                      ws.description!.isNotEmpty)
                                    Text(
                                      ws.description!,
                                      style: TextStyle(
                                        color: colorScheme.onSurfaceVariant,
                                        fontSize: 13,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 14,
                              color: colorScheme.outline,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "${ws.createdAt.day}/${ws.createdAt.month}/${ws.createdAt.year}",
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.outline,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              "${ws.documents?.length ?? 0} Docs",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            heroTag: 'join',
            onPressed: _showJoinDialog,
            label: const Text("Join"),
            icon: const Icon(Icons.login),
            backgroundColor: colorScheme.surface,
            foregroundColor: colorScheme.primary,
          ),
          const SizedBox(height: 16),
          FloatingActionButton.extended(
            heroTag: 'create',
            onPressed: _showCreateDialog,
            label: const Text("Create"),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
