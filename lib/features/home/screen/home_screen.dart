import 'package:auto_flow/constants/app_paddings.dart';
import 'package:auto_flow/constants/app_textstyles.dart';
import 'package:auto_flow/features/home/widgets/profile_Header.dart';
import 'package:auto_flow/features/home/widgets/section_card.dart';
import 'package:auto_flow/features/home/widgets/tool_tiles.dart';
import 'package:auto_flow/features/workspace/service/workspace_service.dart';
import 'package:auto_flow/models/api_models/workspace_model.dart';
import 'package:flutter/material.dart';
import 'package:auto_flow/features/history/screen/history_screen.dart';
import 'package:auto_flow/models/api_models/analysis_model.dart';
import 'package:auto_flow/services/analysis_service.dart';
import 'package:auto_flow/features/history/widgets/file_tiles.dart';
import 'package:auto_flow/features/detail/screen/detail_screen.dart';
import 'package:auto_flow/models/api_models/user_model.dart';
import 'package:auto_flow/features/upload/screen/concept_analysis_screen.dart';
import 'package:auto_flow/features/upload/screen/custom_analysis_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<AnalysisModel> recentAnalysis = [];
  bool isLoading = true;
  UserModel? user;
  final _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchRecentAnalysis();
  }

  Future<void> _fetchUserData() async {
    try {
      final userDataStr = await _storage.read(key: 'userData');
      if (userDataStr != null) {
        setState(() {
          user = UserModel.fromJson(jsonDecode(userDataStr));
        });
      }
    } catch (e) {
      debugPrint("Error fetching user data: $e");
    }
  }

  Future<void> _fetchRecentAnalysis() async {
    try {
      final data = await AnalysisService.getAllAnalyses(limit: 5);
      if (mounted) {
        setState(() {
          recentAnalysis = data;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      debugPrint("Error fetching recent analysis: $e");
    }
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
    final result = await WorkspaceService.addAnalysisToWorkspace(
      workspaceId,
      analysis.toJson(),
    );
    if (!mounted) return;

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
                    _deleteAnalysis(analysis);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _deleteAnalysis(AnalysisModel analysis) async {
    final id = analysis.analysisId ?? '';
    if (id.isEmpty) return;

    setState(() {
      recentAnalysis.removeWhere((a) => a.analysisId == id);
    });

    final result = await AnalysisService.deleteAnalysis(id);

    if (!mounted) return;

    if (result['success'] != true) {
      // Revert if failed
      _fetchRecentAnalysis();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? "Failed to delete")),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Analysis deleted")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          "Home",
          style: AppTextStyles.midHeader(
            context,
          ).copyWith(color: colorScheme.primary),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.workspace_premium_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: AppPaddings.all16,
        child: RefreshIndicator(
          onRefresh: _fetchRecentAnalysis,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProfileHeader(colorScheme: colorScheme, user: user),
                const SizedBox(height: 24),
                SectionCard(
                  title: "Upload Limit",
                  icon: Icons.warning,
                  child: Text(
                    "Upload limit for the day: 1/3 left",
                    style: AppTextStyles.smallHeader(
                      context,
                    ).copyWith(color: colorScheme.onSurface),
                  ),
                ),
                const SizedBox(height: 24),

                SectionCard(
                  title: "Explore Tools",
                  icon: Icons.explore_outlined,
                  child: Column(
                    children: const [
                      ToolTile(
                        icon: Icons.upload_file,
                        title: "Document Analysis",
                        subtitle: "Upload and validate formatting",
                      ),
                      ToolTile(
                        icon: Icons.swap_horiz_outlined,
                        title: "Convertor",
                        subtitle: "Convert documents",
                      ),
                      ToolTile(
                        icon: Icons.insights_outlined,
                        title: "AI Feedback",
                        subtitle: "Get structured writing feedback",
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Recent Analysis",
                      style: AppTextStyles.subMidHeader(
                        context,
                      ).copyWith(color: colorScheme.primary),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const HistoryScreen(),
                          ),
                        );
                      },
                      child: Text(
                        "View All",
                        style: AppTextStyles.smallHeader(
                          context,
                        ).copyWith(color: colorScheme.primary),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                if (isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (recentAnalysis.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text("No recent analysis found"),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: recentAnalysis.length,
                    itemBuilder: (context, index) {
                      final analysis = recentAnalysis[index];
                      return ReviewFileTile(
                        fileName: analysis.fileName,
                        submittedAt: analysis.uploadDate != null
                            ? (DateTime.tryParse(analysis.uploadDate!) ??
                                  DateTime.now())
                            : DateTime.now(),
                        score: analysis.totalScore,
                        fileType:
                            (analysis.fileType?.toLowerCase() ?? '').contains(
                              'pdf',
                            )
                            ? FileType.pdf
                            : FileType.word,
                        status: analysis.totalScore >= 80
                            ? ReviewStatus.good
                            : (analysis.totalScore >= 50
                                  ? ReviewStatus.warning
                                  : ReviewStatus.critical),
                        analysisType: analysis.formatType ?? 'Default',
                        onUploadToWorkspace: () =>
                            _showWorkspaceSelection(analysis),
                        onTap: () => _navigateToAnalysis(analysis),
                        onLongPress: () => _showOptions(analysis),
                      );
                    },
                  ),

                const SizedBox(height: 60), // Bottom padding
              ],
            ),
          ),
        ),
      ),
    );
  }
}
