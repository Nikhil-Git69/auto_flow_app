import 'package:flutter/material.dart';
import 'package:auto_flow/models/api_models/workspace_model.dart';
import 'package:auto_flow/constants/app_textstyles.dart';

class WorkspaceReferenceMaterialsTab extends StatelessWidget {
  final WorkspaceModel workspace;
  final String? currentUserId;
  final Future<void> Function() onRefresh;
  final VoidCallback onUploadAdminFile;
  final Function(String) onDeleteAdminFile;
  final Function(String, String) onDownloadAdminFile;

  const WorkspaceReferenceMaterialsTab({
    super.key,
    required this.workspace,
    required this.currentUserId,
    required this.onRefresh,
    required this.onUploadAdminFile,
    required this.onDeleteAdminFile,
    required this.onDownloadAdminFile,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final uploads = workspace.adminUploads ?? [];
    final isOwner = currentUserId == workspace.ownerId;
    final isCoAdmin = workspace.coAdmins?.contains(currentUserId) == true;
    final canUpload = isOwner || isCoAdmin;

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: Stack(
        children: [
          if (uploads.isEmpty)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.folder_open, size: 64, color: colorScheme.outline),
                  const SizedBox(height: 16),
                  Text(
                    "No Reference Materials",
                    style: AppTextStyles.subMidHeader(context),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    canUpload
                        ? "Upload materials to share with members."
                        : "Admins haven't uploaded any materials yet.",
                    style: AppTextStyles.smallHeader(
                      context,
                    ).copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            )
          else
            ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              itemCount: uploads.length,
              itemBuilder: (context, index) {
                final file = uploads[index];
                final sizeMB = (file.fileSize / (1024 * 1024)).toStringAsFixed(
                  2,
                );

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 0,
                  color: colorScheme.surfaceContainerLow,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: colorScheme.outlineVariant),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: colorScheme.secondaryContainer,
                      child: Icon(
                        Icons.insert_drive_file,
                        color: colorScheme.onSecondaryContainer,
                      ),
                    ),
                    title: Text(
                      file.fileName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "$sizeMB MB • ${file.uploadDate.day}/${file.uploadDate.month}/${file.uploadDate.year}",
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.download),
                          onPressed: () =>
                              onDownloadAdminFile(file.id, file.fileName),
                        ),
                        if (canUpload)
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => onDeleteAdminFile(file.id),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          if (canUpload)
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                onPressed: onUploadAdminFile,
                child: const Icon(Icons.upload_file),
              ),
            ),
        ],
      ),
    );
  }
}
