import 'package:auto_flow/features/history/widgets/file_type_icon.dart';
import 'package:auto_flow/features/history/widgets/score_badge.dart';
import 'package:flutter/material.dart';

enum FileType { pdf, word }

enum ReviewStatus { good, warning, critical }

class ReviewFileTile extends StatelessWidget {
  final String fileName;
  final DateTime submittedAt;
  final int score;
  final FileType fileType;
  final ReviewStatus status;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final String? analysisType;
  final VoidCallback? onUploadToWorkspace;

  const ReviewFileTile({
    super.key,
    required this.fileName,
    required this.submittedAt,
    required this.score,
    required this.fileType,
    required this.status,
    required this.onTap,
    this.onLongPress,
    this.analysisType,
    this.onUploadToWorkspace,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            FileTypeIcon(fileType: fileType),

            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fileName,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  Row(
                    children: [
                      Text(
                        'Checked on ${_formatDate(submittedAt)}',
                        style: theme.textTheme.bodyMedium,
                      ),
                      if (analysisType != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: colors.primaryContainer.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            analysisType!.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: colors.onPrimaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // // Upload
            // if (onUploadToWorkspace != null)
            //   IconButton(
            //     icon: const Icon(Icons.upload_file_outlined, size: 20),
            //     tooltip: "Save to Workspace",
            //     onPressed: onUploadToWorkspace,
            //     color: colors.primary,
            //   ),

            // Score
            // ScoreBadge(score: score),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
