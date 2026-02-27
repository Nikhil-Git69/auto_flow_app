import 'package:flutter/material.dart';
import 'package:auto_flow/models/api_models/workspace_model.dart';

class WorkspaceAccessCodeCard extends StatelessWidget {
  final WorkspaceModel workspace;
  final bool isOwner;
  final VoidCallback onCopyAccessCode;

  const WorkspaceAccessCodeCard({
    super.key,
    required this.workspace,
    required this.isOwner,
    required this.onCopyAccessCode,
  });

  @override
  Widget build(BuildContext context) {
    if (!isOwner) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;

    return Container(
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
                  workspace.accessCode,
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
            onPressed: onCopyAccessCode,
            color: colorScheme.onSecondaryContainer,
          ),
        ],
      ),
    );
  }
}
