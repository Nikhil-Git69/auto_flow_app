import 'package:auto_flow/constants/app_textstyles.dart';
import 'package:auto_flow/features/detail/screen/detail_screen.dart';
import 'package:auto_flow/features/history/widgets/file_tiles.dart';
import 'package:auto_flow/features/upload/screen/concept_analysis_screen.dart';
import 'package:auto_flow/features/upload/screen/custom_analysis_screen.dart';
import 'package:auto_flow/features/workspace/service/workspace_service.dart';
import 'package:auto_flow/models/api_models/analysis_model.dart';
import 'package:auto_flow/models/api_models/workspace_model.dart';
import 'package:auto_flow/services/analysis_service.dart';
import 'package:flutter/material.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<AnalysisModel> _allAnalyses = [];
  List<AnalysisModel> _filteredAnalyses = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    try {
      final data = await AnalysisService.getAllAnalyses();
      if (mounted) {
        setState(() {
          _allAnalyses = data;
          _isLoading = false;
          _filterAnalyses();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _filterAnalyses();
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error fetching history: $e")));
      }
    }
  }

  void _filterAnalyses() {
    List<AnalysisModel> temp = _allAnalyses;

    // Filter by Search
    if (_searchQuery.isNotEmpty) {
      temp = temp
          .where(
            (a) =>
                a.fileName.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }

    setState(() {
      _filteredAnalyses = temp;
    });
  }

  void _navigateToAnalysis(AnalysisModel analysis) {
    if (analysis.formatType == 'concept') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ConceptAnalysisScreen(analysis: analysis),
        ),
      );
    } else if (analysis.formatType == 'custom') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CustomAnalysisScreen(analysis: analysis),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DetailScreen(analysis: analysis),
        ),
      );
    }
  }

  Future<void> _showWorkspaceSelection(AnalysisModel analysis) async {
    final result = await WorkspaceService.getAllWorkspaces();
    if (!mounted) return;

    if (result['success'] != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? "Failed to fetch workspaces"),
        ),
      );
      return;
    }

    if (result['data'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to fetch workspaces: No data returned"),
        ),
      );
      return;
    }

    final workspaces = (result['data'] as List).cast<WorkspaceModel>();

    if (workspaces.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No workspaces found. Join or create one first."),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text("Upload to Workspace"),
        children: workspaces
            .map(
              (w) => SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                  _uploadToWorkspace(w.id, analysis);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(w.name),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Future<void> _uploadToWorkspace(
    String workspaceId,
    AnalysisModel analysis,
  ) async {
    // Immediate feedback
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Uploading to workspace..."),
        duration: Duration(seconds: 1), // Short duration, will be replaced
        backgroundColor: Colors.blue,
      ),
    );

    final result = await WorkspaceService.addAnalysisToWorkspace(
      workspaceId,
      analysis.toJson(),
    );
    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result['message']),
        backgroundColor: result['success'] ? Colors.green : Colors.red,
      ),
    );
  }

  void _showOptions(AnalysisModel analysis) {
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
                  leading: const Icon(Icons.upload_file, color: Colors.blue),
                  title: const Text('Upload to Workspace'),
                  onTap: () {
                    Navigator.pop(context);
                    _showWorkspaceSelection(analysis);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text(
                    'Delete Analysis',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _confirmDelete(analysis);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(AnalysisModel analysis) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Analysis"),
        content: Text(
          "Are you sure you want to delete '${analysis.fileName}'? This action cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (!mounted) return;
      _deleteAnalysis(analysis.analysisId ?? '');
    }
  }

  Future<void> _deleteAnalysis(String id) async {
    if (id.isEmpty) return;

    // Optimistic update
    setState(() {
      _allAnalyses.removeWhere((a) => a.analysisId == id);
      _filterAnalyses();
    });

    final result = await AnalysisService.deleteAnalysis(id);

    if (!mounted) return;

    if (result['success'] != true) {
      // Revert if failed
      _fetchHistory();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? "Failed to delete")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Analysis deleted successfully")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text(
          'Evaluation History',
          style: AppTextStyles.midHeader(
            context,
          ).copyWith(color: Theme.of(context).colorScheme.primary),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) {
                _searchQuery = value;
                _filterAnalyses();
              },
              decoration: InputDecoration(
                hintText: 'Search documents...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: colors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _fetchHistory,
                    child: _filteredAnalyses.isEmpty
                        ? ListView(
                            children: const [
                              SizedBox(height: 100),
                              Center(child: Text("No history found")),
                            ],
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _filteredAnalyses.length,
                            itemBuilder: (context, index) {
                              final analysis = _filteredAnalyses[index];
                              final fileType =
                                  (analysis.fileType?.toLowerCase() ?? '')
                                      .contains('pdf')
                                  ? FileType.pdf
                                  : FileType.word;

                              final status = analysis.totalScore >= 80
                                  ? ReviewStatus.good
                                  : (analysis.totalScore >= 50
                                        ? ReviewStatus.warning
                                        : ReviewStatus.critical);

                              return ReviewFileTile(
                                fileName: analysis.fileName,
                                submittedAt: analysis.uploadDate != null
                                    ? (DateTime.tryParse(
                                            analysis.uploadDate!,
                                          ) ??
                                          DateTime.now())
                                    : DateTime.now(),
                                score: analysis.totalScore,
                                fileType: fileType,
                                status: status,
                                analysisType: analysis.formatType ?? 'Default',
                                onUploadToWorkspace: () =>
                                    _showWorkspaceSelection(analysis),
                                onTap: () => _navigateToAnalysis(analysis),
                                onLongPress: () => _showOptions(analysis),
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}
