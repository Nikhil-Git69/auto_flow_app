import 'dart:convert';
import 'package:auto_flow/constants/app_paddings.dart';
import 'package:auto_flow/constants/app_textstyles.dart';
import 'package:auto_flow/features/detail/screen/detail_screen.dart';
import 'package:auto_flow/features/upload/screen/concept_analysis_screen.dart';
import 'package:auto_flow/features/upload/screen/custom_analysis_screen.dart';
import 'package:auto_flow/features/workspace/screen/comments_screen.dart';
import 'package:auto_flow/features/workspace/screen/project_timeline/project_timeline_screen.dart';
import 'package:auto_flow/features/workspace/service/workspace_service.dart';
import 'package:auto_flow/models/api_models/analysis_model.dart';
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
  int _selectedIndex = 0;
  int _documentFilterIndex = 0;
  bool _isLoadingDetails = true;

  @override
  void initState() {
    super.initState();
    _workspace = widget.workspace;
    _loadCurrentUser();
    _refreshWorkspace(); 
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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _copyAccessCode() {
    Clipboard.setData(ClipboardData(text: _workspace.accessCode));
    showSnackMessage("Access code copied to clipboard!");
  }

  // --- Member Management ---
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

          _workspace = _workspace.copyWith(
            members: updatedMembers,
          ); // Assuming copyWith or manual update
          // Manual update if copyWith doesn't exist
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
          showSnackMessage("$memberName removed successfully");
        }
      } else {
        if (mounted) {
          showSnackMessage(result['message'] ?? "Failed to remove member");
        }
      }
    }
  }

  // --- Document Management ---
  void _showDocumentOptions(AnalysisModel doc) {
    final isWorkspaceOwner = _currentUserId == _workspace.ownerId;
    final isDocumentOwner = doc.userId == _currentUserId;

    // Always show if user can view comments (everyone in workspace)
    // differentiating actions inside

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.comment_outlined,
                    color: Colors.blueGrey,
                  ),
                  title: const Text('Comments'),
                  onTap: () {
                    Navigator.pop(context);
                    _showComments(doc);
                  },
                ),
                if (isWorkspaceOwner)
                  ListTile(
                    leading: const Icon(
                      Icons.check_circle_outline,
                      color: Colors.blue,
                    ),
                    title: const Text('Set Status'),
                    onTap: () {
                      Navigator.pop(context);
                      _showStatusSelection(doc);
                    },
                  ),
                if (isWorkspaceOwner || isDocumentOwner)
                  ListTile(
                    leading: const Icon(Icons.delete, color: Colors.red),
                    title: const Text(
                      'Remove from Workspace',
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _confirmRemoveDocument(doc);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showComments(AnalysisModel doc) {
    if (_currentUserId == null) {
      showSnackMessage("User ID not found. Please relogin.");
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            CommentsScreen(workspaceId: _workspace.id, analysis: doc),
      ),
    );
  }

  void _showStatusSelection(AnalysisModel doc) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text("Set Status"),
        children: ['Pending', 'Accepted', 'Rejected']
            .map(
              (status) => SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                  _updateDocumentStatus(doc, status);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(status),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  void showSnackMessage(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _updateDocumentStatus(AnalysisModel doc, String status) async {
    final result = await WorkspaceService.updateDocumentStatus(
      _workspace.id,
      doc.analysisId ?? '',
      status,
    );

    if (result['success'] == true) {
      if (!mounted) return;
      // Update local state directly — no refresh needed
      final updatedDocs = (_workspace.documents ?? []).map((d) {
        if (d.analysisId == doc.analysisId) {
          // Recreate with updated status using toJson/fromJson
          final json = d.toJson();
          json['status'] = status;
          return AnalysisModel.fromJson(json);
        }
        return d;
      }).toList();
      setState(() {
        _workspace = _workspace.copyWith(documents: updatedDocs);
      });
      showSnackMessage("Status updated");
    } else {
      if (!mounted) return;
      showSnackMessage(result['message'] ?? "Failed to update");
    }
  }

  Future<void> _confirmRemoveDocument(AnalysisModel doc) async {
    try {
      final result = await WorkspaceService.removeDocument(
        _workspace.id,
        doc.analysisId ?? '',
      );

      if (result['success'] == true) {
        if (!mounted) return;
        // Update local state directly — no refresh needed (matching React's pattern)
        final updatedDocs = (_workspace.documents ?? [])
            .where((d) => d.analysisId != doc.analysisId)
            .toList();
        setState(() {
          _workspace = _workspace.copyWith(documents: updatedDocs);
        });
        showSnackMessage("Document removed");
      } else {
        if (!mounted) return;
        showSnackMessage(result['message'] ?? "Failed to remove doc");
      }
    } catch (e) {
      debugPrint('_confirmRemoveDocument error: $e');
      if (mounted) {
        showSnackMessage("Failed to remove document");
      }
    }
  }

  Future<void> _refreshWorkspace() async {
    setState(() {
      _isLoadingDetails = true;
    });
    try {
      final result = await WorkspaceService.getWorkspaceById(_workspace.id);
      debugPrint('RefreshWorkspace result success: ${result['success']}');
      if (result['success'] == true && mounted) {
        final data = result['data'];
        debugPrint('RefreshWorkspace data type: ${data.runtimeType}');
        if (data is WorkspaceModel) {
          debugPrint(
            'RefreshWorkspace members: ${data.members?.map((m) => m.name).toList()}',
          );
          setState(() {
            _workspace = data;
            _isLoadingDetails = false;
          });
        } else {
          debugPrint(
            'RefreshWorkspace: data is not WorkspaceModel, got ${data.runtimeType}',
          );
          setState(() {
            _isLoadingDetails = false;
          });
        }
      } else {
        debugPrint('RefreshWorkspace failed: ${result['message']}');
        if (mounted) {
          setState(() {
            _isLoadingDetails = false;
          });
        }
      }
    } catch (e) {
      debugPrint('RefreshWorkspace error: $e');
      if (mounted) {
        setState(() {
          _isLoadingDetails = false;
        });
      }
    }
  }

  List<AnalysisModel> get _filteredDocuments {
    final allDocs = _workspace.documents ?? [];
    if (_documentFilterIndex == 0) return allDocs;
    if (_documentFilterIndex == 1)
      return allDocs.where((d) => d.formatType == 'concept').toList();
    if (_documentFilterIndex == 2)
      return allDocs.where((d) => d.formatType == 'custom').toList();
    return allDocs
        .where((d) => d.formatType == 'default' || d.formatType == null)
        .toList();
  }

  Widget _buildMembersSection(BuildContext context, ColorScheme colorScheme) {
    final members = _workspace.members ?? [];
    final isOwner = _currentUserId == _workspace.ownerId;

    // Check if members have real names (not placeholder 'Member')
    final hasMemberNames =
        members.isEmpty || members.any((m) => m.name != 'Member');

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
        if (_isLoadingDetails && !hasMemberNames)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          )
        else if (!_showAllMembers)
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

  Widget _buildFilterTab(String label, int index) {
    final isSelected = _documentFilterIndex == index;
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () {
        setState(() {
          _documentFilterIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? colorScheme.onPrimary
                  : colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, ColorScheme colorScheme) {
    return RefreshIndicator(
      onRefresh: _refreshWorkspace,
      child: SingleChildScrollView(
        padding: AppPaddings.all16,
        physics:
            const AlwaysScrollableScrollPhysics(), // Ensure scrollable for refresh
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Documents", style: AppTextStyles.subMidHeader(context)),
                Text(
                  "${_workspace.documents?.length ?? 0} Total",
                  style: TextStyle(color: colorScheme.outline, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Filter Tabs
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildFilterTab("All", 0),
                  const SizedBox(width: 8),
                  _buildFilterTab("Concept", 1),
                  const SizedBox(width: 8),
                  _buildFilterTab("Custom", 2),
                  const SizedBox(width: 8),
                  _buildFilterTab("Default", 3),
                ],
              ),
            ),

            if (_filteredDocuments.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Text(
                    "No documents found.",
                    style: TextStyle(color: colorScheme.outline),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _filteredDocuments.length,
                itemBuilder: (context, index) {
                  final doc = _filteredDocuments[index];
                  return Card(
                    elevation: 0,
                    color: colorScheme.surfaceContainerLow,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: colorScheme.outlineVariant),
                    ),
                    child: InkWell(
                      onLongPress: () => _showDocumentOptions(doc),
                      borderRadius: BorderRadius.circular(12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: doc.formatType == 'concept'
                              ? Colors.indigo.shade100
                              : doc.formatType == 'custom'
                              ? Colors.amber.shade100
                              : colorScheme.primaryContainer,
                          child: Icon(
                            doc.formatType == 'concept'
                                ? Icons.schema
                                : doc.formatType == 'custom'
                                ? Icons.rule
                                : Icons.description,
                            color: doc.formatType == 'concept'
                                ? Colors.indigo
                                : doc.formatType == 'custom'
                                ? Colors.amber.shade900
                                : colorScheme.onPrimaryContainer,
                          ),
                        ),
                        title: Text(
                          doc.fileName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  "Score: ${doc.totalScore}/100",
                                  style: TextStyle(
                                    color: doc.totalScore > 70
                                        ? Colors.green
                                        : Colors.orange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (doc.status != null)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Text(
                                      "• ${doc.status}",
                                      style: TextStyle(
                                        color: colorScheme.outline,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            if (doc.formatType != null &&
                                doc.formatType != 'default')
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: doc.formatType == 'concept'
                                        ? Colors.indigo.shade50
                                        : Colors.amber.shade50,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: doc.formatType == 'concept'
                                          ? Colors.indigo.shade200
                                          : Colors.amber.shade200,
                                      width: 0.5,
                                    ),
                                  ),
                                  child: Text(
                                    doc.formatType!.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: doc.formatType == 'concept'
                                          ? Colors.indigo
                                          : Colors.amber.shade900,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          if (doc.formatType == 'concept') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ConceptAnalysisScreen(analysis: doc),
                              ),
                            );
                          } else if (doc.formatType == 'custom') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    CustomAnalysisScreen(analysis: doc),
                              ),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DetailScreen(analysis: doc),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
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
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildDashboard(context, colorScheme),
          TimelineScreen(workspaceId: _workspace.id),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.timeline_outlined),
            selectedIcon: Icon(Icons.timeline),
            label: 'Timeline',
          ),
        ],
      ),
    );
  }
}
