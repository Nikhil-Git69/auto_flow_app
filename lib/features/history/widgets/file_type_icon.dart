import 'package:auto_flow/features/history/widgets/file_tiles.dart';
import 'package:flutter/material.dart';


class FileTypeIcon extends StatelessWidget {
  final FileType fileType;

  const FileTypeIcon({required this.fileType});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    IconData icon = Icons.description;
    String label = 'DOC';

    switch (fileType) {
      case FileType.pdf:
        icon = Icons.picture_as_pdf;
        label = 'PDF';
        break;
      case FileType.word:
        icon = Icons.description;
        label = 'DOCX';
        break;
    }

    return Container(
      height: 44,
      width: 44,
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: colors.onPrimaryContainer),
    );
  }
}
