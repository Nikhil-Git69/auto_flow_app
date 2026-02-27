import 'package:flutter/material.dart';
import 'package:auto_flow/models/api_models/analysis_model.dart';
import 'package:auto_flow/constants/app_textstyles.dart';

class WorkspaceDocumentList extends StatelessWidget {
  final List<AnalysisModel> filteredDocuments;
  final Function(AnalysisModel) onDocumentLongPress;
  final Function(AnalysisModel) onDocumentTap;

  const WorkspaceDocumentList({
    super.key,
    required this.filteredDocuments,
    required this.onDocumentLongPress,
    required this.onDocumentTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Documents", style: AppTextStyles.subMidHeader(context)),
            Text(
              "${filteredDocuments.length} Total",
              style: TextStyle(color: colorScheme.outline, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (filteredDocuments.isEmpty)
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
            itemCount: filteredDocuments.length,
            itemBuilder: (context, index) {
              final doc = filteredDocuments[index];
              return Card(
                elevation: 0,
                color: colorScheme.surfaceContainerLow,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: colorScheme.outlineVariant),
                ),
                child: InkWell(
                  onLongPress: () => onDocumentLongPress(doc),
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
                                color: Colors.amber.shade50,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: Colors.amber.shade200,
                                  width: 0.5,
                                ),
                              ),
                              child: Text(
                                doc.formatType!.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber.shade900,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => onDocumentTap(doc),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}
