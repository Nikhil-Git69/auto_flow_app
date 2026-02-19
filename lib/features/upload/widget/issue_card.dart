import 'package:auto_flow/constants/app_textstyles.dart';
import 'package:auto_flow/models/api_models/analysis_model.dart';
import 'package:flutter/material.dart';

class IssueCard extends StatelessWidget {
  final AnalysisIssue issue;
  final VoidCallback? onApplyFix; // For future use

  const IssueCard({super.key, required this.issue, this.onApplyFix});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isCustomFormat = issue.customFormatIssue;

    // Determine colors based on severity and type
    Color severityColor;
    if (issue.severity == 'Critical') {
      severityColor = colorScheme.error;
    } else if (issue.severity == 'Major') {
      severityColor = Colors.orange;
    } else {
      severityColor = Colors.blue;
    }

    // Special styling for Custom Format issues
    if (isCustomFormat) {
      // Maybe purple or something distinct if needed, but sticking to severity for now
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isCustomFormat
            ? BorderSide(
                color: Colors.purple.withValues(alpha: 0.3),
                width: 1.5,
              )
            : BorderSide.none,
      ),
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
                  backgroundColor: isCustomFormat
                      ? Colors.purple.withValues(alpha: 0.1)
                      : colorScheme.primaryContainer,
                  labelStyle: TextStyle(
                    color: isCustomFormat
                        ? Colors.purple
                        : colorScheme.onPrimaryContainer,
                    fontSize: 12,
                  ),
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                Text(
                  issue.severity,
                  style: TextStyle(
                    color: severityColor,
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
                    const Icon(
                      Icons.lightbulb_outline,
                      size: 16,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Suggestion: ${issue.suggestion}",
                        style: TextStyle(
                          color: Colors.green[800],
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            // Add Apply Fix button here later if needed
          ],
        ),
      ),
    );
  }
}
