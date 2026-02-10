import 'package:auto_flow/constants/app_paddings.dart';
import 'package:auto_flow/constants/app_textstyles.dart';
import 'package:auto_flow/models/api_models/upload_model.dart';
import 'package:flutter/material.dart';

class DetailScreen extends StatefulWidget {
  final AnalysisModel analysis;

  const DetailScreen({Key? key, required this.analysis}) : super(key: key);

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final analysis = widget.analysis;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          analysis.fileName,
          style: AppTextStyles.midHeader(context).copyWith(color: colorScheme.onPrimary),
        ),
        centerTitle: true,
        backgroundColor: colorScheme.primary,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: colorScheme.onPrimary),
      ),
      body: Padding(
        padding: AppPaddings.all16,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Score Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      "Document Score",
                      style: AppTextStyles.subMidHeader(context),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "${analysis.totalScore}/100",
                      style: AppTextStyles.largeHeader(context).copyWith(
                        color: analysis.totalScore > 70 ? Colors.green : Colors.orange,
                        fontSize: 32,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Summary Section
              if (analysis.summary.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: colorScheme.outlineVariant,
                      width: 1.0,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Analysis Summary",
                        style: AppTextStyles.midHeader(context),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        analysis.summary,
                        style: AppTextStyles.smallHeader(context),
                      ),
                    ],
                  ),
                ),
              
              const SizedBox(height: 20),

              // Issues Section
              Text(
                "Issues Found (${analysis.issues.length})",
                style: AppTextStyles.midHeader(context),
              ),
              const SizedBox(height: 10),

              if (analysis.issues.isEmpty)
                const Center(child: Text("No issues found! Great job."))
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: analysis.issues.length,
                  itemBuilder: (context, index) {
                    final issue = analysis.issues[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Chip(
                                  label: Text(issue.type),
                                  backgroundColor: colorScheme.primaryContainer,
                                  labelStyle: TextStyle(color: colorScheme.onPrimaryContainer, fontSize: 12),
                                  padding: EdgeInsets.zero,
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                Text(
                                  issue.severity,
                                  style: TextStyle(
                                    color: issue.severity == 'Critical' ? colorScheme.error : Colors.orange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              issue.description,
                              style: AppTextStyles.subMidHeader(context).copyWith(fontSize: 16),
                            ),
                            if (issue.suggestion != null && issue.suggestion!.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.green.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.lightbulb_outline, size: 16, color: Colors.green),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        "Suggestion: ${issue.suggestion}",
                                        style: TextStyle(color: Colors.green[800], fontSize: 13),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
