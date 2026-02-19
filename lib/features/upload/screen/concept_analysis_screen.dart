import 'package:auto_flow/constants/app_paddings.dart';
import 'package:auto_flow/constants/app_textstyles.dart';
import 'package:auto_flow/models/api_models/analysis_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class ConceptAnalysisScreen extends StatefulWidget {
  final AnalysisModel analysis;

  const ConceptAnalysisScreen({super.key, required this.analysis});

  @override
  State<ConceptAnalysisScreen> createState() => _ConceptAnalysisScreenState();
}

class _ConceptAnalysisScreenState extends State<ConceptAnalysisScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final analysis = widget.analysis;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Concept Breakdown",
          style: AppTextStyles.midHeader(
            context,
          ).copyWith(color: colorScheme.onPrimary),
        ),
        centerTitle: true,
        backgroundColor: colorScheme.primary,
        iconTheme: IconThemeData(color: colorScheme.onPrimary),
        bottom: TabBar(
          controller: _tabController,
          labelColor: colorScheme.onPrimary,
          unselectedLabelColor: colorScheme.onPrimary.withValues(alpha: 0.7),
          indicatorColor: colorScheme.onPrimary,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: "Summary"),
            Tab(text: "Detailed WBS"),
          ],
        ),
      ),
      body: Column(
        children: [
          // Score Header
          Container(
            padding: const EdgeInsets.all(16),
            color: colorScheme.primaryContainer.withValues(alpha: 0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      analysis.fileName,
                      style: AppTextStyles.subMidHeader(context),
                    ),
                    Text(
                      "Uploaded: ${analysis.uploadDate}",
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getScoreColor(analysis.totalScore),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "${analysis.totalScore}/100",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSummaryTab(context, analysis),
                _buildDetailedWBSTab(context, analysis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryTab(BuildContext context, AnalysisModel analysis) {
    return SingleChildScrollView(
      padding: AppPaddings.all16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Executive Summary", style: AppTextStyles.midHeader(context)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Text(
              analysis.summary.isNotEmpty
                  ? analysis.summary
                  : "No summary available.",
              style: const TextStyle(height: 1.5, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedWBSTab(BuildContext context, AnalysisModel analysis) {
    return SingleChildScrollView(
      padding: AppPaddings.all16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (analysis.processedContent != null &&
              analysis.processedContent!.isNotEmpty)
            Html(
              data: analysis.processedContent,
              style: {
                "body": Style(
                  fontSize: FontSize(16),
                  lineHeight: LineHeight(1.5),
                ),
                "h1": Style(color: Theme.of(context).colorScheme.primary),
                "h2": Style(color: Theme.of(context).colorScheme.primary),
                "ul": Style(padding: HtmlPaddings.only(left: 20)),
              },
            )
          else
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text("No detailed breakdown available."),
              ),
            ),
        ],
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 90) return Colors.green;
    if (score >= 70) return Colors.teal;
    if (score >= 50) return Colors.orange;
    return Colors.red;
  }
}
