import 'dart:convert';
import 'package:auto_flow/constants/app_paddings.dart';
import 'package:auto_flow/constants/app_textstyles.dart';
import 'package:auto_flow/features/detail/screen/detail_screen.dart';
import 'package:auto_flow/features/detail/screen/report_analysis_screen.dart';
import 'package:auto_flow/features/workspace/screen/comments_screen.dart';
import 'package:auto_flow/features/workspace/widgets/workspace_members_section.dart';
import 'package:auto_flow/features/workspace/widgets/workspace_reference_materials_tab.dart';
import 'package:auto_flow/features/workspace/widgets/workspace_access_code_card.dart';
import 'package:auto_flow/features/workspace/widgets/workspace_document_list.dart';
import 'package:auto_flow/features/workspace/screen/project_timeline/project_timeline_screen.dart';
import 'package:auto_flow/features/workspace/service/workspace_service.dart';
import 'package:auto_flow/models/api_models/analysis_model.dart';
import 'package:auto_flow/models/api_models/workspace_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

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

          _workspace = _workspace.copyWith(members: updatedMembers);
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

  Future<void> _promoteMember(String memberId, String memberName) async {
    final result = await WorkspaceService.promoteToCoAdmin(
      _workspace.id,
      memberId,
    );
    if (result['success'] == true) {
      showSnackMessage("$memberName promoted to Co-Admin");
      _refreshWorkspace();
    } else {
      showSnackMessage(result['message'] ?? "Failed to promote");
    }
  }

  Future<void> _demoteMember(String memberId, String memberName) async {
    final result = await WorkspaceService.demoteToMember(
      _workspace.id,
      memberId,
    );
    if (result['success'] == true) {
      showSnackMessage("$memberName demoted to Member");
      _refreshWorkspace();
    } else {
      showSnackMessage(result['message'] ?? "Failed to demote");
    }
  }

  void _showDocumentOptions(AnalysisModel doc) {
    final isDocumentOwner = doc.userId == _currentUserId;

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
                if (_isAdmin)
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
                if (_isOwner || isDocumentOwner)
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

  // ─── Role helpers (mirrors WorkspaceDetailView.tsx lines 87-90) ───────────
  bool get _isOwner =>
      _currentUserId != null && _currentUserId == _workspace.ownerId;
  bool get _isCoAdmin =>
      _currentUserId != null &&
      (_workspace.coAdmins?.contains(_currentUserId) ?? false);
  bool get _isAdmin => _isOwner || _isCoAdmin;

  List<AnalysisModel> get _filteredDocuments {
    final allDocs = _workspace.documents ?? [];

    // Document visibility: owners see everything, co-admins and members
    // see only their own documents — matches React filter at line 95.
    return allDocs.where((doc) {
      if (_isOwner) return true;
      return doc.userId != null && doc.userId == _currentUserId;
    }).toList();
  }

  Widget _buildMembersSection(BuildContext context, ColorScheme colorScheme) {
    return WorkspaceMembersSection(
      workspace: _workspace,
      currentUserId: _currentUserId,
      isLoadingDetails: _isLoadingDetails,
      showAllMembers: _showAllMembers,
      onToggleShowAll: () {
        setState(() {
          _showAllMembers = !_showAllMembers;
        });
      },
      onPromote: _promoteMember,
      onDemote: _demoteMember,
      onRemove: _removeMember,
    );
  }

  Widget _buildDashboard(BuildContext context, ColorScheme colorScheme) {
    return RefreshIndicator(
      onRefresh: _refreshWorkspace,
      child: SingleChildScrollView(
        padding: AppPaddings.all16,
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Info
            if (_workspace.description != null) ...[
              Text(
                _workspace.description!,
                style: AppTextStyles.smallHeader(context).copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
            ] else ...[
              const SizedBox(height: 8),
            ],

            // Role chip (mirrors WorkspaceDetailView.tsx line 126)
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _isOwner
                      ? Colors.amber.shade50
                      : _isCoAdmin
                      ? Colors.blue.shade50
                      : colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _isOwner
                        ? Colors.amber.shade200
                        : _isCoAdmin
                        ? Colors.blue.shade200
                        : colorScheme.outlineVariant,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isOwner
                          ? Icons.admin_panel_settings
                          : _isCoAdmin
                          ? Icons.security
                          : Icons.person_outline,
                      size: 16,
                      color: _isOwner
                          ? Colors.amber.shade800
                          : _isCoAdmin
                          ? Colors.blue.shade800
                          : colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Role: ${_isOwner
                          ? 'Admin'
                          : _isCoAdmin
                          ? 'Co-Admin'
                          : 'Member'}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _isOwner
                            ? Colors.amber.shade800
                            : _isCoAdmin
                            ? Colors.blue.shade800
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Access Code Card
            WorkspaceAccessCodeCard(
              workspace: _workspace,
              isOwner: _isOwner,
              onCopyAccessCode: _copyAccessCode,
            ),

            const SizedBox(height: 32),

            // Members Section
            _buildMembersSection(context, colorScheme),

            const SizedBox(height: 32),

            // Document list
            WorkspaceDocumentList(
              filteredDocuments: _filteredDocuments,
              onDocumentLongPress: _showDocumentOptions,
              onDocumentTap: (doc) {
                if (doc.formatType == 'report') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReportAnalysisScreen(analysis: doc),
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
          ],
        ),
      ),
    );
  }

  Widget _buildReferenceMaterialsTab(
    BuildContext context,
    ColorScheme colorScheme,
  ) {
    return WorkspaceReferenceMaterialsTab(
      workspace: _workspace,
      currentUserId: _currentUserId,
      onRefresh: _refreshWorkspace,
      onUploadAdminFile: _uploadAdminFile,
      onDeleteAdminFile: _deleteAdminFile,
      onDownloadAdminFile: _downloadAndOpenAdminFile,
    );
  }

  Future<void> _uploadAdminFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.any);
    if (result != null && result.files.single.path != null) {
      final path = result.files.single.path!;
      final name = result.files.single.name;
      setState(() {
        _isLoadingDetails = true;
      });

      final uploadResult = await WorkspaceService.uploadAdminFile(
        _workspace.id,
        path,
        name,
      );
      if (uploadResult['success'] == true) {
        showSnackMessage("File uploaded");
        _refreshWorkspace();
      } else {
        setState(() {
          _isLoadingDetails = false;
        });
        showSnackMessage(uploadResult['message'] ?? "Upload failed");
      }
    }
  }

  Future<void> _deleteAdminFile(String uploadId) async {
    setState(() {
      _isLoadingDetails = true;
    });
    final result = await WorkspaceService.deleteAdminFile(
      _workspace.id,
      uploadId,
    );
    if (result['success'] == true) {
      showSnackMessage("File deleted");
      _refreshWorkspace();
    } else {
      setState(() {
        _isLoadingDetails = false;
      });
      showSnackMessage(result['message'] ?? "Failed to delete file");
    }
  }

  Future<void> _downloadAndOpenAdminFile(
    String uploadId,
    String fileName,
  ) async {
    showSnackMessage("Downloading $fileName...");
    try {
      final url = await WorkspaceService.getAdminFileDownloadUrl(
        _workspace.id,
        uploadId,
      );
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/$fileName');
        await file.writeAsBytes(response.bodyBytes);
        await OpenFilex.open(file.path);
      } else {
        showSnackMessage("Failed to download file from URL.");
      }
    } catch (e) {
      showSnackMessage("Error opening file: $e");
    }
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
          _buildReferenceMaterialsTab(context, colorScheme),
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
            icon: Icon(Icons.library_books_outlined),
            selectedIcon: Icon(Icons.library_books),
            label: 'Reference',
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
