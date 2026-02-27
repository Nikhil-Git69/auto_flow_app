import 'package:flutter/material.dart';

class ProfileEditableRow extends StatelessWidget {
  final String field;
  final String label;
  final TextStyle labelStyle;
  final String editLabel;
  final TextEditingController controller;
  final Color primary;
  final String? placeholder;
  final bool isEditing;
  final bool isSaving;
  final VoidCallback onSave;
  final VoidCallback onCancel;
  final VoidCallback onEdit;

  const ProfileEditableRow({
    super.key,
    required this.field,
    required this.label,
    required this.labelStyle,
    required this.editLabel,
    required this.controller,
    required this.primary,
    this.placeholder,
    required this.isEditing,
    required this.isSaving,
    required this.onSave,
    required this.onCancel,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    if (isEditing) {
      return Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              autofocus: true,
              enabled: !isSaving,
              decoration: InputDecoration(
                hintText: placeholder,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: primary, width: 2),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          isSaving
              ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: primary,
                  ),
                )
              : Row(
                  children: [
                    IconButton(
                      onPressed: onSave,
                      icon: Icon(Icons.check_circle, color: primary),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      onPressed: onCancel,
                      icon: const Icon(
                        Icons.cancel_outlined,
                        color: Colors.grey,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: labelStyle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        TextButton(
          onPressed: onEdit,
          style: TextButton.styleFrom(foregroundColor: primary),
          child: Text(
            editLabel,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
